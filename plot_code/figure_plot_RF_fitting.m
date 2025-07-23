clc;
clear all;
close all;

load('RF_estimated.mat');
%% plot
% === 3. Plot results ===
figure('Position', [200, 100, 500, 500]);

% Compute R² and RMSE
R2 = 1 - sum((y - y_pred).^2) / sum((y - mean(y)).^2);
RMSE = sqrt(mean((y - y_pred).^2));

densityscatter(y,y_pred,100,5);


grid on; axis equal;
xlim([min(y) max(y)]);
ylim([min(y) max(y)]);
refline(1,0); % 1:1 line

% Show R² and RMSE
text(0.5, 20*0.96, sprintf('R^2 = %.2f', R2), 'FontSize', 20, 'VerticalAlignment', 'top');
text(0.5, 20*0.85, sprintf('RMSE = %.2f m', RMSE), 'FontSize', 20, 'VerticalAlignment', 'top');

xlabel('Observed maximum water height (m)');
ylabel('Predicted maximum water height (m)');

grid off; axis equal;
xlim([0 20]);
ylim([0 20]);
refline_obj = refline(1,0); % 1:1 line
refline_obj.Color = 'k';           % Set color to black
refline_obj.LineWidth = 2;         % Set line width to 1
set(gca,'linewidth',1,'fontsize',18)




%% Save the figure to a file (e.g., PNG)
exportgraphics(gcf, 'RF_modeling_RMSE.tiff', 'Resolution', 300);
hold off;
close all;
