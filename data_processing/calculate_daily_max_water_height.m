clc;
clear all;
close all;

Daily_MaxH = zeros(17693051,13,'int32');
t = 1;
for day_i = [6:11 36:42]

    load(['Rdycore_water_height_day_' num2str(day_i) '.mat']);
    Daily_MaxH(:,t) = max(Height_Rdycores,[],2);
    t = t+1;
end

save("Rdycore_Daily_MaxH.mat",'Daily_MaxH');


%% event 1

Daily_MaxH = zeros(17693051,7,'int32');
Daily_InuT = zeros(17693051,7,'int32');
t = 1;
for day_i = [36:42]

    load(['Rdycore_water_height_day_' num2str(day_i) '.mat']);
    Daily_MaxH(:,t) = max(Height_Rdycores,[],2);
    Daily_InuT(:,t) = sum(double(Height_Rdycores)/1000>0.12, 2);
    t = t+1;
end

save("Rdycore_Daily_all_CA_Feb.mat",'Daily_MaxH',"Daily_InuT");

%% event Jan
Daily_MaxH = zeros(17693051,7,'int32');
Daily_InuT = zeros(17693051,7,'int32');
t = 1;
for day_i = [6:12]

    load(['Rdycore_water_height_day_' num2str(day_i) '.mat']);
    Daily_MaxH(:,t) = max(Height_Rdycores,[],2);
    Daily_InuT(:,t) = sum(double(Height_Rdycores)/1000>0.12, 2);
    t = t+1;
end

save("Rdycore_Daily_all_CA_Jan.mat",'Daily_MaxH',"Daily_InuT");
