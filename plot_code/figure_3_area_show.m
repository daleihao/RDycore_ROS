clc;
clear all;
close all;

% Load data
load("accumulated_rainrunoff.mat");   % meanRunoff, meanRAIN, Daily_MaxH, Pre_H
calculate_daily_max_water_height;
load('LUC_2017.mat');
load('latlon_2017.mat');
load('meanslope.mat');

Pre_Hs = double(Pre_H)/1000;
% Max water height (in meters)
Max_Hs = double(max(Daily_MaxH,[],2)) / 1000;

% Base variables
elevations = elevs/1000;
slope = meanslope;
floodedarea = Max_Hs > 0.12;% & Pre_Hs <0.12;

% Land cover masks
isUrban = LUCs >= 21 & LUCs <= 24;
isCrop = LUCs >= 81 & LUCs <= 82;
isVeg = LUCs >= 31 & LUCs <= 71;
isWetland = LUCs >= 90 & LUCs <= 95;

% Bin definitions
elev_edges = (0:300:2500)/1000;
runoff_edges = 0:4:28;
rain_edges = 0:2:16;
slope_edges = 0:4:28;

% Flooded ratios by 1D bins
flooded_ratio_elev   = calcFloodedRatio(elevations, elev_edges, floodedarea, isUrban, isCrop, isVeg, isWetland, areas);
flooded_ratio_runoff = calcFloodedRatio(meanRunoff, runoff_edges, floodedarea, isUrban, isCrop, isVeg, isWetland, areas);
flooded_ratio_rain   = calcFloodedRatio(meanRAIN, rain_edges, floodedarea, isUrban, isCrop, isVeg, isWetland, areas);
flooded_ratio_slope  = calcFloodedRatio(slope, slope_edges, floodedarea, isUrban, isCrop, isVeg, isWetland, areas);

% Bin centers
elev_centers = (elev_edges(1:end-1) + elev_edges(2:end)) / 2;
runoff_centers = (runoff_edges(1:end-1) + runoff_edges(2:end)) / 2;
rain_centers = (rain_edges(1:end-1) + rain_edges(2:end)) / 2;
slope_centers = (slope_edges(1:end-1) + slope_edges(2:end)) / 2;

% Total ratio per bin (across land cover types)
total_flooded_elev   = sum(flooded_ratio_elev, 2);
total_flooded_runoff = sum(flooded_ratio_runoff, 2);
total_flooded_rain   = sum(flooded_ratio_rain, 2);
total_flooded_slope  = sum(flooded_ratio_slope, 2);

