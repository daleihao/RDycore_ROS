clc;
clear all;
close all;





% Initialize figure
figure; hold on;

% Set figure size and position
figure_position = [100, 100, 800, 600];  % [left, bottom, width, height]
set(gcf, 'Position', figure_position);

% Set line width and font size for clarity
line_width = 2;
font_size = 20;

% Define shading regions
shade_color = [0.9, 0.9, 0.9]; % Light gray
jan_start = datetime(2017,1,7,0,0,0, 'TimeZone', 'America/Los_Angeles');
jan_end   = datetime(2017,1,12,23,59,59, 'TimeZone', 'America/Los_Angeles');
feb_start = datetime(2017,2,6,0,0,0, 'TimeZone', 'America/Los_Angeles');
feb_end   = datetime(2017,2,12,23,59,59, 'TimeZone', 'America/Los_Angeles');

%% plot 
colors = {'r','g','b','k'};
colors = {[0, 114, 178]/255, ... % Blue
          [213, 94, 0]/255,   ... % Vermilion (Orange-Red)
          [0, 158, 115]/255,  ... % Teal (Greenish)
          [204, 121, 167]/255};   % Reddish-Purple

for gage_i = 1:4

    load(['USGS_gage_height_' num2str(gage_i) '.mat']);

    hourMeanHeights = hourlyMeanHeights((4*24+1-8):((4*24+1-8)+1295));
    hourlytime = hourlytime((4*24+1-8):((4*24+1-8)+1295));
    load(['gage_height_' num2str(gage_i)  '.mat']);

    RMSEs = nan(45853,1);
    for i = 1:45853
        waterlevels_i = waterlevels(i,:)';
        RMSEs(i) = sqrt(mean((hourMeanHeights-waterlevels_i).^2,"all",'omitnan'));
    end

    index = find(RMSEs==min(RMSEs));
  h1 =   plot(hourlytime,waterlevels(index,:)','--','Color',colors{gage_i}, 'LineWidth', line_width);

  h2 =   plot(hourlytime, hourMeanHeights, '-','Color',colors{gage_i},'LineWidth', line_width);
    
    

    validIdx = ~isnan(waterlevels(index,:)') & ~isnan(hourMeanHeights);
R = corr(waterlevels(index,validIdx)', hourMeanHeights(validIdx), 'Rows', 'complete');


    text(hourlytime(500), 20-gage_i*1.1, ['R = ', num2str(R, '%.2f')], 'FontSize', 30, 'Color', colors{gage_i});


end

% Shade the background for selected periods AFTER site data
y_limits = ylim; % Get dynamic y-axis limits based on data
fill([jan_start jan_end jan_end jan_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
fill([feb_start feb_end feb_end feb_start], [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], ...
    shade_color, 'EdgeColor', 'none', 'FaceAlpha', 0.3);

legend([h1, h2], {'Rdycore', 'Benchmark'}, 'Location', 'best');

% Format plot for better clarity
xlabel('Date', 'FontSize', font_size, 'FontWeight', 'bold');
ylabel('Gage Height (feet)', 'FontSize', font_size, 'FontWeight', 'bold');
%title('Gage Heights for Multiple Sites', 'FontSize', font_size, 'FontWeight', 'bold');
%legend(plot_handles, legend_entries, 'Location', 'best', 'FontSize', font_size);
%grid on;
box on;

% Set axes properties
ax = gca;
ax.FontSize = font_size;
ax.LineWidth = 1.5;

% Save the figure to a file (e.g., PNG)
saveas(gcf, 'gage_heights_multiple_sites.png');

hold off;
