function [Height_Rdycores, SurfaceElevs] = extract_water_level(trixs,triys,trizs, point_xs, point_ys,thresholds)

centriod_x = mean(trixs,1);
centriod_y = mean(triys,1);
centriod_z = mean(trizs,1);
siteNum = length(point_xs);

Height_Rdycores = cell(siteNum, 1);
SurfaceElevs = cell(siteNum, 1);

for gage_i = 1:siteNum
    Height_Rdycores{gage_i} = [];
end

for day_i = 0:57
    Rdycore_filename = ['./CA_output_dt_0_25s_2017/CA2017.CriticalOutFlowBC_jigsaw_withrain_2month_long_dt_0_25s_pm_2017-' num2str(day_i,'%02d') '.h5'];
    fileinfo = h5info(Rdycore_filename);

    disp(['Day: ' num2str(day_i)])
    tic;

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


    for hour_i = 1:24
        groupname = sorted_groups{hour_i};
        Height_Rdycore = h5read(Rdycore_filename,['//' groupname '/Height']);

        for gage_i = 1:siteNum
            point_x = point_xs(gage_i);
            point_y = point_ys(gage_i);
            
            distances = sqrt((point_x - centriod_x).^2 + (point_y - centriod_y).^2);
            filters = distances<thresholds;

            Height_Rdycore_filter = Height_Rdycore(filters);
            elev_filters = centriod_z(filters);
         
            Height_Rdycores{gage_i} = [Height_Rdycores{gage_i} Height_Rdycore_filter(:)];
            SurfaceElevs{gage_i} = [SurfaceElevs{gage_i} elev_filters(:)];
            
        end
    end
    toc
end

end