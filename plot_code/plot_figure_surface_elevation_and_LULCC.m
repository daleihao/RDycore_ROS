clc;
clear all;
close all;

%load('CA_area_mask.mat'); 


region_name = 'CA2017';
prj_code = 32610;

[trix, triy, areas, elevs] = get_trixy_Jigsaw(region_name, prj_code);
load('LUC_2017.mat');

load('latlon_2017.mat');

load("building_lat_lon.mat");

% Define RGB colormap for NLCD codes (simplified)
nlcd_classes = [11 21 22 23 24 31 41 42 43 52 71 81 82 90 95];
nlcd_colors = [ ...
    70 107 159;   % 11: Open Water
   % 209 222 248;  % 12: Perennial Ice/Snow
    222 197 197;  % 21: Developed, Open Space
    217 146 130;  % 22: Developed, Low Intensity
    235 000 000;  % 23: Developed, Medium Intensity
    171 000 000;  % 24: Developed, High Intensity
    179 174 163;  % 31: Barren Land
    104 171  95;  % 41: Deciduous Forest
    28  95  44;   % 42: Evergreen Forest
    181 197 143;  % 43: Mixed Forest
    204 186 124;  % 52: Shrub/Scrub
    223 223 194;  % 71: Grassland/Herbaceous
    220 217 57;   % 81: Pasture/Hay
    171 108 40;   % 82: Cultivated Crops
    181 217 231;  % 90: Woody Wetlands
    209 230 241   % 95: Emergent Herbaceous Wetlands
] / 255;  % Normalize to 0–1 for MATLAB

nlcd_labels = { ...
    'Open Water', ...% 'Perennial Ice/Snow', ...
    'Developed: Open Space', 'Developed: Low Intensity', ...
    'Developed: Medium Intensity', 'Developed: High Intensity', ...
    'Barren Land', ...
    'Deciduous Forest', 'Evergreen Forest', 'Mixed Forest', ...
    'Shrub/Scrub', 'Grassland/Herbaceous', ...
    'Pasture/Hay', 'Cultivated Crops', ...
    'Woody Wetlands', 'Herbaceous Wetlands'};


% 3. Map NLCD class codes to colormap indices
[~, ~, idx] = unique(LUCs);  % Map values to sequential integers
cmap = zeros(max(idx), 3);        % Initialize colormap

tick_locs = [];  % For colorbar ticks
tick_labels = {};  % For colorbar labels

for i = 1:length(nlcd_classes)
    class_val = nlcd_classes(i);
    if any(LUCs(:) == class_val)
        class_index = unique(idx(LUCs == class_val));
        cmap(class_index, :) = nlcd_colors(i, :);
        tick_locs(end+1) = i; %#ok<*SAGROW>
        tick_labels{end+1} = nlcd_labels{i};
    end
end


% Create a new mapped matrix from 1 to 16
landcover_mapped = nan(size(LUCs));  % Use NaN for undefined

for i = 1:length(nlcd_classes)
    landcover_mapped(LUCs == nlcd_classes(i)) = i;
end



%% test

maxlevel = 2500;
figure('Position', [100 100 1250 600]);

p1 = subplot("Position",[0.04 0.05, 0.4 0.9])
plot_global_map_elev(trix, triy, elevs, 0, maxlevel, '', 1, 1,'(a)');



hold on
m_scatter(lons_b, lats_b, 0.001, '.', 'r','MarkerFaceAlpha', 0.01);
%h = m_plot(lons_b, lats_b, 'r.', 'MarkerSize', 0.01, 'MarkerFaceAlpha', 0.1);


% Full path to the shapefile
shapefile = '/Users/haod776/Documents/work/SCIDAC/Hydrodynamic_study/qgis_CA2017/outlet.shp';

S = shaperead(shapefile);


% Loop through each feature
for i = 1:length(S)
    % Extract coordinates
    lon_i = S(i).X;
    lat_i = S(i).Y;
    
    % Remove NaNs (used to separate polygon parts)
    lon_i = lon_i(~isnan(lon_i));
    lat_i = lat_i(~isnan(lat_i));
    
    % Store coordinates (append to arrays)
    m_scatter(lon_i, lat_i,100,'o','k','filled');

end

colormap(p1, flipud(winter))
hcb = colorbar;
hcb.Title.String = 'm';


set(gca,'fontsize',20);

%% plot2
maxlevel = 15;


p2 = subplot("Position",[0.46 0.05, 0.4 0.9])
plot_global_map(trix, triy, landcover_mapped, 1, maxlevel, '', 1, 0,'(b)');
colormap(p2, cmap)

cb = colorbar;
cb.Ticks = tick_locs;
cb.TickLabels = tick_labels;
cb.TickLength = 0;
cb.FontSize = 15;
cb.Location = 'eastoutside';

h = findall(cb, 'Type', 'Text');
for i = 1:length(h)
    h(i).Rotation = 1999;  
end


caxis([0.5 15.5]); 

set(gca,'fontsize',20);


set(gcf, 'Visible', 'on');  
fig = gcf;
set(fig, 'Units', 'inches');
fig_pos = get(fig, 'Position');  % [left bottom width height]

set(fig, 'PaperUnits', 'inches');
set(fig, 'PaperPosition', [0 0 fig_pos(3:4)]);
set(fig, 'PaperSize', fig_pos(3:4));

% Use the same renderer as on screen (OpenGL)
set(gcf, 'Renderer', 'painters');

% Save the figure to a file (e.g., PNG)
exportgraphics(gcf, 'surface_elevation_r.tiff', 'Resolution', 300);
hold off;
close all;