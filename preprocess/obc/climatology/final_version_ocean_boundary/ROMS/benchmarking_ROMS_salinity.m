clear; close all;

IMOS=load('..\..\datasets\processed_IMOS_udates.mat');
DWER=load('..\..\datasets\processed_DWER_udates.mat');
ROMS=load('E:\CS_BC\datasets\ROMS\ROMS_merged_2001_2023.mat');
CSIRO=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_CSIRO_public.mat');

vars={'SAL','TEMP'};

IMOS.dataout.SAL.Data(2835:2890)=NaN;
IMOS.dataout.SAL.Data(IMOS.dataout.SAL.Data==35.6449)=NaN;
IMOS.dataout.SAL.Data(3296:3385)=NaN;

IMOSdate=IMOS.dataout.SAL.Date;
IMOSdata=IMOS.dataout.SAL.Data;

ROMSdate=ROMS.merged.site1.time;
ROMSdata=ROMS.merged.site1.SAL;

DWERdate=DWER.dataout.SAL.Date;
DWERdata=DWER.dataout.SAL.Data;

ROMSdate2=ROMS.merged.site2.time;
ROMSdata2=ROMS.merged.site2.SAL;

[datelt, IMOSsbias, newIMOSSAL]=find_monthly_bias(IMOSdate, IMOSdata, ROMSdate, ROMSdata);
[~, DWERsbias, newDWERSAL]=find_monthly_bias(DWERdate, DWERdata, ROMSdate2, ROMSdata2);



%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2008:2:2024,1,1);
titles={'Salinity','Temperature'};
units={'PSU','degree C'};
c2f='c';
c2f2='m';
colors=[102,194,165;...
141,160,203;...
252,141,98]./255;
ms =12;
alp=0.2;

for v=1
    subplot(2,1,1);
    scatter(IMOS.dataout.(vars{v}).Date,IMOS.dataout.(vars{v}).Data,ms,'filled','MarkerFaceColor',colors(1,:),'MarkerFaceAlpha',0.6,'MarkerEdgeAlpha',0.6,'DisplayName','IMOS');
    hold on;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel(units{v})

    if v==1
        %scatter(ROMS.merged.site1.time,ROMS.merged.site1.SAL,ms,'filled','MarkerFaceColor',colors(2,:),'MarkerEdgeAlpha',alp,'DisplayName','ROMS');
        plot(ROMS.merged.site1.time,ROMS.merged.site1.SAL,'Color',colors(2,:),'DisplayName','ROMS');
        hold on;
        plot(ROMS.merged.site1.time,newIMOSSAL,'Color',colors(3,:),'DisplayName','ROMS-corrected');
        hold on;
        
        ylim([35 37]);
        hl=legend; 
        set(hl,'Location','northwest');
        title([titles{v},'-IMOS']);

    elseif v==2
        scatter(ROMS.merged.site1.time,ROMS.merged.site1.TEMP,ms,'Color',colors(:,1),'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([16 30]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');
        title([titles{v},'-IMOS']);
    
    end

    set(hl,'FontSize',6)

end

for v=1 %:length(vars)
    subplot(2,1,2);
    scatter(DWER.dataout.(vars{v}).Date,DWER.dataout.(vars{v}).Data,ms,'filled','MarkerFaceColor',colors(1,:),'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6,'DisplayName','DWER-nearshore');
    hold on;
    
    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel(units{v})

    if v==1
        %scatter(ROMS.merged.site2.time,ROMS.merged.site2.SAL,ms,'filled','MarkerFaceColor',colors(2,:),'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        plot(ROMS.merged.site2.time,ROMS.merged.site2.SAL,'Color',colors(2,:),'DisplayName','ROMS');
        hold on;
        %scatter(ROMS.merged.site2.time,newDWERSAL,ms,c2f2,'filled','MarkerFaceAlpha',alp,'MarkerEdgeAlpha',alp,'DisplayName','ROMS-corrected');
        plot(ROMS.merged.site2.time,newDWERSAL,'Color',colors(3,:),'DisplayName','ROMS-corrected');
        hold on;
        ylim([34 38]);
        hold on;
        hl=legend; 
        set(hl,'Location','northwest');
        title([titles{v},'-DWER s6142985']);
    elseif v==2
        scatter(ROMS.merged.site2.time,ROMS.merged.site2.TEMP,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([16 30]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');
        title([titles{v},'-DWER s6142985']);
    end

    set(hl,'FontSize',6)

end

img_name ='ROMS_Benchmarking_timeseries_salinity_only.png';

saveas(gcf,img_name);
