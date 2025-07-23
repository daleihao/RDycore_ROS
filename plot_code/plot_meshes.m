clc;
clear all;
close all;

region_name = 'CA2017';
prj_code = 32610;

[lons_all, lats_all, zs_all, connect_all] = get_trixy_lat_lon(region_name, prj_code);

lat_ranges = [
    39.52 39.92;
    39.95 40.35;
    39.55 39.95
    ];

lon_ranges = [
    -121.53 -121.13;
    -121.25 -120.85;
    -120.55 -120.15
    ];

Rivers = shaperead('../../../jigsaw_mesh/shape_files/CA_event/Rivers');
ordthr = 12;

fig4 = figure;
set(fig4, 'Position', [10, 10, 900, 300]);

labels = {'(a)', '(b)', '(c)'};

for iSub = 1:3

   subplot("Position",[0.04+(iSub-1)*0.33 0.07, 0.26 0.88])

    lat_range = lat_ranges(iSub,:);
    lon_range = lon_ranges(iSub,:);

    % Step 1: Find node indices within bounding box
    inside_idx = find(...
        lats_all >= lat_range(1) & lats_all <= lat_range(2) & ...
        lons_all >= lon_range(1) & lons_all <= lon_range(2));

   

    % Step 3: Filter triangles: all 3 nodes must be inside
    in1 = ismember(connect_all(:,1), inside_idx);
    in2 = ismember(connect_all(:,2), inside_idx);
    in3 = ismember(connect_all(:,3), inside_idx);
    mask_tri = in1 | in2 | in3;
    connect_sub = connect_all(mask_tri,:);

 
    % Step 4: Remap connect indices to local node indices

    % Step 5: Extract local node coordinates

    % Plot the filtered mesh
    h = trisurf(connect_sub, lons_all, lats_all, zs_all);
    demcmap([   min(zs_all(inside_idx)) max(zs_all(inside_idx))]); view(2); hold on;

    axis equal
    % Plot rivers
    for i = 1:length(Rivers)
        if Rivers(i).ORD_FLOW <= ordthr
            xr = Rivers(i).X(1:end-1);
            yr = Rivers(i).Y(1:end-1);
            plot3(xr, yr, ones(length(xr),1)*3000, 'b-', 'LineWidth', 1.5);
        end
    end

    xlim(lon_range); ylim(lat_range);
  %  title(sprintf('Region %d', iSub), 'FontSize', 14, 'FontWeight', 'bold');

     t = title(labels{iSub}, 'FontSize', 14, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left');
    
    % Shift title a bit left inside the axis
    pos = get(t, 'Position');
    % Move title left a bit by decreasing X position (pos(1))
    pos(1) = min(xlim) + 0.01*(max(xlim)-min(xlim)); 
    % Optionally, adjust Y position (pos(2)) if needed
    set(t, 'Position', pos);

        cb = colorbar;
    cb.Title.String = 'm';
    cb.Title.Rotation = 0;

end

print(gcf, 'mesh_show.png', '-dpng', '-r300');
% Save the figure to a file (e.g., PNG)
exportgraphics(fig4, 'mesh_show.png', 'Resolution', 300);
hold off;
close all;
