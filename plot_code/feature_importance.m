clc;
clear all;
close all;

% Load data
load("accumulated_rainrunoff.mat");   % meanRunoff, meanRAIN, Daily_MaxH, Pre_H
calculate_daily_max_water_height;
load('LUC_2017.mat');                 
load('latlon_2017.mat');
load('meanslope.mat');                

% Max water height (in meters)
Max_Hs = double(max(Daily_MaxH,[],2)) / 1000;
Pre_H = double(Pre_H) / 1000;

% Base variables
elevations = elevs;
slope = meanslope;
%floodedarea = Max_Hs > 0.12 & Pre_H <=0.12;

filters =  (LUCs>12) & (LUCs < 90) & Pre_H <=0.12; %floodedarea;%

landcover_cat = categorical(LUCs);
% Assume these are all column vectors of the same size (N x 1)
%X = [elevations, slope, meanRAIN, meanRunoff, landcover_cat]; % Predictors
y = Max_Hs;                                      % Response variable
X = table(elevations, slope, meanRunoff, landcover_cat); % Predictors

X = X(filters,:);
y = y(filters);


% Random forest regression
%Mdl = TreeBagger(100, X, y, 'Method', 'regression', 'OOBPrediction', 'On', 'OOBPredictorImportance', 'On');
% Define base learner (decision tree)
t = templateTree();

tic;
% Fit Random Forest with hyperparameter optimization
% Mdl = fitrensemble(X, y, ...
%     'Method', 'Bag', ...
%     'Learners', t, ...
%     'OptimizeHyperparameters', {'NumLearningCycles', 'MinLeafSize', 'MaxNumSplits'}, ...
%     'HyperparameterOptimizationOptions', struct( ...
%         'AcquisitionFunctionName', 'expected-improvement-plus', ...
%         'MaxObjectiveEvaluations', 30));                 % <- Optional: speeds it up if Parallel Toolbox is available
% Create a random forest regression model
numTrees = 500;         % Number of trees in the forest
minLeafSize = 5;        % Minimum number of observations per leaf

Mdl = TreeBagger(numTrees, X, y, ...
    'Method', 'regression', ...
    'MinLeafSize', minLeafSize, ...
    'OOBPrediction', 'On', ...
    'OOBPredictorImportance', 'On');

toc;

% Plot importance
% Predict
y_pred = predict(Mdl, X);

% Get predictor importance
importance = Mdl.OOBPermutedPredictorDeltaError;

% Create predictor labels
%n_landcover = size(X_landcover, 2);
%landcover_labels = strcat('LC', string(1:n_landcover));
%predictor_names = ["elev", "slope", "rain", "runoff", landcover_labels];
predictor_names = ["elev", "slope", "runoff",'LC'];


% Normalize importance to relative importance (percentage)
relImportance = importance / sum(importance) * 100;

% Sort importance descending
[sortedImportance, sortIdx] = sort(relImportance, 'descend');
sortedNames = predictor_names(sortIdx);

% Right subplot: Variable Importance (vertical)
% Right subplot: Variable Importance (horizontal bar with feature names on y-axis)
subplot(1,2,2);
barh(sortedImportance);  % 横向条形图
xlabel('Relative Importance (%)');
title('Relative Predictor Importance (Random Forest)');
yticks(1:length(sortedImportance));
yticklabels(sortedNames);
grid on;
set(gca, 'YDir', 'reverse');

%%


figure('Position', [100, 100, 1000, 400]);

% Compute R² and RMSE
R2 = 1 - sum((y - y_pred).^2) / sum((y - mean(y)).^2);
RMSE = sqrt(mean((y - y_pred).^2));

% Left subplot: Observed vs Predicted
subplot(1,2,1);
densityscatter(y,y_pred,100,5);

xlabel('Observed');
ylabel('Predicted');

grid on; axis equal;
xlim([min(y) max(y)]);
ylim([min(y) max(y)]);
refline(1,0); % 1:1 line

% Show R² and RMSE
text(min(y), max(y)*0.95, sprintf('R^2 = %.2f', R2), 'FontSize', 10, 'VerticalAlignment', 'top');
text(min(y), max(y)*0.88, sprintf('RMSE = %.2f', RMSE), 'FontSize', 10, 'VerticalAlignment', 'top');
