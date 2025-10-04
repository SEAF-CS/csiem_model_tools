clear; close all;

% load IMOS
var='SAL';
DWER=load(['..\DWER_data_',var,'.mat']);

% find sites within SW region

%shp=shaperead('W:\csiem\csiem-marvl-dev\gis\MLAU_Zones_v3_ll.shp');

%sites=fieldnames(DWER.data);

sites={'DWER_CSMWQ_6142979_Fixed_2047';...
'DWER_CSMWQ_6142979_Floating_2048';...
'DWER_CSMWQ_6142979_Integrated_2049';...
'DWER_CSMWQ_6142979_Profile_2050';...
'DWER_CSMWQ_6142985_Fixed_2207';...
'DWER_CSMWQ_6142985_Floating_2208';...
'DWER_CSMWQ_6142985_Integrated_2209';...
'DWER_CSMWQ_6142985_Profile_2210';...
'DWER_CSMWQ_6142986_Fixed_2256';...
'DWER_CSMWQ_6142986_Floating_2257';...
'DWER_CSMWQ_6142986_Integrated_2258';...
'DWER_CSMWQ_6142986_Profile_2259'};

%sid=1;

for ss=1 %:length(sites)
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

        dateall=tmpdate1;
        dataall=tmpdata1;

end

timearray=dateall;
timearray2=floor(timearray);

SAL =dataall;

timeuniq=unique(timearray2);
polys=4; % for polygon at IMOS

        for t=1:length(timeuniq)
            tmpind1=find(timearray2==(timeuniq(t)));
           % tmpdepth=depth(tmpind1);
            tmpdata0=SAL(tmpind1);
            AMMuniq(t)=mean(tmpdata0(~isnan(tmpdata0)));
        end



%%

romsfile='W:\csiem\Model\TFV\BMTv3_Rerun\bc_dbase\ROMS\ROMS_UTC+8_20130101_20140101_FILLED.nc';

%'W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\Updated\ROMS_UTC+8_20201001_20211231.nc';

%'W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\ROMS_UTC+8_20220101_20221231.nc';

% xx0=tmpdata.X; %116.666;
% yy0=tmpdata.Y; %-32.335;
 xx0=115.338; yy0=-32.0216; 
%xx0=114.3; yy0=-32.013;
xx=ncread(romsfile,'lon');
yy=ncread(romsfile,'lat');

xind=find(abs(xx-xx0)==min(abs(xx-xx0)));
yind=find(abs(yy-yy0)==min(abs(yy-yy0)));

sal=ncread(romsfile,'salinity',[xind yind 1 1],[1 1 Inf Inf]);
temp=ncread(romsfile,'water_temp',[xind yind 1 1],[1 1 Inf Inf]);
time=ncread(romsfile,'time')/24+datenum(1990,1,1);

salmodel=squeeze(sal(1,1,:,:));
tempmodel=squeeze(temp(1,1,:,:));
depth=ncread(romsfile,'depth');
lon=ncread(romsfile,'lon');
lat=ncread(romsfile,'lat');

%%
for i=1:size(salmodel,2)
    pressure(:,i)=depth/10+1.013;
end

[rho, rhodif]=seawater_density(salmodel,tempmodel,pressure);
%%
dvec=datevec(time);

for mm=1:12
    inds=find(dvec(:,2)==mm);
    monthly_mean_output_sal(:,mm)=mean(salmodel(1:26,inds),2);
    monthly_mean_output_temp(:,mm)=mean(tempmodel(1:26,inds),2);
    monthly_mean_output_rho(:,mm)=mean(rho(1:26,inds),2);
end

colors=[158,1,66;...
213,62,79;...
244,109,67;...
253,174,97;...
254,224,139;...
255,255,191;...
230,245,152;...
171,221,164;...
102,194,165;...
50,136,189;...
94,79,162;...
2,56,88]./255;

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

        clf;

        axes('Position',[0.07 0.08 0.20 0.8]);
for mm=1:12
        plot(monthly_mean_output_sal(2:26,mm),-depth(2:26),'Color',colors(mm,:));
        hold on;
end
     %   xlabel('Salinity (PSU)');
        ylabel('Depth (m)');
     %   legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

        title('(a) Salinity (PSU)');
        xlim([35 36]);

        axes('Position',[0.36 0.08 0.20 0.8]);
for mm=1:12
        plot(monthly_mean_output_temp(2:26,mm),-depth(2:26),'Color',colors(mm,:));
        hold on;
end
     %   xlabel('Temperature (^oC)');
        ylabel('Depth (m)');
     %   legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

      title('(b) Temperature (^oC)');
       xlim([15 25]);

       axes('Position',[0.65 0.08 0.20 0.8]);
for mm=1:12
        plot(monthly_mean_output_rho(2:26,mm),-depth(2:26),'Color',colors(mm,:));
        hold on;
end
       % xlabel('Density (kg/m^2)');
        ylabel('Depth (m)');
        hl=legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
        set(hl,'Position',[0.94 0.3 0.005 0.4],'FontSize',6)

      title('(c) Density (kg/m^2)');
        xlim([1024 1026]);


        img_name ='roms_monthly_profile_check.png';

        saveas(gcf,img_name);

% 
% datearray=datenum(2022,1:3:13,1);
% 
% 
% hfig = figure('visible','on','position',[304         166        1271         812]);
% 
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf,'paperposition',[0.635 6.35 20.32 10]);
% 
%         clf;
% 
%         plot(time,salmodel,'k');
%         hold on;
%         scatter(timeuniq,AMMuniq);
%         hold on;
%         set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'mm/yyyy'));
%         %  set(gca,'ylim',[215 245]);
%         ylabel('Salinity (PSU)');
%         legend('ROMS','DWER data');
% 
%       %  title([vars{v}, ' - poly',num2str(polys)]);
% 
%         img_name ='roms_salinity_check.png';
% 
%         saveas(gcf,img_name);