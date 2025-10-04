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
set(gcf,'paperposition',[0.635 6.35 30.32 20]*0.8);
datearray=datenum(2004:2:2024,1,1);

%yyaxis left;
for v=1:length(vars)-1
    tmp=data.(vars{v}).Data;tmp(tmp>2)=mean(tmp(tmp<=2));
    plotdata(v,:)=tmp;
    piedata(v)=mean(tmp);
    tmp2=data2.(vars{v}).Data;tmp2(tmp2>2)=mean(tmp2(tmp2<=2));
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

pos1=[0.1 0.6 0.8 0.35];
pos2=[0.1 0.15 0.8 0.35];
pos3=[0.1 0.05 0.8 0.05];

axes('Position',pos1);

ha=area(data.Diato.Date,plotdata','LineStyle','none');
colororder(colors)
hold on;
%hl=legend(varnames(2:end));
%ylabel('Phytoplankton biomass (mg/m^3)');
%ylim([0 2]);

%yyaxis right;
plot(data.WQ_DIAG_PHY_TCHLA.Date,-data.WQ_DIAG_PHY_TCHLA.Data,'b','DisplayName','Total chlorophyll-a');
hold on;
set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel({'Total chlorophyll-a/Composition','(\mug/L)'});
set(gca,'ylim',[-2 2],'YTick',-2:1:2,'YTickLabel',{'2','1','0','1','2'});
title('(a) Phytoplankton biomass at IMOS offshore location (ESA GlobColour product)')

axes('Position',pos2);

ha=area(data2.Diato.Date,plotdata2','LineStyle','none');
colororder(colors)
hold on;

%ylabel('Phytoplankton biomass (mg/m^3)');
%ylim([0 2]);

%yyaxis right;
plot(data2.WQ_DIAG_PHY_TCHLA.Date,-data2.WQ_DIAG_PHY_TCHLA.Data,'b','DisplayName','Total chlorophyll-a');
hold on;
set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel({'Total chlorophyll-a/Composition','(\mug/L)'});
set(gca,'ylim',[-3 3],'YTick',-3:1:3,'YTickLabel',{'3','2','1','0','1','2','3'});
title('(b) Phytoplankton biomass at DWER nearshore location (ESA GlobColour product)')

hl=legend(varnames(1:end));
set(hl,'Position',pos3,'NumColumns',6);

img_name ='Phytoplankton_composition_timeseries.png';

saveas(gcf,img_name);


%%

%% read data

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 15]*0.8);

pos1=[0.1 0.1 0.3 0.8];
pos2=[0.5 0.1 0.3 0.8];
pos3=[0.85 0.25 0.12 0.5];

axes('Position',pos1);

pie(piedata*10);
title({'(a) Phytoplankton composition ','at IMOS offshore station'});

axes('Position',pos2);

pie(piedata2);
title({'(b) Phytoplankton composition ','at DWER nearshore station'});

hl=legend(varnames(1:end-1));
set(hl,'Position',pos3);

img_name ='Phytoplankton_composition_piechart.png';

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
title({'(a) Phytoplankton group composition ','at IMOS offshore station'});

axes('Position',pos2);

pie(piedata2(1:6)*10);
title({'(b) Phytoplankton group composition ','at DWER nearshore station'});

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