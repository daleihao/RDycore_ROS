clc;
clear all;
close all;

calculate_daily_max_water_height;
calculate_peaking_timing;
peaking_timing = double(Peak_Ts)/24+double(Max_Ts-1);

region_name = 'CA2017';
prj_code = 32610;

[trix, triy, areas, elevs] = get_trixy_Jigsaw(region_name, prj_code);
load('LUC_2017.mat');

load("buildings_Locs.mat");
%% test
Max_Hs = double(max(Daily_MaxH,[],2))/1000;
Durations = double(sum(Daily_InuT ,2))/24;

Pre_Hs = double(Pre_H)/1000;

startDate = datetime(2017, 1, 7);
timeVec = startDate + days(0:51);

% Base colors (medium intensity)
urbanColor = [0.2 0.6 0.2];
cropColor = [0.49 0.18 0.56];
filteredColor = [0.85 0.33 0.1];

% Colors for line plots: solid lines deeper, dashed lines lighter
urbanColor_solid = urbanColor * 0.8 + 0.2;    % slightly lighter than base but not too light
urbanColor_dashed = urbanColor * 0.4 + 0.6;   % much lighter
cropColor_solid = cropColor * 0.8 + 0.2;
cropColor_dashed = cropColor * 0.4 + 0.6;

edges = [0, 1, 3, 7, 14, inf];
dur_labels = {'<1 day', '1–3 days', '3–7 days', '7–14 days', '>14 days'};

nBins = length(edges)-1;
urban_colors = zeros(nBins, 3);
crop_colors = zeros(nBins, 3);
filtered_colors = zeros(nBins, 3);
for i = 1:nBins
    factor = i/(nBins+0.5); % from 0.2 (lighter) to 1 (base color)
    urban_colors(i,:) = urbanColor * factor + (1 - factor);
    crop_colors(i,:) = cropColor * factor + (1 - factor);
    filtered_colors(i,:) = filteredColor * factor + (1 - factor);
end

% Define shading regions
shade_color = [0.8, 0.8, 0.8]; % Light gray
jan_start = datetime(2017,1,7,0,0,0);
jan_end   = datetime(2017,1,12,23,59,59);
feb_start = datetime(2017,2,6,0,0,0);
feb_end   = datetime(2017,2,12,23,59,59);
feb2_start = datetime(2017,2,16,0,0,0);
feb2_end   = datetime(2017,2,27,23,59,59);




%% calculate area
urban_areas = nan(52,1);
crop_areas = nan(52,1);
build_nums = nan(52,1);
build_num2s = nan(52,1);

urban_areas_acum = nan(52,1);
crop_areas_acum = nan(52,1);
build_nums_acum = nan(52,1);
build_num2s_acum = nan(52,1);

validIdx = all(~isnan(buildingLocs), 2);  % rows with no NaN
cleanLocs = buildingLocs(validIdx, :);

FloodedArea_before = zeros(size(Max_Hs));
FloodedArea_before2 = zeros(size(Max_Hs));

for day_i = 1:52

    Max_H_i = double(Daily_MaxH(:,day_i))/1000;
    Pre_Hs = double(Pre_H)/1000;
    FloodedArea = zeros(size(Max_H_i));
    FloodedArea(Max_H_i>=0.12) = 2;
    FloodedArea(Max_H_i>=0.46) = 3;
    FloodedArea(Pre_Hs>=0.12) = 1;
    FloodedArea(LUCs==11) = 0;


    filters_flooded = FloodedArea > 1;
    LUCs_flooded = LUCs(filters_flooded);
    area_flooded = areas(filters_flooded);
    urban_areas(day_i,1) = sum(area_flooded(LUCs_flooded >= 21 & LUCs_flooded<=24))/100000;
    crop_areas(day_i,1) = sum(area_flooded(LUCs_flooded == 81 | LUCs_flooded==82))/100000;
    build_nums(day_i,1) = sum(filters_flooded(cleanLocs));

    filters_flooded = FloodedArea > 1 | FloodedArea_before > 1;
    LUCs_flooded = LUCs(filters_flooded);
    area_flooded = areas(filters_flooded);
    urban_areas_acum(day_i,1) = sum(area_flooded(LUCs_flooded >= 21 & LUCs_flooded<=24))/100000;
    crop_areas_acum(day_i,1) = sum(area_flooded(LUCs_flooded == 81 | LUCs_flooded==82))/100000;
    build_nums_acum(day_i,1) = sum(filters_flooded(cleanLocs));

    filters_flooded2 = FloodedArea > 2;
    build_num2s(day_i,1) = sum(filters_flooded2(cleanLocs));
    filters_flooded2 = FloodedArea > 2 | FloodedArea_before2 > 2;
    build_num2s_acum(day_i,1) = sum(filters_flooded2(cleanLocs));

    FloodedArea_before(filters_flooded) = 2;
    FloodedArea_before2(filters_flooded2) = 3;
