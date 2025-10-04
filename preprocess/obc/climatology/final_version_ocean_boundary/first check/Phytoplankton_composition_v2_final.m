clear; close all;

ESA=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_ESA_bysite_public.mat');

data=ESA.csiem.ESA_GC_Polygon_3;
data2=ESA.csiem.ESA_GC_Point_11;
vars={'Diato','GREEN','Dino','HAPTO','PROCHLO','PROKAR','MICRO','NANO', 'PICO','WQ_DIAG_PHY_TCHLA'};
varnames={'Diatom','Green Algae','Dinoflagellates','Haptophytes','Prochlorococcus',...
    'Prokaryotes','Microplankton','Nanoplankton','Picoplankton','Total Chlorophyll-a'};

%% Phytoplankton product information
% expressed as Chlorophyll a concentration in sea water
% (mg m-3), includes the following variables: DIATO
% (Diatoms), DINO (Dinophytes or Dinoflagellates), CRYPTO
% (Cryptophytes), GREEN (Green algae & Prochlorophytes)
% and PROKAR (Prokaryotes); MICRO (Micro-
% phytoplankton), NANO (Nano-phytoplankton) and PICO
% (Pico-phytoplankton) also known as “Phytoplankton Size
% Classes” (PSCs). MICRO consist of DIATO and DINO, NANO
% of CRYPTO and half of the GREEN group and PICO includes
% half GREEN and PROKAR. Note: the development of the
% algorithms applied for the PFT retrieval in this product is
% based on a different methodology than that used for the
% PFT estimate provided in other products (GLO and ATL).
% For more details see the relevant documentation

%% read data

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]*1.0);
datearray=datenum(2004:2:2024,1,1);

%yyaxis left;
for v=1:length(vars)-1
    tmp=data.(vars{v}).Data;tmp(tmp>2)=mean(tmp(tmp<=2));
    plotdata(v,:)=tmp;
    piedata(v)=mean(tmp);
    tmp2=data2.(vars{v}).Data;tmp2(tmp2>4)=mean(tmp2(tmp2<=4));
    plotdata2(v,:)=tmp2;
    piedata2(v)=mean(tmp2);
end

colors=[228,26,28;...
55,126,184;...
77,175,74;...
152,78,163;...
255,127,0;...
255,255,51;...
166,86,40;...
247,129,191;...
153,153,153]./255;

wl=0.3;wd=0.20;

pos1=[0.1 0.68 wl wd];
pos2=[0.5 0.68 wl wd];
pos3=[0.1 0.38 wl wd];
pos4=[0.5 0.38 wl wd];
pos5=[0.1 0.08 wl wd];
pos6=[0.5 0.08 wl wd];
pos7=[0.85 0.72 0.12 0.12];
pos8=[0.85 0.43 0.12 0.06];
pos9=[0.85 0.18 0.12 0.03];

axes('Position',pos1);

ha=area(data.Diato.Date,plotdata(1:6,:)','LineStyle','none');
colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(a) Phytoplankton Function Types (PFTs) - IMOS offshore')

axes('Position',pos3);

ha=area(data.Diato.Date,plotdata(7:9,:)','LineStyle','none');
colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(c) Phytoplankton size classes - IMOS offshore')

axes('Position',pos5);

plot(data.WQ_DIAG_PHY_TCHLA.Date,data.WQ_DIAG_PHY_TCHLA.Data,'b','DisplayName','Total chlorophyll-a');
hold on;
set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(e) Total chlorophyll-a concentration - IMOS offshore')

%%


axes('Position',pos2);

ha=area(data2.Diato.Date,plotdata2(1:6,:)','LineStyle','none');
colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 4],'YTick',0:1:4,'YTickLabel',{'0.0','1.0','2.0','3.0','4.0'});
title('(b) Phytoplankton Function Types (PFTs) - DWER nearshore')

hl=legend(varnames(1:6));
set(hl,'Position',pos7);

axes('Position',pos4);

ha=area(data2.Diato.Date,plotdata2(7:9,:)','LineStyle','none');
colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 4],'YTick',0:1:4,'YTickLabel',{'0.0','1.0','2.0','3.0','4.0'});
title('(d) Phytoplankton size classes - DWER nearshore');

hl=legend(varnames(7:9));
set(hl,'Position',pos8);

axes('Position',pos6);

plot(data2.WQ_DIAG_PHY_TCHLA.Date,data2.WQ_DIAG_PHY_TCHLA.Data,'b','DisplayName','Total chlorophyll-a');
hold on;
set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 4],'YTick',0:1:4,'YTickLabel',{'0.0','1.0','2.0','3.0','4.0'});
title('(f) Total chlorophyll-a concentration - DWER nearshore')

hl=legend(varnames(10));
set(hl,'Position',pos9);


img_name ='Phytoplankton_composition_timeseries_final.png';

saveas(gcf,img_name);

%% read data

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 25]*0.8);

pos1=[0.1 0.5 0.3 0.3];
pos2=[0.5 0.5 0.3 0.3];
pos3=[0.1 0.1 0.3 0.3];
pos4=[0.5 0.1 0.3 0.3];
pos5=[0.85 0.60 0.12 0.2];
pos6=[0.85 0.20 0.12 0.1];

axes('Position',pos1);

pie(piedata(1:6)*10);
title({'(a) Phytoplankton Functional Types ','at IMOS offshore station'});

axes('Position',pos2);

pie(piedata2(1:6)*10);
title({'(b) Phytoplankton Functional Types ','at DWER nearshore station'});

hl=legend(varnames(1:6));
set(hl,'Position',pos5);
hold on;

axes('Position',pos3);

pie(piedata(7:9)*10);
title({'(c) Phytoplankton size composition ','at IMOS offshore station'});

axes('Position',pos4);

pie(piedata2(7:9)*10);
title({'(d) Phytoplankton size composition ','at DWER nearshore station'});

hl=legend(varnames(7:9));
set(hl,'Position',pos6);
img_name ='Phytoplankton_composition_piechart_v2.png';

saveas(gcf,img_name);