clc; clear; close all;

% Load data
load("gage_measurements_all.mat");
load("gages_xyz.mat");
load("gage_height_Rdycore_500m_v3.mat");
USGS_gage_heights = USGS_gage_heights(1:1392,:);
m2ft = 3.28084;

% Elevation corrections
elevs([5 12 16]) = elevs([5 12 16]) + ([2 16 75])';
elevs = elevs / m2ft;

% Colors for plotting
colors = {[0, 114, 178]/255, ... % Blue
    [213, 94, 0]/255,   ... % Vermilion (Orange-Red)
    [0, 158, 115]/255,  ... % Teal (Greenish)
    [204, 121, 167]/255};   % Reddish-Purple

group_1 = [1 8 9 11 17 19 22 23 5 12 16]; % elevation adjustment
plot_gage_ids = [1 4:13 15:23];
plot_gage_ids_1 = [1 4:13 15:18 22];
plot_gage_ids_2 = [19:21 23];

startTime = datetime(2017, 1, 1, 0, 0, 0);

R_all = nan(length(plot_gage_ids),1);
RMSE_all = nan(length(plot_gage_ids),1);
KGE_all = nan(length(plot_gage_ids),1);


% Define shading regions
shade_color = [0.8, 0.8, 0.8]; % Light gray
jan_start = datetime(2017,1,7,0,0,0);
jan_end   = datetime(2017,1,12,23,59,59);
feb_start = datetime(2017,2,6,0,0,0);
feb_end   = datetime(2017,2,12,23,59,59);
feb2_start = datetime(2017,2,16,0,0,0);
feb2_end   = datetime(2017,2,27,23,59,59);




%% Layout parameters
map_w = 0.28;
map_h = 0.42; % taller maps
map_x = 0.01;
map_y_top = 0.55;
map_y_bot = 0.07;

colorbar_w = 0.015; % width of colorbar
colorbar_gap = 0.005; % gap between map and colorbar

ts_x = map_x + map_w + colorbar_w + 0.02; % time series start X
ts_w = 0.66;
ts_h = 0.18;
ts_cols = 4;
ts_rows = 5;
ts_dx = ts_w/ts_cols;
ts_dy = ts_h;

%% Step 1: Plot time series & calculate metrics
for g = 1:length(plot_gage_ids)
    col = mod(g-1, ts_cols);
    row = floor((g-1)/ts_cols);
    pos_x = ts_x + col*ts_dx;
    pos_y = 0.98 - (row+1)*ts_dy; % from top down


    gage_i = plot_gage_ids(g);
    h = USGS_gage_heights(:, gage_i)/m2ft;
    elev = SurfaceElevs{gage_i};
    wl = Height_Rdycores{gage_i,1};
    h = h((4*24+1-8):((4*24+1-8)+1295));
    if gage_i == 18, h = h - 5.33/m2ft; elseif gage_i == 2, h = h - 0.05/m2ft; elseif gage_i == 1, h = h + 0.25*m2ft; end
    wl = wl(:, (4*24+1):((4*24+1)+1295));
    t = startTime + hours((4*24+1):((4*24+1)+1295))';

    % Find best grid by RMSE
    gridNum = size(wl, 1);
    RMSEs = nan(gridNum,1);
    for i = 1:gridNum
        waterlevels_i = wl(i,:)';
        if ismember(gage_i, group_1)
            h_corr = h + (elevs(gage_i) - elev(i,1));
        else
            h_corr = h;
        end
        RMSEs(i) = sqrt(mean((h_corr - waterlevels_i).^2, 'omitnan'));
    end
    [minRMSE, idx] = min(RMSEs);

    if ismember(gage_i, group_1)
        h_corr = h + (elevs(gage_i) - elev(idx,1));
    else
        h_corr = h;
    end

    sim = wl(idx,:)';
    obs = h_corr;

    % Compute metrics
    [R, RMSE, KGE] = calc_KGE(sim, obs);
    R_all(g) = R;
    KGE_all(g) = KGE;
    RMSE_all(g) = RMSE;
    % Plot lines

end



%% Step 2: Plot maps now that R_all and KGE_all are known
% Create figure
figure('Units','normalized','Position',[0.05 0.05 0.3 0.45]);

% Correlation map
plot_global_map_site_ref2(lons(plot_gage_ids_1), lats(plot_gage_ids_1),lons(plot_gage_ids_2), lats(plot_gage_ids_2), RMSE_all([1:15 19]),RMSE_all([16:18 20]), 0, 1, 'RMSE (m)', 1, 1, '');
nColors = 10;
cmap = brewermap(nColors, 'GnBu');  % Red-Yellow-Blue diverging
colormap(cmap);
set(gca, 'FontSize', 15);

% Colorbar for R
cb1 = colorbar;
%ylabel(cb1, 'R value', 'FontSize', 11);
%cb1.Position(1) = cb1.Position(1)-0.04;  % example position, adjust to your layout
set(gca,'LineWidth',1)

set(gca,'LineWidth',1)
set(gca, 'FontSize', 15);

set(gcf, 'Visible', 'on');  % 显式设置图像可见（可选）
fig = gcf;
set(fig, 'Units', 'inches');
fig_pos = get(fig, 'Position');  % [left bottom width height]

set(fig, 'PaperUnits', 'inches');
set(fig, 'PaperPosition', [0 0 fig_pos(3:4)]);
set(fig, 'PaperSize', fig_pos(3:4));

% Use the same renderer as on screen (OpenGL)
set(fig, 'Renderer', 'painters');

% Save the figure to a file (e.g., PNG)
exportgraphics(gcf, 'Figure_S2_gage_height_comparison_RMSE.tiff', 'Resolution', 300);
hold off;
close all;

%% Helper function for metrics
function [R, RMSE, KGE] = calc_KGE(sim, obs)
sim = sim(:);
obs = obs(:);
valid = ~isnan(sim) & ~isnan(obs);
sim = sim(valid);
obs = obs(valid);

RMSE = sqrt(mean((sim-obs).^2));

if length(sim) < 2
    R = NaN; KGE = NaN;
    return;
end
R = corr(sim, obs);
beta = mean(sim) / mean(obs);
alpha = (std(sim)/mean(sim)) / (std(obs)./mean(obs));
KGE = 1 - sqrt((R - 1)^2 + (alpha - 1)^2 + (beta - 1)^2);
end

