clear; close all;

% set up library path
%addpath(genpath('.\aed-marvl\'))

% model output file and read in mesh
ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\outputs\results\csiem_A001_20221101_20240401_WQ_WQ.nc';

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

outdir = 'MPB_GPP\';
mkdir(outdir);

%%
readdata=0;
vars={'WQ_DIAG_OXY_OXY_DSF','WQ_DIAG_PHY_MPB_GPP','WQ_DIAG_PHY_MPB_RSP'};

if readdata
    for v=1:length(vars)
     tmp=ncread(ncfile,vars{v});
     outdata.(vars{v})=tmp(bottom_cellsHR,:);
    end
    save('MPBGPP.mat','outdata','-mat','-v7.3');
else
     load('MPBGPP.mat');
end

%%
% tdat = tfv_readnetcdf(ncfile,'timestep',tt);
% vars=fieldnames(tdat);

sim_name = [outdir,'animation.mp4'];

hvid = VideoWriter(sim_name, 'MPEG-4');
set(hvid,'Quality',100);
set(hvid,'FrameRate',2);
framepar.resolution = [1024,768];

open(hvid);


     hfig = figure('visible','on','position',[304         166     900    1800]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 12 24]*0.8);
set(gcf,'Color','w');

xlim=[115.6000  115.86]; %[155.32-1  155.86+1]; %[115.6000  115.8];
ylim=[-32.3000  -31.95]; %[-32.67-1  -31.67+1]; %[-32.3000  -31.9];


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


clims1=[400 0 -4 -0.04];
clims2=[2000 200 40 0.2];

m_proj('miller','lon',xlim,'lat',ylim);
hold on;

LONG=double(vert(:,1));LAT=double(vert(:,2));

for k=1:length(LONG)
[X(k),Y(k)]=m_ll2xy(LONG(k),LAT(k));
end
vert2(:,1)=X;vert2(:,2)=Y;
% 
% fields={'WQ_PHY_PICO', 'WQ_PHY_MIXED','WQ_PHY_DIATOM','WQ_PHY_DINO','WQ_DIAG_MAC_MAC_AG','WQ_DIAG_MAC_MAC_BG','WQ_DIAG_PHY_MPB_BEN'};
% lims=[12 12 12 12 16000 16000 200]

t1=datenum(2023,1,1);ind1=find(abs(timesteps-t1)==min(abs(timesteps-t1)));
t2=datenum(2023,1,10);ind2=find(abs(timesteps-t2)==min(abs(timesteps-t2)));

for i=ind1:ind2
 %   subplot(2,4,i);
 disp(datestr(timesteps(i)));
clf;

tmp1=outdata.WQ_DIAG_OXY_OXY_DSF(:,i);
tmp2=outdata.WQ_DIAG_PHY_MPB_GPP(:,i);
tmp3=outdata.WQ_DIAG_PHY_MPB_RSP(:,i);
cdata=tmp1+tmp2-tmp3;
colormap('jet');

 F = scatteredInterpolant(cell_X,cell_Y,double(cdata));
    zzz=F(xxx,yyy);zzz(~cell_inds)=NaN;
    patFig0=m_pcolor(xxx,yyy,zzz);shading interp;
clim([-100 100]);
%patFig = patch('faces',faces,'vertices',vert2,'FaceVertexCData',cdata);shading flat;
set(gca,'box','on');
hold on;

m_grid('box','fancy','tickdir','out');
    hold on;

hc=colorbar;
set(hc,'Position',[0.75 0.18 0.02 0.3]);
title(['Time at: ', datestr(double(timesteps(i)),'yyyy-mm-dd HH:MM')]);


img_name =[outdir,'map_',datestr(double(timesteps(i)),'yyyymmddHHMM'),'.png'];
saveas(gcf,img_name);

writeVideo(hvid,getframe(hfig));
end

close(hvid);