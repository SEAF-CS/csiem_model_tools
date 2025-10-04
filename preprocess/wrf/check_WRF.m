clear; close all;

infile='E:\AED Dropbox\AED_Cockburn_db\7_modelling\WRF\20230101000000\results\d02\wrfout_d02_2023-01-01_000000.nc';
infile2='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\2_weather\WRF\cockburn_met_wrf4tfv_2022_2023.nc';

times=ncread(infile,'Times');
lon=ncread(infile,'XLONG');
lat=ncread(infile,'XLAT');

lon2=ncread(infile2,'longitude');
lat2=ncread(infile2,'latitude');

%znu=ncread(infile,'ZNU');
%znw=ncread(infile,'ZNW');
% 
% x00=115.7255; y00=-32.1874;
% 
% lon1=squeeze(lon(:,:,1));
% lat1=squeeze(lat(:,:,1));
% 
% xdiff=lon1-x00;
% ydiff=lat1-y00;
% tdiff=sqrt(xdiff.^2+ydiff.^2);

indx=32;indy=49;

%%


%%
readdata1=0;

if readdata1
    t2=ncread(infile2,'time')/24+datenum(1990,1,1);
T2S=ncread(infile2,'T2',[indx indy 1],[1 1 Inf]);T2S=squeeze(T2S(1,1,:));
SWS=ncread(infile2,'SWDOWN',[indx indy 1],[1 1 Inf]);SWS=squeeze(SWS(1,1,:));
LWS=ncread(infile2,'GLW',[indx indy 1],[1 1 Inf]);LWS=squeeze(LWS(1,1,:));
save('extracted_WRF_202324.mat','t2','T2S','SWS','LWS','-v7.3');

else
load extracted_WRF_202324.mat;
end

%%
readdata2=0;

if readdata2


t0=ncread(infile,'Times');
for i=1:size(t0,2)
    tmp=t0(:,i);
    Str=convertCharsToStrings(tmp);
    t3(i)=datenum(Str,'yyyy-mm-dd_HH:MM:SS');
end

T2=ncread(infile,'T2',[indx indy 1],[1 1 Inf]);T2=squeeze(T2(1,1,:));
SW=ncread(infile,'SWDNB',[indx indy 1],[1 1 Inf]);SW=squeeze(SW(1,1,:));
LW=ncread(infile,'LWDNB',[indx indy 1],[1 1 Inf]);LW=squeeze(LW(1,1,:));
save('extracted_WRF_202301.mat','t3','T2','SW','LW','-v7.3');

else
load extracted_WRF_202301.mat;
end

%%

%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2022,12:1:15,1);

c2f='c';
ms =4;


    subplot(3,1,1);
    
    plot(t2,T2S,'Color','k','DisplayName','converted');
    hold on;
    plot(t3,T2-273.15,'Color','b','DisplayName','raw');
    hold on;
    hl=legend;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel('degrees')

    title('Temperature');

subplot(3,1,2);
    
    plot(t2,SWS,'Color','k','DisplayName','converted');
    hold on;
    plot(t3,SW,'Color','b','DisplayName','raw');
    hold on;
    hl=legend;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel('W/m^2')

    title('SW radiation');

    subplot(3,1,3);
    
    plot(t2,LWS,'Color','k','DisplayName','converted');
    hold on;
    plot(t3,LW,'Color','b','DisplayName','raw');
    hold on;
    hl=legend;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel('W/m^2')

    title('LW radiation');

img_name ='WRF_checking.png';

saveas(gcf,img_name);


%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2022,7:6:31,1);

c2f='c';
ms =4;


    subplot(3,1,1);
    
    plot(t2,T2S,'Color','k','DisplayName','WRF');
    hold on;
    plot(t2,movmean(T2S,24*30),'Color','b','DisplayName','movemean');
    hold on;
    hl=legend;


    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel('degrees')

    title('Temperature');

subplot(3,1,2);
    
    plot(t2,SWS,'Color','k','DisplayName','converted');
    hold on;
    plot(t2,movmean(SWS,24*30),'Color','b','DisplayName','movemean');
    hold on;
    
    hl=legend;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel('W/m^2')

    title('SW radiation');

    subplot(3,1,3);
    
    plot(t2,LWS,'Color','k','DisplayName','converted');
    hold on;
    plot(t2,movmean(LWS,24*30),'Color','b','DisplayName','movemean');
    hold on;
    hl=legend;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm/yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel('W/m^2')

    title('LW radiation');

img_name ='WRF_checking_movemean.png';

saveas(gcf,img_name);