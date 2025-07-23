clc;
clear all;
close all;

% Full path to the shapefile
shapefile = '/Users/haod776/Documents/work/SCIDAC/Hydrodynamic_study/jigsaw_mesh/shape_files/CA_event/CA_buildings_clipped.shp';

% Read the shapefile
S = shaperead(shapefile);

% Initialize containers for lat/lon
lats_b = [];
lons_b = [];

% Loop through each feature
for i = 1:length(S)
    % Extract coordinates
    lon_i = S(i).X;
    lat_i = S(i).Y;
    
    % Remove NaNs (used to separate polygon parts)
    lon_i = lon_i(~isnan(lon_i));
    lat_i = lat_i(~isnan(lat_i));
    
    % Store coordinates (append to arrays)
    lons_b = [lons_b; lon_i(:)];
    lats_b = [lats_b; lat_i(:)];
end

save('building_lat_lon.mat','lons_b','lats_b');
% Plot to verify
figure;
plot(lons, lats, '.');
xlabel('Longitude');
ylabel('Latitude');
title('Building Points from Shapefile');
axis equal;


%% get tryx triy
region_name = 'CA2017';
prj_code = 32610;

[lons_all, lats_all, areas, elevs] = get_trixy_Jigsaw(region_name, prj_code);
lons_all = lons_all';
lats_all = lats_all';


% Step 1: Reshape all triangle vertices into a list of points
all_vertices = [lons_all(:), lats_all(:)];  % Each row: [lon, lat]

% Step 2: Find unique vertices and build index map
[unique_vertices, ~, idx_map] = unique(all_vertices, 'rows');

% Step 3: Build triangle connectivity using indices of unique vertices
num_tri = size(lons_all, 1);
triangles = reshape(idx_map, num_tri, 3);  % Nx3

% Step 4: Create triangulation object
TR = triangulation(triangles, unique_vertices);

% Step 5: Prepare query points
query_pts = [lons, lats];  % Mx2

% Step 6: Locate triangle index for each query point
ti = pointLocation(TR, query_pts);  % Mx1: index into triangles (NaN if outside)

buildingLocs = ti;

save('buildings_Locs.mat','buildingLocs','query_pts');