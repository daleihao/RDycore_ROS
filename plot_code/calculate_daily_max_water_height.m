
%% event Jan
if(~exist('daily_values_all.mat','file'))
    Daily_MaxH = zeros(17693051,52,'int32');
    Daily_InuT = zeros(17693051,52,'int32');
    t = 1;
    for day_i = [6:57]

        load(['../spatial/Rdycore_2017_water_height_day_' num2str(day_i) '.mat']);
        Daily_MaxH(:,t) = max(Height_Rdycores,[],2);
        Daily_InuT(:,t) = sum(double(Height_Rdycores)/1000>0.12, 2);
        t = t+1;
    end
else
load('daily_values_all.mat');
end

Pre_H = zeros(17693051,1,'int32');
for day_i = [5]

    load(['../spatial/Rdycore_2017_water_height_day_' num2str(day_i) '.mat']);
    Pre_H(:,1) = Height_Rdycores(:,end);
end
