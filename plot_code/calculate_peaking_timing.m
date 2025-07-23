%%
if(~exist('peaking_timing.mat','file'))
    Daily_MaxH = zeros(17693051,52,'int32');
    Daily_PeakT = zeros(17693051,52,'int32');
    t = 1;
    for day_i = [6:57]

        load(['../spatial/Rdycore_2017_water_height_day_' num2str(day_i) '.mat']);
        [Daily_MaxH(:,t), Daily_PeakT(:,t)] = max(Height_Rdycores,[],2);
        t = t+1;
    end

    [Max_Hs, Max_Ts]= max(Daily_MaxH,[],2);

    nGrid = size(Daily_PeakT, 1);
    indices = sub2ind(size(Daily_PeakT), (1:nGrid)', Max_Ts);
    Peak_Ts = Daily_PeakT(indices);

    save('peaking_timing.mat','Peak_Ts','Max_Ts')
else
    load('peaking_timing.mat');
end
