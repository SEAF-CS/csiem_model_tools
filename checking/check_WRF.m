clear; close all;

wrffile1='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\bc_repo\2_weather\WRF\WRF_d02_UTC+0_20220101_20230101.nc';
wrffile2='W:\WRF4tfv_perth-1500_UTC+8_20211101-20221231.nc';

sitenames='center';
siteX=115.7265;
siteY=-32.1927;

lon1=ncread(wrffile1, 'longitude');
lat1=ncread(wrffile1, 'latitude');

lonind1=find(abs(lon1-siteX)==min(abs(lon1-siteX)));
latind1=find(abs(lat1-siteY)==min(abs(lat1-siteY)));

lon2=ncread(wrffile2, 'longitude');
lat2=ncread(wrffile2, 'latitude');

lonind2=find(abs(lon2-siteX)==min(abs(lon2-siteX)));
latind2=find(abs(lat2-siteY)==min(abs(lat2-siteY)));

time1=ncread(wrffile1,'time')/24+datenum(1990,1,1);
time2=ncread(wrffile2,'time')/24+datenum(1990,1,1);

vars={'SWDOWN','T2','RAINV','REL_HUM'};

for v=1:length(vars)
    var=vars{v};
    disp(var);
tmp=ncread(wrffile1,var,[lonind1 latind1 1],[1 1 Inf]);
data1.(var)=squeeze(tmp(1,1,:));

tmp=ncread(wrffile2,var,[lonind2 latind2 1],[1 1 Inf]);
data2.(var)=squeeze(tmp(1,1,:));
end

%%
outDir='.\WRF_check\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

hfig = figure('visible','on','position',[304         166        1675         1200]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24.5 10]);

for v=1:length(vars)
    clf;

    plot(time1,data1.(vars{v}));
    hold on;

    plot(time2,data2.(vars{v}));
    hold on;

    datearray=datenum(2022,1:3:13,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mmm'));

    img_name =[outDir,'check_',vars{v},'.jpg'];
    saveas(gcf,img_name);
end
