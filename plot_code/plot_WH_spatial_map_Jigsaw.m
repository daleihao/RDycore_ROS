clc;
clear all;
close all;

region_name = 'CA2017';
prj_code = 32610;


%% fiure
res_v = 0.01;
res_h = 0.01;

lon = (-122+res_h/2):res_h: (-119-res_h/2);
lat = (41-res_v/2):-res_v: (38 + res_v/2);

[lons,lats]=meshgrid(lon,lat);

load("cmaps.mat");
colors_abs = cmaps.NEO_modis_lst;
colors_delta = cmaps.NEO_modis_lst_anom;

[trix, triy] = get_trixy_Jigsaw(region_name, prj_code);


Rdycore_filename = 'CA2017.CriticalOutFlowBC_jigsaw_withrain_2month_long_dt_0_25s_pm-58.h5';
fileinfo = h5info(Rdycore_filename);
groupname = fileinfo.Groups(1).Name;
Height_Rdycore = h5read(Rdycore_filename,['//' groupname '/Height']);


figure;
plot_global_map(trix, triy, Height_Rdycore, 0, 1, 'RDycore', 1, 1,'');
colormap(colors_abs);


hcb = colorbar;
hcb.Title.String = "m";
