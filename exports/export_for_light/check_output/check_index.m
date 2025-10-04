
clear;
close all;

metfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\CSIEM_export_2023Jan05.nc';
WQfile ='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\CSIEM_export_2023Jan05.nc';

dat = tfv_readnetcdf(metfile,'timestep',1);
cellx=ncread(metfile,'cell_X');
celly=ncread(metfile,'cell_Y');

Bottcells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
Bottcells(length(dat.idx3)) = length(dat.idx3);
Surfcells=dat.idx3(dat.idx3 > 0);

datT = tfv_readnetcdf(metfile,'time',1);
timesteps=datT.Time;

siteX=115.7265;
siteY=-32.1927;

diffx=cellx-siteX;diffy=celly-siteY;
difft=sqrt(diffx.^2+diffy.^2);

ind0=find(abs(difft)==min(abs(difft)));

sw=ncread(metfile,'WQ_DIAG_OAS_SWFLUX');
sw2=sw(Bottcells,:);
sw3=sw2(ind0,:);

t0=datenum(2023,1,6);
ind=find(abs(timesteps-t0)==min(abs(timesteps-t0)));


%%

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\2_weather\WRF\cockburn_met_wrf4tfv_2022_2023.nc';
lat=ncread(ncfile,'latitude');
lon=ncread(ncfile,'longitude');

siteX=115.7265;
siteY=-32.1927;

indx=find(abs(lon-siteX)==min(abs(lon-siteX)));
indy=find(abs(lat-siteY)==min(abs(lat-siteY)));

time=ncread(ncfile,'time')/24+datenum(1990,1,1);
time_local=ncread(ncfile,'local_time')/24+datenum(1990,1,1);
