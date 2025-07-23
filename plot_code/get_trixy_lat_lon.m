function [lon, lat,z, connect1] = get_trixy_lat_lon(region_name, prj_code)

tag = [region_name '_jigsaw_30m'];

input_dir = '/Users/haod776/Documents/work/SCIDAC/Hydrodynamic_study/jigsaw_mesh/script/meshes';

%% read coordinate info
x = ncread([input_dir '/' tag '.exo'],'coordx');
y= ncread([input_dir '/' tag '.exo'],'coordy');
z = ncread([input_dir '/' tag '.exo'],'coordz');

connect1 = ncread([input_dir '/' tag '.exo'],'connect1') ;

connect1 = connect1';
proj        = projcrs(prj_code);
[lat,lon] = projinv(proj,x,y);


