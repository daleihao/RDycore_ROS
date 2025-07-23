clc;
clear all;
close all;

addpath '/global/cfs/cdirs/m4267/Dalei/RDycore/input/CA2017_jigsaw_30m/code'
cd /global/cfs/cdirs/m4267/Dalei/RDycore/input/CA2017_jigsaw_30m

case_name = 'CA2017_jigsaw_30m';

x = ncread(['./' case_name '.exo'],'coordx');
y = ncread(['./' case_name '.exo'],'coordy');
z = ncread(['./' case_name '.exo'],'coordz');

x = x';
y = y';
z = z';

connect1    = ncread(['./' case_name '.exo'],'connect1');

trixs = x(connect1);
triys = y(connect1);
trizs = z(connect1);

load('./code/gages_xy.mat');

[Height_Rdycores, SurfaceElevs] = extract_water_level(trixs,triys,trizs, point_xs, point_ys, 500);

save(['gage_height_Rdycore_500m_v3.mat'],"Height_Rdycores", "SurfaceElevs");

%m2ft = 3.28084;
[Height_Rdycores, SurfaceElevs] = extract_water_level(trixs,triys,trizs, point_xs, point_ys, 200);

save(['gage_height_Rdycore_200m_v3.mat'],"Height_Rdycores", "SurfaceElevs");

[Height_Rdycores, SurfaceElevs] = extract_water_level(trixs,triys,trizs, point_xs, point_ys, 100);

save(['gage_height_Rdycore_100m_v3.mat'],"Height_Rdycores", "SurfaceElevs");