clear; close all;

% set up library path
%addpath(genpath('.\aed-marvl\'))

% model output file and read in mesh
ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_PH_map_light2_OASIM_restart_08_newBIN20240916_SALCH4_WQ.nc';

dat = tfv_readnetcdf(ncfile,'time',1);
timesteps = dat.Time;

dat = tfv_readnetcdf(ncfile,'timestep',1);
clear funcions

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

surf_cellsHR=dat.idx3(dat.idx3 > 0);
bottom_cellsHR(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cellsHR(length(dat.idx3)) = length(dat.idx3);

%%

vars2plot={'WQ_OGM_POC','WQ_PHS_FRP','WQ_OGM_POP','WQ_OGM_DOP'};
ulims=[50 0.2 1 0.3];
blims=[0 0 0 0];

% set which time slot to plot
t0=datenum('20220101 12:00','yyyymmdd HH:MM');
tt = find(abs(timesteps-t0)==min(abs(timesteps-t0)));

outdir = 'SALCH4-PO4-check-v4-weir_Ps';
mkdir(outdir);
%%
% tdat = tfv_readnetcdf(ncfile,'timestep',tt);
% vars=fieldnames(tdat);

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 15.24]);

for ii=1:3:length(timesteps)
    clf;
    tdat = tfv_readnetcdf(ncfile,'timestep',ii);

    for v=1:4
        subplot(2,2,v);
        clear cdata;
        cdata = tdat.(vars2plot{v})(bottom_cellsHR);
    patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata);shading flat
    set(gca,'box','on');

    set(findobj(gca,'type','surface'),...
        'FaceLighting','phong',...
        'AmbientStrength',.3,'DiffuseStrength',.8,...
        'SpecularStrength',.9,'SpecularExponent',25,...
        'BackFaceLighting','unlit');

    %   x_lim = get(gca,'xlim');
    %  y_lim = get(gca,'ylim');
% 
%     if strfind(vars{ii},'DEPTH')
       caxis([blims(v) ulims(v)]);
% 
%     end
    cb = colorbar;

    colorTitleHandle = get(cb,'Title');
    %set(colorTitleHandle ,'String',regexprep(varname,'_',' '),'color','k','fontsize',10);
    
   % dim = [0.2 0.2 0.3 0.1];
    str = datestr(double(timesteps(ii)),'yyyy/mm/dd HH:MM');
  %  annotation('textbox',dim,'String',str,'FitBoxToText','on','LineStyle','none');
    title([regexprep(vars2plot{v},'_',' '),' - ', str],'color','k','fontsize',10);hold on;
    axis off;
    axis equal;

    end

    img_name =[outdir,'/check-',datestr(double(timesteps(ii)),'yyyymmddHHMMSS'),'.png'];

    saveas(gcf,img_name);
end