end

add_label = @(letter) text(0.92, 0.97, ['(' letter ')'], 'Units', 'normalized', ...
    'FontSize', 18, 'FontWeight', 'bold', 'VerticalAlignment', 'top');
add_label2 = @(letter) text(-0.05, 1.05, ['(' letter ')'], 'Units', 'normalized', ...
    'FontSize', 18, 'FontWeight', 'bold', 'VerticalAlignment', 'top');


%% Global Map on the left (40% width)
figure('Position', [100, 100, 1100, 900]);

p0 = subplot('Position', [0.05, 0.05, 0.58, 0.90]);
hold(p0, 'on');
load("cmaps.mat");
colors_abs = cmaps.NEO_modis_lst;

plot_global_map(trix, triy, Durations, 0, 30, '', 1, 1, '');
colormap(p0, colors_abs);
hcb = colorbar(p0);
title(hcb, 'Days');

set(p0, 'FontSize', 18, 'LineWidth',1);
add_label('a');

%% Right Side Layout
rightX = 0.68;
rightW = 0.3;

% Adjusted vertical positions
rightTopY = 0.72;        % lowered from 0.75
topHeight = 0.5;        % total stacked time-series height
bottomHeight = 0.43;     % space for pie charts

% --- Time series (stacked)
p1 = subplot('Position', [rightX, rightTopY, rightW, topHeight/2 - 0.02]);
hold(p1, 'on');
plot(p1, timeVec, urban_areas, '-', 'LineWidth', 2.5, 'Color', urbanColor_solid);
plot(p1, timeVec, crop_areas, '-', 'LineWidth', 2.5, 'Color', cropColor_solid);
plot(p1, timeVec, urban_areas_acum, '--', 'LineWidth', 2.5, 'Color', urbanColor_dashed);
plot(p1, timeVec, crop_areas_acum, '--', 'LineWidth', 2.5, 'Color', cropColor_dashed);
ylabel(p1, 'Area (km^{2})');
xtickformat(p1, 'MMM dd');
xlim(p1, [min(timeVec), max(timeVec)]);
% Shade the background for selected periods AFTER site data
y_limits = ylim;
yl = y_limits;

