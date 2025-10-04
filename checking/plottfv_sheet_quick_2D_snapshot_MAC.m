clear ; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\';

WQfile=[inDir,'tests_PH_map_light2_v2_WQ.nc'];

dat = tfv_readnetcdf(WQfile,'time',1);
timesteps_WQ = dat.Time;


%%

dat = tfv_readnetcdf(WQfile,'timestep',1);
clear funcions

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

surf_cells=dat.idx3(dat.idx3 > 0);
bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cells(length(dat.idx3)) = length(dat.idx3);
clip_depth=0.05;

first_plot = 1;

img_dir = '.\animation_MAC_map_light2_v2\';

if ~exist(img_dir,'dir')
    mkdir(img_dir);
end

sim_name = [img_dir,'animation.avi'];

hvid = VideoWriter(sim_name);
set(hvid,'Quality',100);
set(hvid,'FrameRate',2);
framepar.resolution = [1024,768];

open(hvid);


%%


hfig = figure('visible','on','position',[304         166         1200        675]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 13.5])

t0=datenum('20220102 12:00','yyyymmdd HH:MM');
tt = find(abs(timesteps_WQ-t0)==min(abs(timesteps_WQ-t0)));
t1=datenum('20230101 12:00','yyyymmdd HH:MM');
tt1 = find(abs(timesteps_WQ-t1)==min(abs(timesteps_WQ-t1)));
plot_interval=12;

xlim=[115.6000  115.8];
ylim=[-32.3000  -31.9];

m_proj('miller','lon',xlim,'lat',ylim);
hold on;

cellInt=floor((xlim(2)-xlim(1))*1111111/500);
    XX=xlim(1):cellInt/1111111:xlim(2);
    YY=ylim(1):cellInt/1111111:ylim(2);
    [xxx,yyy]=meshgrid(XX,YY);
    cell_X=dat.cell_X;
    cell_Y=dat.cell_Y;
    
    [aa,bb]=m_ll2xy(xxx,yyy);
    xxxq=aa;yyyq=bb;
                    
    intv=round(size(xxxq,1)/50);
    xxxx=xxxq(1:intv:end,1:intv:end);
    yyyy=yyyq(1:intv:end,1:intv:end);
                    
    
    coastline_file='./GIS/Boundary.shp';
    shp2=shaperead(coastline_file);
    cell_inds=inpolygon(xxx,yyy,shp2.X,shp2.Y);


LONG=vert(:,1);LAT=vert(:,2);
[X,Y]=m_ll2xy(LONG,LAT);
vert(:,1)=X;vert(:,2)=Y;

%         LONG=vert2(:,1);LAT=vert2(:,2);
%     [X,Y]=m_ll2xy(LONG,LAT);
%     vert2(:,1)=X;vert2(:,2)=Y;

