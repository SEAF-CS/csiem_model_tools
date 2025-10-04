clear; close all;

inDir='W:\csiem\Data\Virtual_Sensor_20241007\MOI\SEAPODYM\Model_PP_ZO\Polygon\';


for poly=1:6

infile=[inDir,'CMEMS_npp_zooc_polygon_',num2str(poly),'.csv'];

disp(infile);
T=readtable(infile);

%depth=T.depth;
outdata(poly).Time=T.time;

outdata(poly).timearray=datetime(T.time,'InputFormat','yyyy-mm-dd HH:MM:SS');

outdata(poly).zooc=T.zooc;
end

IMOS=load('..\..\datasets\processed_IMOS_udates_allvars.mat');
DWER=load('..\..\datasets\processed_DWER_udates_allvars.mat');

rawdata=IMOS.dataout.WQ_DIAG_PHY_TCHLA.Data;
timearray=IMOS.dataout.WQ_DIAG_PHY_TCHLA.Date;
IMOSTCHLA=create_monthly_climatology(timearray, rawdata);
IMOSZOO=create_monthly_climatology(datenum(outdata(3).timearray), outdata(3).zooc);

rawdata=DWER.dataout.WQ_DIAG_PHY_TCHLA.Data;
timearray=DWER.dataout.WQ_DIAG_PHY_TCHLA.Date;
DWERTCHLA=create_monthly_climatology(timearray, rawdata);
DWERZOO=create_monthly_climatology(datenum(outdata(6).timearray), outdata(6).zooc);

%%

colors=[127,201,127;...
190,174,212;...
253,192,134;...
56,108,176;...
240,2,127;...
191,91,23]./255;

conv=0.1415; % C=0.1415 gWW/mmol C

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

subplot(2,1,1);
l=3;
yyaxis left;
%plot(datenum(outdata(l).timearray),outdata(l).zooc*conv,'Color',colors(l,:),'DisplayName','Zooplankton');
plot(DWERZOO.time,DWERZOO.data,'DisplayName','Zooplankton');
ylabel({'Zooplankton', '(gWW/m^2)'})
ylim([0 5]);

yyaxis right;
plot(DWERTCHLA.time,DWERTCHLA.data,'DisplayName','TCHLA');
hold on;
ylabel({'TCHLA', '(\mug/L)'})
ylim([0 5]);

    box on;

    datearray=datenum(2008:2:2024,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[34 37]);
    

    title('(a) monthly zooplankton biomass and TCHLA concentration in offshore region');
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
   set(hl,'Location','northwest');

    subplot(2,1,2);
l=6;
yyaxis left;
%plot(datenum(outdata(l).timearray),outdata(l).zooc*conv,'Color',colors(l,:),'DisplayName','Zooplankton');
plot(IMOSZOO.time,IMOSZOO.data,'DisplayName','Zooplankton');
ylabel({'Zooplankton', '(gWW/m^2)'})
ylim([0 5]);
yyaxis right;
plot(IMOSTCHLA.time,IMOSTCHLA.data,'DisplayName','TCHLA');
hold on;
ylabel({'TCHLA', '(\mug/L)'})
ylim([0 5]);
    box on;

    datearray=datenum(2008:2:2024,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[34 37]);
    

   title('(b) monthly zooplankton biomass and TCHLA concentration in nearshore region');
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','northwest');

img_name ='zooplankton-vs-thcla-polygon3.png';

saveas(gcf,img_name);