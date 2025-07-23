clc;
clear all;
close all;

%load('CA_area_mask.mat'); 

calculate_daily_max_water_height;
Max_Hs = double(max(Daily_MaxH,[],2))/1000;

calculate_daily_max_water_height_satellite;
Max_Hs_3 = double(max(Daily_MaxH,[],2))/1000;

region_name = 'CA2017';
prj_code = 32610;

[trix, triy, areas, elevs] = get_trixy_Jigsaw(region_name, prj_code);
load('LUC_2017.mat');

save('latlon_2017.mat',"elevs","trix","triy","areas");

load("buildings_Locs.mat");

load('landsat_data.mat');
satellite_flood = landsat_data(:,1);
satellite_flood(landsat_data(:,5) == 1) = 2;
%% test

maxlevel = 2;
figure('Position', [100 100 1100 600]);

p0 = subplot('Position', [0.06 0.02 0.4 0.95]);

plot_global_map(trix, triy, Max_Hs, 0, maxlevel, 'RDycore (All)', 1, 1,'(a)');

%hold on
%m_scatter(lons_build(filter_loc), lats_build(filter_loc), 4, '.', 'k');
load("cmaps.mat");
colors_abs = cmaps.NEO_modis_lst;
colors_discrete = [
    0.8 0.8 0.8;    % non-flooded (light gray)
    0.0 0.5 1.0;    % flooded (blue)
    0.0 0.2 0.5     % permanent water (dark blue)
];

set(gca,'fontsize',20);

colormap(p0, colors_abs);
hcb = colorbar;
hcb.Title.String = 'm';


lat_range = [39.52 39.92];
lon_range = [-121.53 -121.13];
m_line([lon_range(1) lon_range(2) lon_range(2) lon_range(1) lon_range(1)], ...
       [lat_range(1) lat_range(1) lat_range(2) lat_range(2) lat_range(1)], ...
       'color', [0.5 0 0.5], ...      % Purple
       'linewidth', 2, ...
       'linestyle', '--');

lat_range = [39.95 40.35];
lon_range = [-121.25 -120.85];
m_line([lon_range(1) lon_range(2) lon_range(2) lon_range(1) lon_range(1)], ...
       [lat_range(1) lat_range(1) lat_range(2) lat_range(2) lat_range(1)], ...
       'color', [0.5 0 0.5], ...      % Purple
       'linewidth', 2, ...
       'linestyle', '--');

lat_range = [39.55 39.95];
lon_range = [-120.55 -120.15];
m_line([lon_range(1) lon_range(2) lon_range(2) lon_range(1) lon_range(1)], ...
       [lat_range(1) lat_range(1) lat_range(2) lat_range(2) lat_range(1)], ...
       'color', [0.5 0 0.5], ...      % Purple
       'linewidth', 2, ...
       'linestyle', '--');

lat_range = [39.52 39.92];
lon_range = [-121.53 -121.13];

p1 = subplot('Position', [0.5 0.65 0.13 0.3]);
plot_regional_map(trix, triy, Max_Hs,lat_range, lon_range, 0, maxlevel, 'RDycore (All)', 0, 0,'(b)');
colormap(p1, colors_abs);

p2 = subplot('Position', [0.645 0.65 0.13 0.3]);
plot_regional_map(trix, triy, Max_Hs_3,lat_range, lon_range, 0, maxlevel, 'RDycore (3rd)', 0, 0,'(c)');
colormap(p2, colors_abs);

p3 = subplot('Position', [0.79 0.65 0.13 0.3]);
plot_regional_map(trix, triy, satellite_flood,lat_range, lon_range, 0, maxlevel, 'Satellite (3rd)', 0, 0,'(d)');