for i=tt:plot_interval:tt1
    
    disp(datestr(timesteps_WQ(i)));
    clf;
    
   % if first_plot
    subplot(1,4,1);
    
    names={'D';'WQ_DIAG_MAC_MAC_AG';'WQ_DIAG_MAC_MAC_BG';'WQ_DIAG_MAC_PAR';'WQ_DIAG_MAC_GPP'};
    tdat = tfv_readnetcdf(WQfile,'names',names,'timestep',i);
    
    cdata1=tdat.WQ_DIAG_MAC_MAC_AG(bottom_cells);
    d=tdat.D;
    cdata1(d<clip_depth)=NaN;

    patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata1);shading flat
    set(gca,'box','on');
    trange=[0 15000];
    caxis(trange);
    
    set(findobj(gca,'type','surface'),...
        'FaceLighting','phong',...
        'AmbientStrength',.3,'DiffuseStrength',.8,...
        'SpecularStrength',.9,'SpecularExponent',25,...
        'BackFaceLighting','unlit');
    
    colormap('jet');
    cb = colorbar('southoutside');
    P1=get(cb,'Position');
    set(cb,'Position',[P1(1) P1(2)-0.05 P1(3) P1(4)]);
    cb.Label.String = 'MAC_A (m/s)';
    %cbarrow;
    
    hold on;

    m_plot(shp2.X,shp2.Y,'Color',[0.2 0.2 0.2]);
    hold on;
    
    %colorTitleHandle = get(cb,'Title');
    %set(colorTitleHandle ,'String',regexprep(varname,'_',' '),'color','k','fontsize',10);
    title('Above-ground biomass','color','k','fontsize',10);hold on;
     dim = [0.4 0.91 0.3 0.05];
     str = ['Time: ', datestr(double(timesteps_WQ(i)),'yyyy/mm/dd HH:MM')];
     annotation('textbox',dim,'String',str,'FitBoxToText','on','LineStyle','none','FontSize',15);
    m_grid('box','fancy','tickdir','out');
    hold on;
    
    subplot(1,4,2);

    cdata1=tdat.WQ_DIAG_MAC_MAC_BG(bottom_cells); 
    
    d=tdat.D;
    cdata1(d<clip_depth)=NaN;
        
    patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata1);shading flat
    set(gca,'box','on');
    trange=[0 5000];
    caxis(trange);
    
    set(findobj(gca,'type','surface'),...
        'FaceLighting','phong',...
        'AmbientStrength',.3,'DiffuseStrength',.8,...
        'SpecularStrength',.9,'SpecularExponent',25,...
        'BackFaceLighting','unlit');
    
    colormap('jet');
    cb = colorbar('southoutside');
    P1=get(cb,'Position');
    set(cb,'Position',[P1(1) P1(2)-0.05 P1(3) P1(4)]);
    cb.Label.String = 'MAC_B (m)';
    hold on;
    m_plot(shp2.X,shp2.Y,'Color',[0.2 0.2 0.2]);
    hold on;
    %cbarrow;
    hold on;

    title('Below-ground biomass','color','k','fontsize',10);hold on;
    
    m_grid('box','fancy','tickdir','out');
    hold on;
    
    subplot(1,4,3);
    
    cdata1=tdat.WQ_DIAG_MAC_PAR(bottom_cells); 
    
    d=tdat.D;
    cdata1(d<clip_depth)=NaN;

    patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata1);shading flat
    set(gca,'box','on');
    trange=[0 600];
    caxis(trange);
    
    set(findobj(gca,'type','surface'),...
        'FaceLighting','phong',...
        'AmbientStrength',.3,'DiffuseStrength',.8,...
        'SpecularStrength',.9,'SpecularExponent',25,...
        'BackFaceLighting','unlit');
    
    colormap('jet');
    cb = colorbar('southoutside');
    P1=get(cb,'Position');
    set(cb,'Position',[P1(1) P1(2)-0.05 P1(3) P1(4)]);
    cb.Label.String = 'MAC-PAR (W m^{-2})';

    hold on;

    m_plot(shp2.X,shp2.Y,'Color',[0.2 0.2 0.2]);
    hold on;
    
   % cbarrow;

    title('MAC-PAR','color','k','fontsize',10);hold on;
    
    m_grid('box','fancy','tickdir','out');
    hold on;
    
    subplot(1,4,4);

    cdata1=tdat.WQ_DIAG_MAC_GPP(bottom_cells); 
    
    d=tdat.D;
    cdata1(d<clip_depth)=NaN;
    
    patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata1);shading flat
    set(gca,'box','on');
    trange=[0 500];
    caxis(trange);
    
    set(findobj(gca,'type','surface'),...
        'FaceLighting','phong',...
        'AmbientStrength',.3,'DiffuseStrength',.8,...
        'SpecularStrength',.9,'SpecularExponent',25,...
        'BackFaceLighting','unlit');
    
    colormap('jet');
    cb = colorbar('southoutside');
    P1=get(cb,'Position');
    set(cb,'Position',[P1(1) P1(2)-0.05 P1(3) P1(4)]);
    cb.Label.String = 'MAC-NPP (mmol C/m^2/day)';
    
    
    hold on;

    m_plot(shp2.X,shp2.Y,'Color',[0.2 0.2 0.2]);
    hold on;
    
    title('MAC-GPP','color','k','fontsize',10);hold on;
    
    m_grid('box','fancy','tickdir','out');
    hold on;
    
    img_name =[img_dir,'/hydro_',datestr(double(timesteps_WQ(i)),'yyyymmddHHMM'),'.png'];
    
    saveas(gcf,img_name);
    
    writeVideo(hvid,getframe(hfig));
    
end

close(hvid);