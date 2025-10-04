clear; close all;
% 
% zen=load('extracted_OASIM_2023_WQ_DIAG_OAS_ZEN.mat');
% swr=load('extracted_OASIM_2023_WQ_DIAG_OAS_SWR_SF.mat');

WRFfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.5\bc_repo\2_weather\WRF\cockburn_met_wrf4tfv_2022_2023.nc';
WRFtime=ncread(WRFfile,'local_time')/24+datenum(1990,1,1);
lon=ncread(WRFfile,'longitude');
lat=ncread(WRFfile,'latitude');

siteX=115.7265;
siteY=-32.1927;

indx=find(abs(lon-siteX)==min(abs(lon-siteX)));
indy=find(abs(lat-siteY)==min(abs(lat-siteY)));

WRFsw0=ncread(WRFfile,'SWDOWN',[indx indy 1],[1 1 Inf]);
WRFsw=squeeze(WRFsw0(1,1,:));

%%

WQfile ='W:\csiem\Model\TFV\csiem_model_tfvaed_1.5\outputs\results\CSIEM_export_2023Jan05_new2.nc'; %csiem_A001_Jan_light_WQ.nc';
dat = tfv_readnetcdf(WQfile,'timestep',1);
cellx=ncread(WQfile,'cell_X');
celly=ncread(WQfile,'cell_Y');

Bottcells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
Bottcells(length(dat.idx3)) = length(dat.idx3);
Surfcells=dat.idx3(dat.idx3 > 0);

datT = tfv_readnetcdf(WQfile,'time',1);
timesteps=datT.Time;

diffx=cellx-siteX;diffy=celly-siteY;
difft=sqrt(diffx.^2+diffy.^2);

ind0=find(abs(difft)==min(abs(difft)));

tmp=ncread(WQfile,'WQ_DIAG_OAS_ZEN');
tmp2=tmp(Bottcells,:);
data1=tmp2(ind0,:);
clear tmp tmp2;

tmp=ncread(WQfile,'WQ_DIAG_OAS_SWR_SF');
tmp2=tmp(Bottcells,:);
data2=tmp2(ind0,:);
clear tmp tmp2;

%%
hfig = figure('visible','on','position',[304         166   1200   575]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 8]);

yyaxis left;
plot(timesteps,data1);
ylabel('ZEN');
hold on;

yyaxis right;
plot(timesteps,data2);
hold on;
plot(WRFtime, WRFsw,'k');
ylabel('Shortwave');
xlabel('hours 05/Jan');

datearray=datenum(2023,1,5,1:24,0,0);

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'HH'));

grid on;
hl=legend('ZEN','SWR-SF','WRF-SW');

img_name ='check_time_v2.png';
saveas(gcf,img_name);

