function [trixs, triys,areas, elevs] = get_trixy_Jigsaw(region_name, prj_code)

tag = [region_name '_jigsaw_30m'];

input_dir = '/Users/haod776/Documents/work/SCIDAC/Hydrodynamic_study/jigsaw_mesh/script/meshes';

%% read coordinate info
x = ncread([input_dir '/' tag '.exo'],'coordx');
y= ncread([input_dir '/' tag '.exo'],'coordy');
z = ncread([input_dir '/' tag '.exo'],'coordz');

x = x';
y = y';
z = z';
connect1 = ncread([input_dir '/' tag '.exo'],'connect1') ;
areas = polyarea(x(connect1),y(connect1));
areas = areas';
elevs = mean(z(connect1)',2);
trix = x(connect1);
triy = y(connect1);

proj        = projcrs(prj_code);
[triys,trixs] = projinv(proj,trix,triy);


