clc;
clear all;
close all;

cd /global/cfs/cdirs/m4267/Dalei/RDycore/input/CA2017_jigsaw_30m

for day_i = 0:57
    Rdycore_filename = ['./CA_output_dt_0_25s_2017/CA2017.CriticalOutFlowBC_jigsaw_withrain_2month_long_dt_0_25s_pm_2017-' num2str(day_i,'%02d') '.h5'];
    fileinfo = h5info(Rdycore_filename);

    % Initialize
    group_names = {};
    time_values = [];

    % Loop through all groups
    for i = 1:length(fileinfo.Groups)
        gname = fileinfo.Groups(i).Name;

        % Skip non-time groups like '/Domain' and '/fields'
        if contains(gname, 'Domain') || contains(gname, 'fields')
            continue;
        end

        % Extract leading number from group name
        tokens = regexp(gname, '/(\d+)\s', 'tokens');
        if ~isempty(tokens)
            group_names{end+1} = gname;
            time_values(end+1) = str2double(tokens{1}{1});
        end
    end

    % Sort groups by extracted time
    [~, sorted_idx] = sort(time_values);
    sorted_groups = group_names(sorted_idx);


    disp(['Day: ' num2str(day_i)])
    tic;


    Height_Rdycores = zeros(17693051, 24, 'int32');
    for hour_i = 1:length(sorted_groups)
        groupname = sorted_groups{hour_i};
        Height_Rdycore = h5read(Rdycore_filename,['//' groupname '/Height']);

        Height_Rdycores(:,hour_i) = int32(Height_Rdycore*1000);

    end
    save(['Rdycore_2017_water_height_day_' num2str(day_i) '.mat'], 'Height_Rdycores');
    toc
end