fill([jan_start jan_end jan_end jan_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
fill([feb_start feb_end feb_end feb_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);

fill([feb2_start feb2_end feb2_end feb2_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);



legend(p1, {'Urban', 'Crop'}, 'Location', 'northwest');
set(p1, 'FontSize', 12, 'LineWidth', 1,'XTickLabel',[]); box(p1, 'on');
add_label('b');


%% 2
p2 = subplot('Position', [rightX, rightTopY - topHeight/2, rightW, topHeight/2 - 0.02]);
hold(p2, 'on');
plot(p2, timeVec, build_nums, '-', 'Color', urbanColor_solid, 'LineWidth', 2);
plot(p2, timeVec, build_num2s, '-', 'Color', cropColor_solid, 'LineWidth', 2);
plot(p2, timeVec, build_nums_acum, '--', 'Color', urbanColor_dashed, 'LineWidth', 2);
plot(p2, timeVec, build_num2s_acum, '--', 'Color', cropColor_dashed, 'LineWidth', 2);
ylabel(p2, 'Number of Buildings');
xtickformat(p2, 'MMM dd');
xlim(p2, [min(timeVec), max(timeVec)]);

y_limits = ylim;
yl = y_limits;

fill([jan_start jan_end jan_end jan_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
fill([feb_start feb_end feb_end feb_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);

fill([feb2_start feb2_end feb2_end feb2_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);


legend(p2, {'Building (>0.12m)', 'Building (>0.46m)'}, 'Location', 'northwest');
set(p2, 'FontSize', 12, 'LineWidth', 1); box(p2, 'on');
add_label('c');



%% Pie Chart Positions (2×2)
rightX = 0.65;
rightW = 0.35;
pieW = rightW/2 - 0.01;
pieH = bottomHeight/2 - 0.01;
pieY1 = 0.01 + pieH ;
pieY2 = 0.01;
pieX1 = rightX;
pieX2 = rightX + rightW/2 + 0.01;

% --- Pie 1 (top-left)
p3 = subplot('Position', [pieX1, pieY1, pieW, pieH]);
urban_mask = (LUCs >= 21 & LUCs <= 24) & Pre_Hs < 0.12 & Max_Hs >= 0.12;
urban_durs = Durations(urban_mask);
urban_counts = histcounts(urban_durs, edges);
pieInsideLabels(urban_counts, dur_labels, urban_colors, 5);
text(0, 1.15, 'Urban', 'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');
add_label2('d');

% --- Pie 2 (top-right)
p4 = subplot('Position', [pieX2, pieY1, pieW, pieH]);
crop_mask = (LUCs == 81 | LUCs == 82) & Pre_Hs < 0.12 & Max_Hs > 0.12;
crop_durs = Durations(crop_mask);
crop_counts = histcounts(crop_durs, edges);
pieInsideLabels(crop_counts, dur_labels, crop_colors, 5);
text(0, 1.15, 'Crop', 'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');

% --- Pie 3 (bottom-left)
p5 = subplot('Position', [pieX1, pieY2, pieW, pieH]);
Durations2 = Durations;
Durations2(Pre_Hs > 0.12 | Max_Hs < 0.12) = nan;
filtered_build_durs = Durations2(cleanLocs);
filtered_build_durs = filtered_build_durs(~isnan(filtered_build_durs));
counts_filtered_build = histcounts(filtered_build_durs, edges);
pieInsideLabels(counts_filtered_build, dur_labels, filtered_colors, 5);
text(0, 1.15, 'Building (>0.12m)', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');

% --- Pie 4 (bottom-right)
p6 = subplot('Position', [pieX2, pieY2, pieW, pieH]);
Durations3 = Durations;
Durations3(Pre_Hs > 0.12 | Max_Hs < 0.46) = nan;
filtered_durs_2 = Durations3(cleanLocs);
filtered_durs_2 = filtered_durs_2(~isnan(filtered_durs_2));
counts_filtered_2 = histcounts(filtered_durs_2, edges);
pieInsideLabels(counts_filtered_2, dur_labels, filtered_colors, 5);
text(0, 1.15, 'Building (>0.46m)', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');

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
exportgraphics(gcf, 'Figure_5_duration.tiff', 'Resolution', 300);
hold off;
close all;

%% Helper Function: Pie with Inside Labels
function pieInsideLabels(counts, labels, colors, min_pct_to_label)
if nargin < 4
    min_pct_to_label = 0;
end
total = sum(counts);
h = pie(counts);
patchHandles = h(1:2:end);
textHandles = h(2:2:end);

for k = 1:length(patchHandles)
    patchHandles(k).FaceColor = colors(k,:);
end

for k = 1:length(textHandles)
    textHandles(k).String = '';
end

for k = 1:length(patchHandles)
    verts = patchHandles(k).Vertices;
    x = verts(:,1);
    y = verts(:,2);
    A = 0; Cx = 0; Cy = 0;
    for i = 1:length(x)-1
        step = x(i)*y(i+1) - x(i+1)*y(i);
        A = A + step;
        Cx = Cx + (x(i)+x(i+1))*step;
        Cy = Cy + (y(i)+y(i+1))*step;
    end
    A = A/2;
    Cx = Cx/(6*A);
    Cy = Cy/(6*A);
    pct = int32(100 * counts(k)/total);
    if pct > min_pct_to_label
        text(Cx, Cy, sprintf('%s\n%d%%', labels{k}, pct), ...
            'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    end
end
end
