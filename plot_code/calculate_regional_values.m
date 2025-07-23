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
FloodedArea = nan(size(Max_Hs));
FloodedArea(Max_Hs>=0.12) = 2;
FloodedArea(Pre_Hs>=0.12) = 1;
FloodedArea(LUCs==11) = 0;

validIdx = all(~isnan(buildingLocs), 2);  % rows with no NaN
cleanLocs = buildingLocs(validIdx, :);

buildFlooded = FloodedArea(cleanLocs);

% Plot to verify
lons_build = query_pts(validIdx,1);
lats_build = query_pts(validIdx,2);
filter_loc = buildFlooded == 2;

figure;
plot(lons_build(filter_loc), lats_build(filter_loc), '.');
xlabel('Longitude');
ylabel('Latitude');
title('Building Points from Shapefile');
axis equal;

Durations(Durations<=0) = nan;
Durations(FloodedArea<2 | isnan(FloodedArea)) = nan;
peaking_timing(FloodedArea<2 | isnan(FloodedArea)) = nan;
%Durations(isnan(FloodedArea)) = nan;
%peaking_timing(isnan(FloodedArea)) = nan;

figure;
s1 = subplot(131)
plot_global_map(trix, triy, FloodedArea, 0, 2, 'RDycore', 1, 1,'');

%hold on
%m_scatter(lons_build(filter_loc), lats_build(filter_loc), 4, '.', 'k');

clc = jet(3);
colormap(s1, clc);
hcb = colorbar;

s2 = subplot(132)
plot_global_map(trix, triy, Durations, 0, 10, 'RDycore', 1, 1,'');
clc = jet(11);
colormap(s2, clc);

hcb = colorbar;

s3 = subplot(133)
plot_global_map(trix, triy, peaking_timing, 0, 52, 'RDycore', 1, 1,'');
clc = jet(101);
colormap(s3, clc);
hcb = colorbar;

days_f = 0:7:50;

start_date = datetime(2017, 1, 7);
date_labels = cellstr(datestr(start_date + days_f, 'mmm-dd'));

% Apply tick labels to the colorbar
set(hcb, 'Ticks', days_f, 'TickLabels', date_labels);


%% FIGURE BUILDING
figure;
s1 = subplot(131)
plot_global_map(trix, triy, FloodedArea, 0, 2, 'RDycore', 1, 1,'');

clc = jet(3);
colormap(s1, clc);
hcb = colorbar;

hold on
m_scatter(lons_build(filter_loc), lats_build(filter_loc), 1, '.', 'r');


%% plot figures
urban_areas = nan(52,1);
crop_areas = nan(52,1);

for day_i = 1:52

    Max_H_i = Daily_MaxH(:,day_i)/1000;
    Pre_Hs = double(Pre_H)/1000;
    FloodedArea = nan(size(Max_H_i));
    FloodedArea(Max_H_i>=0.12) = 2;
    FloodedArea(Pre_Hs>=0.12) = 1;
    FloodedArea(LUCs==11) = 0;


    filters_flooded = FloodedArea == 2;
    LUCs_flooded = LUCs(filters_flooded);
    area_flooded = areas(filters_flooded);
    urban_areas(day_i,1) = sum(area_flooded(LUCs_flooded >= 21 & LUCs_flooded<=24))/100000;
    crop_areas(day_i,1) = sum(area_flooded(LUCs_flooded == 81 | LUCs_flooded==82))/100000;

end

%%all
Pre_Hs = double(Pre_H)/1000;
FloodedArea = nan(size(Max_Hs));
FloodedArea(Max_Hs>=0.12) = 2;
FloodedArea(Pre_Hs>=0.12) = 1;
FloodedArea(LUCs==11) = 0;

filters_flooded = FloodedArea == 2;
LUCs_flooded = LUCs(filters_flooded);
area_flooded = areas(filters_flooded);
urban_area_all = sum(area_flooded(LUCs_flooded >= 21 & LUCs_flooded<=24))/100000;
crop_area_all = sum(area_flooded(LUCs_flooded == 81 | LUCs_flooded==82))/100000;




% Assuming:
% urban_areas: 1 x 52
% crop_areas: 1 x 52
% urban_area_all: scalar
% crop_area_all: scalar

% Generate daily time vector starting from Jan 7
startDate = datetime(2025, 1, 7);
timeVec = startDate + days(0:51);

%% Plot
figure;

subplot(221)
hold on;

% Time series: urban and crop
plot(timeVec, urban_areas, '-', ...
    'LineWidth', 2.5, ...
    'Color', [0.85 0.33 0.1]);  % warm red-orange

plot(timeVec, crop_areas, '-', ...
    'LineWidth', 2.5, ...
    'Color', [0 0.45 0.74]);  % deep blue

% Constant lines
yline(urban_area_all, '--', ...
    'LineWidth', 2, ...
    'Color', [0.2 0.6 0.2], ...
    'Label', 'Urban Area (All)', ...
    'LabelHorizontalAlignment', 'left', ...
    'LabelVerticalAlignment', 'bottom');

yline(crop_area_all, '--', ...
    'LineWidth', 2, ...
    'Color', [0.49 0.18 0.56], ...  % purple
    'Label', 'Crop Area (All)', ...
    'LabelHorizontalAlignment', 'left', ...
    'LabelVerticalAlignment', 'top');

% Beautify
grid on;
%xlabel('Date');
ylabel('Area (ha)');
legend({'Urban Area', 'Crop Area', ...
        'Urban Area (All)', 'Crop Area (All)'}, ...
        'Location', 'northwest');
set(gca, 'FontSize', 12);

% Date formatting
xtickformat('MMM dd');
xlim([min(timeVec), max(timeVec)]);
box on

%%plot2
subplot(222);
hold on;
histogram(Durations(LUCs_flooded == 81 | LUCs_flooded == 82), ...
    'EdgeColor', [0 0.45 0.74], ...
    'LineWidth', 2);

histogram(Durations(LUCs_flooded >= 21 & LUCs_flooded <= 24), ...
    'EdgeColor', [0.85 0.33 0.1], ...
    'LineWidth', 2);


grid on;
xlabel('Flood Duration (days)');
ylabel('Frequency');
legend({'Crop', 'Urban'}, 'Location', 'northeast');
set(gca, 'FontSize', 12);


%%plot2
subplot(223);
hold on;
h1 = histogram(peaking_timing(LUCs_flooded == 81 | LUCs_flooded == 82), ...
    'EdgeColor', [0 0.45 0.74], ...
    'LineWidth', 2);

h2 = histogram(peaking_timing(LUCs_flooded >= 21 & LUCs_flooded <= 24), ...
    'EdgeColor', [0.85 0.33 0.1], ...
    'LineWidth', 2);

h1.NumBins = 1000;
h2.NumBins = 1000;

grid on;
xlabel('Flood Peaking Timing (days)');
ylabel('Frequency');
legend({'Crop', 'Urban'}, 'Location', 'northeast');
set(gca, 'FontSize', 12);
set(gca, 'xTick', days_f, 'xTickLabel', date_labels);

