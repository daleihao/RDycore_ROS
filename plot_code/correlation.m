clc;
clear all;
close all;

%load('CA_area_mask.mat'); 
load("accumulated_rainrunoff.mat");
calculate_daily_max_water_height;

Max_Hs = double(max(Daily_MaxH,[],2))/1000;
%Max_Hs = double(mean(double(Daily_MaxH),2))/1000;
Pre_H = double(Pre_H)/1000;
load('LUC_2017.mat');

load('latlon_2017.mat');
load('meanslope.mat');
%% 
filters_LUC = LUCs>12;

filters = Max_Hs>0.12 & ~isnan(meanRunoff) & Pre_H<0.12 & filters_LUC;
%filters = ~isnan(meanRunoff);
corrcoef(Max_Hs(filters),elevs(filters))

corrcoef(Max_Hs(filters),meanslope(filters))

corrcoef(Max_Hs(filters),meanRAIN(filters))

corrcoef(Max_Hs(filters),meanRunoff(filters))


%% plot 

% Assuming elevation, runoff, and inundation_depth are 1D arrays of the same length
% elevation = [...];        % e.g. in meters
% runoff = [...];           % e.g. in mm/day
% inundation_depth = [...]; % e.g. in meters
runoff = meanRunoff(filters);
elevation = meanslope(filters);
inundation_depth = Max_Hs(filters);
% Remove NaNs (if any)
valid = ~isnan(elevation) & ~isnan(runoff) & ~isnan(inundation_depth);
elevation = elevation(valid);
runoff = runoff(valid);
inundation_depth = inundation_depth(valid);


% Define bin edges
numBins = 30; % adjust for resolution
elev_edges = linspace(min(elevation), max(elevation), numBins+1);
runoff_edges = linspace(min(runoff), max(runoff), numBins+1);

% Prepare bin centers for plotting
elev_centers = (elev_edges(1:end-1) + elev_edges(2:end)) / 2;
runoff_centers = (runoff_edges(1:end-1) + runoff_edges(2:end)) / 2;

% Initialize 2D matrix to hold mean inundation depth
mean_inun = nan(numBins, numBins);
counts = zeros(numBins, numBins);

% Loop through bins
for i = 1:numBins
    for j = 1:numBins
        % Find points in this bin
        inBin = elevation >= elev_edges(i) & elevation < elev_edges(i+1) & ...
                runoff >= runoff_edges(j) & runoff < runoff_edges(j+1);
        
        % Compute mean inundation depth
        if any(inBin)
            mean_inun(j,i) = mean(inundation_depth(inBin)); % note: j,i for image alignment
            counts(j,i) = sum(inBin); % optional: for masking sparse bins
        end
    end
end

% Plot as image
figure;
imagesc(elev_centers, runoff_centers, mean_inun);
set(gca, 'YDir', 'normal'); % so runoff increases upward
xlabel('Elevation (m)');
ylabel('Runoff (mm/day)');
title('Binned Mean Inundation Depth');
colorbar;
colormap jet;
caxis([ 0 1])