clear; close all;

%infile='W:\csiem\Model\TFV\Results_2022_B009\csiem_v1_B009_20220101_20221231_WQ.nc';
infile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\csiem_v1_A001_20221101_20231231_WQ_lowRes_HYCOM_3hourly.nc';
H=ncread(infile,'H',[3500 1],[1 Inf]);
inds=find(H>0.5);

dat = tfv_readnetcdf(infile,'time',1);
timesteps=dat.Time;

dat = tfv_readnetcdf(infile,'timestep',inds(2));

lon=dat.cell_X;
lat=dat.cell_Y;

surf_cells=dat.idx3(dat.idx3 > 0);
bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cells(length(dat.idx3)) = length(dat.idx3);

% fileID = fopen('leaflet_velocity.csv','w');
% fprintf(fileID,'%s\n','Lon,Lat,Vx,Vy');
% 
% for i=1:length(lon)
% fprintf(fileID,'%6.6f, %6.6f, %2.4f, %2.4f\n',lon(i),lat(i),Vx(i),Vy(i));
% end
% fclose(fileID);

%%
% xlim=[115.2000  116.0];
% ylim=[-32.8000  -31.5];
xlim=[115.3000  115.9];
ylim=[-32.7000  -31.6];


% cellInt=floor((xlim(2)-xlim(1))*1111111/500);
%     XXs=xlim(1):cellInt/1111111:xlim(2);
%     YYs=ylim(1):cellInt/1111111:ylim(2);
    cellInt=0.005;
    XXs=xlim(1):cellInt:xlim(2);
    YYs=ylim(1):cellInt:ylim(2);
    [xxx,yyy]=meshgrid(XXs,YYs);

    coastline_file='./GIS/Boundary.shp';
    shp2=shaperead(coastline_file);
    cell_inds=inpolygon(xxx,yyy,shp2.X,shp2.Y);


%%
  hfig = figure('visible','on','position',[304         166         1200        1675]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 33.5]);

outDir='.\leaflet_datasets\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

for t=inds(2)+12:1:inds(2)+24

dat = tfv_readnetcdf(infile,'timestep',t);

Vx0=dat.V_x;
Vy0=dat.V_y;
Vx=Vx0(surf_cells);
Vy=Vy0(surf_cells);

  clf;
  intv=2;


    Fx = scatteredInterpolant(lon,lat,double(Vx));
    zzzx=Fx(xxx,yyy);zzzx(~cell_inds)=NaN;
  %  xxxu=zzzx(1:intv:end,1:intv:end);
    Fy = scatteredInterpolant(lon,lat,double(Vy));
    zzzy=Fy(xxx,yyy);zzzy(~cell_inds)=NaN;
  %  xxxv=zzzy(1:intv:end,1:intv:end);

Vt=sqrt(zzzx.^2+zzzy.^2);
pcolor(xxx,yyy,Vt);
shading flat;
hold on;

colorbar;

    hq0=quiver(xxx(1:intv:end,1:intv:end),yyy(1:intv:end,1:intv:end), ...
        zzzx(1:intv:end,1:intv:end),zzzy(1:intv:end,1:intv:end),4,'w');

    axis equal;
    clim([0 1.0]);set(gca,'xlim',xlim,'ylim',ylim);

    img_name =[outDir,'current_vectors_5km_',datestr(timesteps(t),'yyyymmddHHMMSS'),'.png'];

saveas(gcf,img_name);

%%
fileID = fopen([outDir,'leaflet_velocity_gridded_5km_',datestr(timesteps(t),'yyyymmddHHMMSS'),'.csv'],'w');
fprintf(fileID,'%s\n','Lon,Lat,Vx,Vy');

for i=1:size(xxx,1)
   if mod(i,10)==0
      disp(i);
   end

    for j=1:size(xxx,2)

        fprintf(fileID,'%6.6f, %6.6f, %2.4f, %2.4f\n',xxx(i,j),yyy(i,j),zzzx(i,j),zzzy(i,j));
    end
end
fclose(fileID);

%

ncfile = [outDir,'leaflet_velocity_gridded_5km_',datestr(timesteps(t),'yyyymmddHHMMSS'),'.nc'];
nccreate(ncfile,"LON",...
"Dimensions",{"r",size(xxx,1),"c",size(xxx,2)},"Format","classic");
ncwrite(ncfile,'LON',xxx);

nccreate(ncfile,"LAT",...
"Dimensions",{"r",size(xxx,1),"c",size(xxx,2)},"Format","classic");
ncwrite(ncfile,'LAT',yyy);

nccreate(ncfile,"Vx",...
"Dimensions",{"r",size(xxx,1),"c",size(xxx,2)},"Format","classic");
ncwrite(ncfile,'Vx',zzzx);

nccreate(ncfile,"Vy",...
"Dimensions",{"r",size(xxx,1),"c",size(xxx,2)},"Format","classic");
ncwrite(ncfile,'Vy',zzzy);

end