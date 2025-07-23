clc;
clear all;
close all;

prj_code = 32610;
dof = 3;

% Read CSV file
filename = 'all_CA_sites_new.csv';
data = readtable(filename);

% Extract Latitude, Longitude, and SiteID
lats = data.Latitude;
lons = data.Longitude;
siteIDs = data.SiteID;
elevs = data.Elevation;
siteNum = length(lats);

point_xs = nan(siteNum,1);
point_ys = nan(siteNum,1);
for gage_i = 1:siteNum

    lat_p = lats(gage_i);
    lon_p = lons(gage_i);


    proj        = projcrs(prj_code);
    [point_x,point_y]       = projfwd(proj,lat_p,lon_p);

point_xs(gage_i) = point_x;
point_ys(gage_i) = point_y;
    
end

save('gages_xyz.mat','point_xs','point_ys','elevs','lats','lons','siteIDs');