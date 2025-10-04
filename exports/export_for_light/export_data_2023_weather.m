clear; close all;
%addpath(genpath('W:\csiem\csiem-marvl\'))

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\2_weather\WRF\cockburn_met_wrf4tfv_2022_2023.nc';
lat=ncread(ncfile,'latitude');
lon=ncread(ncfile,'longitude');

siteX=115.7265;
siteY=-32.1927;

indx=find(abs(lon-siteX)==min(abs(lon-siteX)));
indy=find(abs(lat-siteY)==min(abs(lat-siteY)));

time=ncread(ncfile,'time')/24+datenum(1990,1,1);


loadnames={'PSFC','SWDOWN','GLW','T2','U10','V10','RAINV','REL_HUM'};
short_names={'pressure','SW_radiation','LW_ratidation','Air_temperature','WINDU','WINDV','Rain',...
    'Relative_humidity'};
units ={'Pa','W/m2','W/m2','degrees','m/s','m/s','m/day',...
    'percentage'};

CSweather.Time=time;
CSweather.Timestring=datestr(time,'yyyy-mm-dd HH:MM:SS');

%%

for ll=1:length(loadnames)
    loadname=loadnames{ll};
    disp(['loading ',loadname,' ...']);
    tic;

    rawData=ncread(ncfile,loadname,[indx indy 1],[1 1 Inf]);
    CSweather.(short_names{ll})=squeeze(rawData(1,1,:));
    
    toc;
end

save('extracted_2023_weatherV2.mat','CSweather','-mat','-v7.3');