% Correlation
r_elev_val   = corr(elev_centers', total_flooded_elev);
r_runoff_val = corr(runoff_centers', total_flooded_runoff);
r_rain_val   = corr(rain_centers', total_flooded_rain);
r_slope_val  = corr(slope_centers', total_flooded_slope);


%% === Plotting ===

% Label helper function
add_label = @(letter) text(0.92, 0.97, ['(' letter ')'], 'Units', 'normalized', ...
    'FontSize', 18, 'FontWeight', 'bold', 'VerticalAlignment', 'top');

% Define visually distinct, soft pastel colors
colors = [
    204,204,255;   % Urban - Light gray-blue
    255,204,153;   % Crop - Soft orange
    179,230,179;   % Vegetation - Light green
    180,255,255    % Wetland - Light cyan
] / 255;

figure('Position',[100 100 1000 800]);
%t = tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact');
t = tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Elevation subplot
nexttile
b = bar(elev_centers, flooded_ratio_elev * 100, 'stacked');
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xlabel('Elevation (km)')
ylabel('Flooded Ratio (%)')
ylim([0 20])
xlim([0 2.5])
legend({'Urban', 'Crop', 'Vegetation', 'Wetland'}, 'Location', 'north')
box on
set(gca,'linewidth',1,'fontsize',18)

add_label('a')

edges = elev_edges;
xticks(edges(1:end-1) + diff(edges)/2);
xticklabels(arrayfun(@(i) sprintf('%.1f–%.1f', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));
% Slope subplot
nexttile
b = bar(slope_centers, flooded_ratio_slope * 100, 'stacked');
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xlabel('Slope (°)')
ylabel('Flooded Ratio (%)')
ylim([0 15])
xlim([0, 28])
box on
set(gca,'linewidth',1)
set(gca,'linewidth',1,'fontsize',18)

add_label('b')

edges = slope_edges;
xticks(edges(1:end-1) + diff(edges)/2);
xticklabels(arrayfun(@(i) sprintf('%d-%d', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));


% Runoff subplot
nexttile
b = bar(runoff_centers, flooded_ratio_runoff * 100, 'stacked');
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xlabel('Mean Runoff (mm/day)')
ylabel('Flooded Ratio (%)')
ylim([0 10])

xlim([0, 28])
box on
set(gca,'linewidth',1)

set(gca,'linewidth',1,'fontsize',18)

add_label('c')

edges = runoff_edges;
xticks(edges(1:end-1) + diff(edges)/2);
xticklabels(arrayfun(@(i) sprintf('%d-%d', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));

%5 2D map
filters_LUC = LUCs>12;

floodedarea = Max_Hs > 0.12;% & Pre_Hs<0.12;

% === 2D Heatmap 1: Elevation vs Runoff ===
nElevBins = length(elev_edges) - 1;
nRunoffBins = length(runoff_edges) - 1;
flood_ratio_elev_runoff = nan(nElevBins, nRunoffBins);

for i = 1:nElevBins
    for j = 1:nRunoffBins
        elev_mask = elevations >= elev_edges(i) & elevations < elev_edges(i+1);
        runoff_mask = meanRunoff >= runoff_edges(j) & meanRunoff < runoff_edges(j+1);
        bin_mask = elev_mask & runoff_mask & filters_LUC;
        total_pixels = sum(areas(bin_mask));
        if total_pixels > 0
            flooded_pixels = sum(areas(floodedarea & bin_mask));
            flood_ratio_elev_runoff(i, j) = flooded_pixels / total_pixels * 100; % in %
        end
    end
end

% === 2D Heatmap 2: Slope vs Runoff ===
nSlopeBins = length(slope_edges) - 1;
flood_ratio_slope_runoff = nan(nSlopeBins, nRunoffBins);

for i = 1:nSlopeBins
    for j = 1:nRunoffBins
        slope_mask = slope >= slope_edges(i) & slope < slope_edges(i+1);
        runoff_mask = meanRunoff >= runoff_edges(j) & meanRunoff < runoff_edges(j+1);
        bin_mask = slope_mask & runoff_mask & filters_LUC;
        total_pixels = sum(areas(bin_mask));
        if total_pixels > 0
            flooded_pixels = sum(areas(floodedarea & bin_mask));
            flood_ratio_slope_runoff(i, j) = flooded_pixels / total_pixels * 100; % in %
        end
    end
end


% Load ColorBrewer colormap: Yellow-Orange-Red
cmap = brewermap(20, 'YlOrRd');  % Correct spelling

% --- Elevation vs Runoff ---
nexttile
h1 = imagesc(runoff_centers, elev_centers, flood_ratio_elev_runoff);
set(gca, 'YDir', 'normal');
xlabel('Mean Runoff (mm/day)')
ylabel('Elevation (km)')
colormap(gca, cmap);
cb = colorbar;
cb.Label.String = '%';
cb.Location = 'eastoutside';
cb.Label.Rotation = 0;
cb.Label.HorizontalAlignment = 'center';
cb.Label.Position(1) = cb.Label.Position(1) -1.6;
cb.Label.Position(2) = cb.Label.Position(2) -11.5;



caxis([0 30])

% Apply transparency to NaNs
set(h1, 'AlphaData', ~isnan(flood_ratio_elev_runoff));
set(gca, 'Color', [1 1 1]);  % background white for NaNs

box on
set(gca,'linewidth',1)

set(gca,'linewidth',1,'fontsize',18)
add_label('d')


% Set custom Y ticks (Elevation)
edges = elev_edges;
yticks(edges(1:end-1) + diff(edges)/2);
yticklabels(arrayfun(@(i) sprintf('%.1f–%.1f', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));
% Set custom X ticks (Runoff)
edges = runoff_edges;
xticks(edges(1:end-1) + diff(edges)/2);
xticklabels(arrayfun(@(i) sprintf('%d-%d', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));

xtickangle(45);  % Optional: rotate labels for better readability


% --- Slope vs Runoff ---
nexttile
h2 = imagesc(runoff_centers, slope_centers, flood_ratio_slope_runoff);
set(gca, 'YDir', 'normal');
xlabel('Mean Runoff (mm/day)')
ylabel('Slope (°)')
colormap(gca, cmap);
cb = colorbar;
cb.Label.String = '%';
cb.Location = 'eastoutside';
cb.Label.Rotation = 0;
cb.Label.HorizontalAlignment = 'center';
cb.Label.Position(1) = cb.Label.Position(1) -1.6;
cb.Label.Position(2) = cb.Label.Position(2) + 15.5;

caxis([0 20])

% Set custom Y ticks (Slope)
edges = slope_edges;
yticks(edges(1:end-1) + diff(edges)/2);
yticklabels(arrayfun(@(i) sprintf('%d-%d', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));

% Set custom X ticks (Runoff)
edges = runoff_edges;
xticks(edges(1:end-1) + diff(edges)/2);
xticklabels(arrayfun(@(i) sprintf('%d-%d', edges(i), edges(i+1)), 1:length(edges)-1, 'UniformOutput', false));

xtickangle(45);


% Apply transparency to NaNs
set(h2, 'AlphaData', ~isnan(flood_ratio_slope_runoff));
set(gca, 'Color', [1 1 1]);  % background white for NaNs


box on
set(gca,'linewidth',1)

set(gca,'linewidth',1,'fontsize',18)

add_label('e')

nexttile
load('feature_importance_no_wetland.mat');

predictor_names = {"Elevation", "Slope", "Runoff", "Land Cover"};

% Normalize importance to relative importance (percentage)
% Sort importance descending
[sortedImportance, sortIdx] = sort(relImportance, 'descend');
sortedNames = predictor_names(sortIdx);

% Create a colormap with a gradient (e.g., from light to dark blue)
%cmap = flipud(parula(length(sortedImportance)));  % You can use other colormaps too
cmap = flipud(brewermap(4, 'YlOrRd'));  % Correct spelling

hold on
for i = 1:length(sortedImportance)
    barh(i, sortedImportance(i), 'FaceColor', cmap(i,:), 'EdgeColor', 'none');
end

xlabel('Relative Importance (%)');
yticks(1:length(sortedImportance));
yticklabels(sortedNames);
set(gca, 'YDir', 'reverse');
box on
set(gca,'LineWidth',1,'FontSize',18)
add_label('f')

set(gca, 'YTickLabelRotation', 45);


set(gcf, 'Visible', 'on');  % 
fig = gcf;
set(fig, 'Units', 'inches');
fig_pos = get(fig, 'Position');  % [left bottom width height]

set(fig, 'PaperUnits', 'inches');
set(fig, 'PaperPosition', [0 0 fig_pos(3:4)]);
set(fig, 'PaperSize', fig_pos(3:4));

% Use the same renderer as on screen (OpenGL)
set(fig, 'Renderer', 'painters');


% Save the figure to a file (e.g., PNG)
exportgraphics(gcf, 'Figure_3_area_change_r2.tiff', 'Resolution', 300);
hold off;
close all;

%% function
function ratioMat = calcFloodedRatio(var_data, edges, floodedarea, isUrban, isCrop, isVeg, isWetland, areas)
nBins = length(edges) - 1;
ratioMat = nan(nBins, 4); % Urban, Crop, Veg, Wetland
for i = 1:nBins
    in_bin = var_data >= edges(i) & var_data < edges(i+1);
    masks_all = in_bin & (isUrban | isCrop | isVeg | isWetland);
    % Urban
    mask = in_bin & isUrban;
    if sum(mask) > 0
        ratioMat(i,1) = sum(floodedarea(mask).*areas(mask)) / sum(areas(masks_all));
    else
        ratioMat(i,1) = 0;
    end
    % Crop
    mask = in_bin & isCrop;
    if sum(mask) > 0
        ratioMat(i,2) = sum(floodedarea(mask).*areas(mask)) / sum(areas(masks_all));
    else
        ratioMat(i,2) = 0;
    end
    % Vegetation
    mask = in_bin & isVeg;
    if sum(mask) > 0
        ratioMat(i,3) = sum(floodedarea(mask).*areas(mask)) / sum(areas(masks_all));
    else
        ratioMat(i,3) = 0;
    end
    % Wetland
    mask = in_bin & isWetland;
    if sum(mask) > 0
        ratioMat(i,4) = sum(floodedarea(mask).*areas(mask)) / sum(areas(masks_all));
    else
        ratioMat(i,4) = 0;
    end
end
end

