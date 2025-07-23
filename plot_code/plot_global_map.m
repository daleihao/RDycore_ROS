function plot_global_map(trix,triy, maxWH_all, min_clr, max_clr, title_text, isxticklabel, isyticklabel,num_label)
axis equal

m_proj('miller','lat',[38.595 40.515],'lon',[-121.6 -119.97]); % robinson Mollweide

%m_coast('color','k','linewidth',1);
hold on


if isyticklabel && isxticklabel
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], ...
        'fontsize',15,'tickstyle','dd','xtick',4,'ytick',4);
elseif isyticklabel && ~isxticklabel
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], 'xticklabels',[], ...
        'fontsize',15,'tickstyle','dd','xtick',4,'ytick',4);
elseif ~isyticklabel && isxticklabel
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], 'yticklabels',[], ...
        'fontsize',15,'tickstyle','dd','xtick',4,'ytick',4);
else
    m_grid('tickdir','out','linestyle','none','backcolor',[.9 .99 1], 'xticklabels',[], 'yticklabels',[], ...
        'fontsize',15,'tickstyle','dd','xtick',4,'ytick',4);
end


%%
% load('elevations_TP.mat');
% sw_total(elevations<=1500 | isnan(elevations)) = nan;

%m_pcolor(mean(trix),mean(triy),maxWH_all);%,'LineStyle','none');

[x, y] = m_ll2xy(trix, triy);
patch(x,y,maxWH_all,'LineStyle','none');





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



shading flat;

caxis([min_clr-1e-5,max_clr+1e-5])
%colormap(m_colmap('jet','step',10));
m_text(-120.1,40.45,num_label,'fontsize',20,'fontweight','bold');
%colorbar
%colormap(colors_single);

if title_text ~= ""
    t = title(title_text,'fontsize',20, 'fontweight', 'bold');
    set(t, 'horizontalAlignment', 'left');
    set(t, 'units', 'normalized');
    h1 = get(t, 'position');
    set(t, 'position', [0 h1(2) h1(3)]);
end

set(gca, 'FontName', 'Time New Roman');

view(0,90);
hold off