function [trix, triy] = get_trixy_Jigsaw(region_name, prj_code)

tag = [region_name '_jigsaw_30m'];

input_dir = '/Users/haod776/Documents/work/SCIDAC/Hydrodynamic_study/jigsaw_mesh/script/meshes';

%% read coordinate info
x = ncread([input_dir '/' tag '.exo'],'coordx');
y= ncread([input_dir '/' tag '.exo'],'coordy');

x = x';
y = y';
connect1 = ncread([input_dir '/' tag '.exo'],'connect1') ;

trix = x(connect1);
triy = y(connect1);

proj        = projcrs(prj_code);
[triy,trix] = projinv(proj,trix,triy);