colormap(p3, colors_discrete);
hcb = colorbar;
pos(1) = 0.931;               % Change only the 'left' value
pos(2) = 0.66;               % Change only the 'left' value
pos(3) = 0.01;               % Change only the 'left' value
pos(4) = 0.28;               % Change only the 'left' value
set(hcb, 'Position', pos);  % Apply the new position
caxis([-0.5 2.5]);              % Center each color on integer
hcb.Ticks = [0 1 2];            % Discrete ticks
hcb.TickLabels = {'Non-flooded', 'Flooded', 'Permanent \newline Water'};


lat_range = [39.95 40.35];
lon_range = [-121.25 -120.85];

p1 = subplot('Position', [0.5 0.335 0.13 0.3]);
plot_regional_map(trix, triy, Max_Hs,lat_range, lon_range, 0, maxlevel, '', 0, 0,'(e)');
colormap(p1, colors_abs);

p2 = subplot('Position', [0.645 0.335 0.13 0.3]);
plot_regional_map(trix, triy, Max_Hs_3,lat_range, lon_range, 0, maxlevel, '', 0, 0,'(f)');
colormap(p2, colors_abs);

p3 = subplot('Position', [0.79 0.335 0.13 0.3]);
plot_regional_map(trix, triy, satellite_flood,lat_range, lon_range, 0, maxlevel, '', 0, 0,'(g)');

colormap(p3, colors_discrete);
hcb = colorbar;
pos = get(hcb, 'Position');  % Get current position: [left bottom width height]
pos(1) = 0.931;               % Change only the 'left' value
pos(2) = 0.345;               % Change only the 'left' value
pos(3) = 0.01;               % Change only the 'left' value
pos(4) = 0.28;               % Change only the 'left' value
set(hcb, 'Position', pos);  % Apply the new position

caxis([-0.5 2.5]);              % Center each color on integer
hcb.Ticks = [0 1 2];            % Discrete ticks
hcb.TickLabels = {'Non-flooded', 'Flooded', 'Permanent \newline Water'};


lat_range = [39.55 39.95];
lon_range = [-120.55 -120.15];

p1 = subplot('Position', [0.5 0.02 0.13 0.3]);
plot_regional_map(trix, triy, Max_Hs,lat_range, lon_range, 0, maxlevel, '', 0, 0,'(h)');
colormap(p1, colors_abs);

p2 = subplot('Position', [0.645 0.02 0.13 0.3]);
plot_regional_map(trix, triy, Max_Hs_3,lat_range, lon_range, 0, maxlevel, '', 0, 0,'(i)');
colormap(p2, colors_abs);

p3 = subplot('Position', [0.79 0.02 0.13 0.3]);
plot_regional_map(trix, triy, satellite_flood,lat_range, lon_range, 0, maxlevel, '', 0, 0,'(j)');
colormap(p3, colors_discrete);
hcb = colorbar;
caxis([-0.5 2.5]);              % Center each color on integer
hcb.Ticks = [0 1 2];            % Discrete ticks
hcb.TickLabels = {'Non-flooded', 'Flooded', 'Permanent \newline Water'};
pos = get(hcb, 'Position');  % Get current position: [left bottom width height]
pos(1) = 0.931;               % Change only the 'left' value
pos(2) = 0.03;               % Change only the 'left' value
pos(3) = 0.01;               % Change only the 'left' value
pos(4) = 0.28;               % Change only the 'left' value

set(hcb, 'Position', pos);  % Apply the new position


set(gcf, 'Visible', 'on');  
fig = gcf;
set(fig, 'Units', 'inches');
fig_pos = get(fig, 'Position');  % [left bottom width height]

set(fig, 'PaperUnits', 'inches');
set(fig, 'PaperPosition', [0 0 fig_pos(3:4)]);
set(fig, 'PaperSize', fig_pos(3:4));

% Use the same renderer as on screen (OpenGL)
set(fig, 'Renderer', 'painters');

% Save the figure to a file (e.g., PNG)
exportgraphics(gcf, 'spatial_pattern_v1_r.tiff', 'Resolution', 300);
hold off;
close all;