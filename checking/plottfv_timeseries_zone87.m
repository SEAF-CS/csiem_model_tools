clear; close all;

% set up library path
%addpath(genpath('.\aed-marvl\'))

% model output file and read in mesh
ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\csiem_v11_A001_20220101_20221231_WQ_lowRes_seagrass_MZ13_WQ.nc';
cell_number=3379;

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


% set which time slot to plot
datearray=datenum(2022,1,1:2:11);

outdir = 'Seagrasscheck-v1';
mkdir(outdir);
%%
tdat = tfv_readnetcdf(ncfile,'timestep',1);
vars=fieldnames(tdat);

hfig = figure('visible','on','position',[304         166        1271         612]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 12.24])

for ii=1:length(vars)
    clf;

    if strfind(vars{ii},'MAC')
        disp(['plotting variable of ',vars{ii}])
        cdata=ncread(ncfile,vars{ii},[cell_number,1],[1, Inf]);
     %   cdata = tdat.(vars{ii})(cell_number,:);
        plot(timesteps,cdata);

        set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
        ylabel(strrep(vars{ii},'_','-'));
        title(strrep(vars{ii},'_','-'));

        img_name =[outdir,'/',vars{ii},'.png'];

        saveas(gcf,img_name);
    end
end
