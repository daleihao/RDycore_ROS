function plot_global_map_site_ref2(lons,lats,lons2,lats2, Rs, Rs2, min_clr, max_clr, title_text, isxticklabel, isyticklabel,num_label)
axis equal

m_proj('miller','lat',[38.5 40.6],'lon',[-121.8 -119.8]); % robinson Mollweide

%m_coast('color','k','linewidth',1);
hold on


if isyticklabel && isxticklabel
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], ...
        'fontsize',12,'tickstyle','dd','xtick',4,'ytick',4);
elseif isyticklabel && ~isxticklabel
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], 'xticklabels',[], ...
        'fontsize',12,'tickstyle','dd','xtick',4,'ytick',4);
elseif ~isyticklabel && isxticklabel
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], 'yticklabels',[], ...
        'fontsize',12,'tickstyle','dd','xtick',4,'ytick',4);
else
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], 'xticklabels',[], 'yticklabels',[], ...
        'fontsize',12,'tickstyle','dd','xtick',4,'ytick',4);
end


%%
% load('elevations_TP.mat');
% sw_total(elevations<=1500 | isnan(elevations)) = nan;

%m_pcolor(mean(trix),mean(triy),maxWH_all);%,'LineStyle','none');

%[x, y] = m_ll2xy(trix, triy);
h = m_scatter(lons, lats, 100, Rs, 'o', 'filled');
h = m_scatter(lons2, lats2, 100, Rs2, 'o', 'filled','MarkerEdgeColor', 'r', 'LineWidth', 2);


hold on

filename = 'Basin_border/sierra_hwbasins';
basins =m_shaperead(filename);

tmp = basins.ncst;
for k=2:4
    tmp_2 = tmp{k};
    if k==2
        tmp_2 = tmp_2(1:13769,1:2);
    end
    basin_plot = m_line(tmp_2(:,1),tmp_2(:,2),'color','k','linewidth',1);
end


% river
Rivers = shaperead('../../jigsaw_mesh/shape_files/CA_event/Rivers');
for i = 1 : length(Rivers)
    xr = Rivers(i).X(1:end-1);
    yr = Rivers(i).Y(1:end-1);
    m_plot(xr,yr,'k-','LineWidth',0.5,'Color',[0.5 0.5 0.5]); hold on;

end

shading flat;

caxis([min_clr-1e-5,max_clr+1e-5])
%colormap(m_colmap('jet','step',10));
m_text(-121.75,38.60,num_label,'fontsize',18,'fontweight','bold');
%colorbar
%colormap(colors_single);

if title_text ~= ""
    t = title(title_text,'fontsize',12, 'fontweight', 'bold');
    set(t, 'horizontalAlignment', 'left');
    set(t, 'units', 'normalized');
    h1 = get(t, 'position');
    set(t, 'position', [0 h1(2) h1(3)]);
end

set(gca, 'FontName', 'Time New Roman');

view(0,90);
hold off