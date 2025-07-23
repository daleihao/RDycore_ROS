clc;
clear all;
close all;

% Load grid coordinates
region_name = 'CA2017';
prj_code = 32610;
[trix, triy, areas, elevs] = get_trixy_Jigsaw(region_name, prj_code);

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

% Set data path and file pattern
dataDir = '/Users/haod776/Documents/work/SCIDAC/Hydrodynamic_study/writing/code/spatial';
fileList = dir(fullfile(dataDir, 'Rdycore_2017_water_height_day_*.mat'));
nFiles = length(fileList);

% Plot settings
vmin = 0;      % Adjust based on your water height range
vmax = 2;
save_gif = true;
gif_filename = 'flood_hourly_animation.gif';

%% plot
% Create figure
figure('Position', [100 100 800 700]);
frame_count = 1;


% Loop over all files
for f = 39:nFiles
    % Load file

   
    filePath = fullfile(dataDir, fileList(f).name);
    load(filePath);  % Should load 'water_height' or similar

    % Check variable name
    whos

    % Replace 'water_height' with actual variable name if different
    for hour_i = 1:4:24
       clf

      
        current_map = Height_Rdycores(:,hour_i);  % Adjust if variable is named differently
        current_map = double(current_map)/1000;

        trisurf(connect1', x', y', z', current_map, 'EdgeColor','none');
      view(2); colorbar;

       % plot_global_map(trix, triy, current_map, vmin, vmax, 'RDycore', 1, 1, '');
       % patch(trix,triy,current_map,'LineStyle','none');

       caxis([0 5])

        title(['Flooded Area - Day ', num2str(f - 1), ' Hour ', num2str(hour_i - 1)], 'FontSize', 14);

        colorbar
      %  pause(0.01)
       drawnow;

%         % Save as GIF
%         if save_gif
%             frame = getframe(gcf);
%             im = frame2im(frame);
%             [imind, cm] = rgb2ind(im, 256);
%             if frame_count == 1
%                 imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.15);
%             else
%                 imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.15);
%             end
%             frame_count = frame_count + 1;
%         end
    end
end
