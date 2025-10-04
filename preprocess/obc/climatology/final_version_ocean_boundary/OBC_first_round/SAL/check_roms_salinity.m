clear; close all;

romsfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\ROMS_UTC+8_20220101_20221231.nc';

xx0=116.666;yy0=-32.335;
xx=ncread(romsfile,'lon');
yy=ncread(romsfile,'lat');

xind=find(abs(xx-xx0)==min(abs(xx-xx0)));
yind=find(abs(yy-yy0)==min(abs(yy-yy0)));

sal=ncread(romsfile,'salinity',[xind yind 1 1],[1 1 1 Inf]);
time=ncread(romsfile,'time')/24+datenum(1990,1,1);

%%

salmodel=squeeze(sal(1,1,1,:));


% load IMOS
var='SAL';
DWER=load(['..\DWER_data_',var,'.mat']);

%% find sites within SW region

shp=shaperead('W:\csiem\csiem-marvl-dev\gis\MLAU_Zones_v3_ll.shp');

sites=fieldnames(DWER.data);
inc=1;

for ss=1:length(sites)
tmpdata=DWER.data.(sites{ss}).SAL;
aa=tmpdata.Data;
aa(aa<30)=NaN;

if length(aa)>10000
    tmpdata1=aa(1:100:end);
    tmpdate1=tmpdata.Date(1:100:end);
else
    tmpdata1=aa;
    tmpdate1=tmpdata.Date;
end

if inpolygon(tmpdata.X,tmpdata.Y,shp(10).X,shp(10).Y)
    disp(sites{ss});

    if inc==1
        dateall=tmpdate1;
        dataall=tmpdata1;
    else
        dateall=[dateall;tmpdate1];
        dataall=[dataall;tmpdata1];
    end
    inc=inc+1;

end

end

timearray=dateall;
timearray2=floor(timearray);

SAL =dataall;

timeuniq=unique(timearray2);
polys=4; % for polygon at IMOS

        for t=1:length(timeuniq)
            tmpind1=find(timearray2==(timeuniq(t)));
           % tmpdepth=depth(tmpind1);
            tmpdata=SAL(tmpind1);
            AMMuniq(t)=mean(tmpdata(~isnan(tmpdata)));
        end



datearray=datenum(2022,1:3:13,1);


hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

        clf;

        plot(time,salmodel,'k');
        hold on;
        scatter(timeuniq,AMMuniq);
        hold on;
        set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'mm/yyyy'));
        %  set(gca,'ylim',[215 245]);
        ylabel('Salinity (PSU)');
        legend('ROMS','DWER data');

      %  title([vars{v}, ' - poly',num2str(polys)]);

        img_name ='roms_salinity_check.png';

        saveas(gcf,img_name);
