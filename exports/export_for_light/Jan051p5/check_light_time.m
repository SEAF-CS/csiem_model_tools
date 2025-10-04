clear; close all;

zen=load('extracted_OASIM_2023_WQ_DIAG_OAS_ZEN.mat');
swr=load('extracted_OASIM_2023_WQ_DIAG_OAS_SWR_SF.mat');

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
hfig = figure('visible','on','position',[304         166   1200   575]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 8]);

time1=zen.output.Deep_Basin.WQ_DIAG_OAS_ZEN.date;
data1=zen.output.Deep_Basin.WQ_DIAG_OAS_ZEN.bottom;

data2=swr.output.Deep_Basin.WQ_DIAG_OAS_SWR_SF.bottom;

yyaxis left;
plot(time1,data1);
hold on;

yyaxis right;
plot(time1-0.25/24,data2);
hold on;
plot(WRFtime, WRFsw);

datearray=datenum(2023,1,5,1:24,0,0);

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'HH'));

grid on;
hl=legend('ZEN','SWR-SF','WRF-SW');

img_name ='check_time.png';
saveas(gcf,img_name);

