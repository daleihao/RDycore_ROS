clc;
clear;
close all;

% Load site information
filename = 'all_CA_sites.csv';
data = readtable(filename);

siteIDs = data.SiteID;
siteNum = length(siteIDs);

% Predefine the hourly time vector length (e.g. 1418 hours)
% You may want to load the first file to get exact size or define it here explicitly
numHours = 1418;  % Adjust this according to your hourly time vector length

% Initialize matrix to store mean values for all sites
% Each column is one site, rows correspond to hourly times
USGS_gage_heights = NaN(numHours, siteNum);

% Folder where the hourly files are stored
dataFolder = './all_processed_hourly/';

for i = 1:siteNum
    siteID_str = siteIDs{i};
    filePath = fullfile(dataFolder, [siteID_str, '_hourly.txt']);
    
    if ~isfile(filePath)
        warning('File %s does not exist.', filePath);
        continue;
    end
    
    % Read the hourly file
    opts = detectImportOptions(filePath, 'Delimiter', '\t');
    % Make sure Hour is read as datetime
    opts = setvartype(opts, 'Hour', 'datetime');
    T = readtable(filePath, opts);
    
    % Extract MeanValue
    % If the table doesn't have the right length, we handle it by filling NaN
    nRows = height(T);
    if nRows ~= numHours
        warning('File %s has %d rows, expected %d. Filling missing with NaN.', ...
            filePath, nRows, numHours);
    end
    
    % Initialize column with NaN
    colValues = NaN(numHours,1);
    len = min(nRows, numHours);
    colValues(1:len) = T.MeanValue(1:len);
    
    USGS_gage_heights(:, i) = colValues;
end

% allMeanValues is now a [numHours x siteNum] matrix with the data

save('gage_measurements_all.mat', 'USGS_gage_heights');