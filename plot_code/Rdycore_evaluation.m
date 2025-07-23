clc;
clear all;
close all;

% Setup color scheme
colors = {[0, 114, 178]/255, ...  % Blue (RDycore)
          [213, 94, 0]/255, ...   % Orange-red (USGS obs)
          [0, 158, 115]/255, ...
          [204, 121, 167]/255};

m2ft = 3.28084;

% Load data
load("gage_measurements_all.mat");
load("gages_xyz.mat");
load("gage_height_Rdycore_500m_v2.mat");

USGS_gage_heights = USGS_gage_heights(1:1392,:);
line_width = 2;

% Gage group needing elevation offset
group_1 = [1 8 9 11 17 19 22 23 5 12 16];
elevs([5 12 16]) = elevs([5 12 16]) + ([2 16 75])'; % Adjust elevations

elevs = elevs/m2ft;
% Plot configuration
plot_gage_ids = [1 4:13 15:23];
nrows = 5;
ncols = 4;
font_size = 20;
startTime = datetime(2017, 1, 1, 0, 0, 0); % Base date

% Create figure
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.85, 0.75]);
tiledlayout(nrows, ncols, 'Padding', 'compact', 'TileSpacing', 'compact');

R_all = nan(20,1);
KGE_all = nan(20,1);
RMSE_all = nan(20,1);
for g = 1:length(plot_gage_ids)
    gage_i = plot_gage_ids(g);
    nexttile;
    hold on;

    % Get original USGS data
    hourMeanHeights = USGS_gage_heights(:, gage_i)/m2ft;
    surfaceElev = SurfaceElevs{gage_i};
    waterlevels = Height_Rdycores{gage_i, 1} ;

    hourMeanHeights_ori = hourMeanHeights((4*24+1-8):((4*24+1-8)+1295));
    if gage_i == 18
        hourMeanHeights_ori = hourMeanHeights_ori - 5.33/m2ft;
    elseif gage_i == 2
        hourMeanHeights_ori = hourMeanHeights_ori - 0.05/m2ft;
    end

    waterlevels = waterlevels(:, (4*24+1):((4*24+1)+1295));
    hourlytime = ((4*24+1):((4*24+1)+1295))';
    datetimeAxis = startTime + hours(hourlytime);

    % RMSE for best grid
    gridNum = size(waterlevels, 1);
    RMSEs = nan(gridNum, 1);
    for i = 1:gridNum
        waterlevels_i = waterlevels(i, :)';
        if ismember(gage_i, group_1)
            hourMeanHeights = hourMeanHeights_ori + (elevs(gage_i) - surfaceElev(i, 1));
        else
            hourMeanHeights = hourMeanHeights_ori;
        end
        RMSEs(i) = sqrt(mean((hourMeanHeights - waterlevels_i).^2, 'omitnan'));
    end

    index = find(RMSEs == min(RMSEs));
    if ismember(gage_i, group_1)
        hourMeanHeights = hourMeanHeights_ori + (elevs(gage_i) - surfaceElev(index, 1));
    else
        hourMeanHeights = hourMeanHeights_ori;
    end

    % Plot lines
    h1 = plot(datetimeAxis, waterlevels(index, :)', '--', 'Color', colors{1}, 'LineWidth', line_width);
    h2 = plot(datetimeAxis, hourMeanHeights, '-', 'Color', colors{2}, 'LineWidth', line_width);

    % R and KGE
    [R, KGE] = calc_KGE(waterlevels(index, :)', hourMeanHeights);
    R_all(g) = R;
    KGE_all(g) = KGE;
    RMSE_all(g) = min(RMSEs);
    yl = ylim;
    text(datetimeAxis(100), yl(2) - 0.1 * (yl(2) - yl(1)), ...
        ['R = ', num2str(R, '%.2f'), ', KGE = ', num2str(KGE, '%.2f')], ...
        'FontSize', font_size, 'Color', 'k');

    % Style
    set(gca, 'FontSize', font_size, 'LineWidth', 1);
    box on;

    % Show x-tick labels only on bottom row
    if g <= length(plot_gage_ids) - ncols
        set(gca, 'XTickLabel', []);
    else
        xtickformat('MM/dd');
    end

    % Only first subplot has legend
    if g == 1
        legend([h1, h2], {'Rdycore', 'Observations'}, 'Location', 'best', 'FontSize', 9);
    end
end

figure;
plot_global_map_site(lons([1 4:13 15:23]), lats([1 4:13 15:23]), R_all,0,1,'',1,1,'');

colormap jet

set(gcf, 'Color', 'w');
saveas(gcf, 'gage_heights_20sites_tight.png');
