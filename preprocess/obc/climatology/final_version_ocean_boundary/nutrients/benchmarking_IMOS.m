clear; close all;

IMOS=load('..\..\datasets\processed_IMOS_udates_allvars.mat');
ESA=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_ESA_bysite_public.mat');
NASA=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_NASA_bysite_public.mat');
MOI=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_MOI_bysite_public.mat');
% 
% vars={'SAL','TEMP','WQ_PHS_FRP','WQ_NIT_AMM','WQ_NIT_NIT','WQ_OXY_OXY','WQ_DIAG_TOT_TSS','WQ_DIAG_PHY_TCHLA'};
% titles={'Salinity','Temperature','FRP','AMM','NIT','DO','TSS','TCHLA'};
% units={'PSU','degree C','\muM','\muM','\muM','\muM','mg/L','\mug/L'};

vars={'WQ_PHS_FRP','WQ_NIT_AMM','WQ_NIT_NIT','WQ_OXY_OXY','WQ_DIAG_TOT_TSS','WQ_DIAG_PHY_TCHLA'};
titles={'FRP','AMM','NIT','DO','TSS','TCHLA'};
units={'\muM','\muM','\muM','\muM','mg/L','\mug/L'};

%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2008:2:2024,1,1);
c2f='c';
ms =4;

for v=1:length(vars)
    subplot(3,2,v);
    scatter(IMOS.dataout.(vars{v}).Date,IMOS.dataout.(vars{v}).Data,ms,'k','filled','MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6,'DisplayName','IMOS');
    hold on;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel(units{v})

    title(titles{v});
    if v==1
        scatter(MOI.csiem.MOI_PISCES_Polygon_3.WQ_PHS_FRP.Date,MOI.csiem.MOI_PISCES_Polygon_3.WQ_PHS_FRP.Data,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','PISCES');
        ylim([0 0.4]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');    
    elseif v==2
        ylim([0 0.5]);
        hl=legend; 
        % set(hl,'Location','eastoutside');    
    elseif v==3
        scatter(MOI.csiem.MOI_PISCES_Polygon_3.WQ_NIT_NIT.Date,MOI.csiem.MOI_PISCES_Polygon_3.WQ_NIT_NIT.Data,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','PISCES');
        ylim([0 1]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');    
    elseif v==4
        scatter(MOI.csiem.MOI_PISCES_Polygon_3.WQ_OXY_OXY.Date,MOI.csiem.MOI_PISCES_Polygon_3.WQ_OXY_OXY.Data,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','PISCES');
        ylim([180 300]);
        hold on;
        hl=legend; 
        set(hl,'Location','northwest');
    elseif v==5
        scatter(ESA.csiem.ESA_GC_Polygon_3.SPM.Date,ESA.csiem.ESA_GC_Polygon_3.SPM.Data,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','GlobColour');
        ylim([0 6]);
        hold on;
        hl=legend; 

        % set(hl,'Location','eastoutside');
    elseif v==6
        scatter(ESA.csiem.ESA_SEN_Polygon_3.WQ_DIAG_PHY_TCHLA.Date,ESA.csiem.ESA_SEN_Polygon_3.WQ_DIAG_PHY_TCHLA.Data,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','Sentinel');
        ylim([0 5]);
        hold on;
        hl=legend; 
    end

    set(hl,'FontSize',6)

end

img_name ='IMOS_Benchmarking_timeseries.png';

saveas(gcf,img_name);


%%

hfig3 = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 32.32 10]);

% FRP
subplot(1,4,1);
fDate=IMOS.dataout.WQ_PHS_FRP.Date;
fData=IMOS.dataout.WQ_PHS_FRP.Data;
SDate=floor(MOI.csiem.MOI_PISCES_Polygon_3.WQ_PHS_FRP.Date);
SData=MOI.csiem.MOI_PISCES_Polygon_3.WQ_PHS_FRP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib),'poly1');
hp=plot(sf,fData(ia)', SData(ib));
hp(1).Color=[0 1 1];
[r,m,b] = regression(fData(ia)', SData(ib),'one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[0 0.3]; ylim=[0 0.3];
set(gca,'xlim',xlim,'ylim',ylim);
string={['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.65;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('PISCES');
title('FRP (\muM)');


% DO
subplot(1,4,2);
fDate=IMOS.dataout.WQ_OXY_OXY.Date;
fData=IMOS.dataout.WQ_OXY_OXY.Data;
SDate=floor(MOI.csiem.MOI_PISCES_Polygon_3.WQ_OXY_OXY.Date);
SData=MOI.csiem.MOI_PISCES_Polygon_3.WQ_OXY_OXY.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib),'poly1');
hp=plot(sf,fData(ia)', SData(ib));
hp(1).Color=[0 1 1];
[r,m,b] = regression(fData(ia)', SData(ib),'one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[180 280]; ylim=[180 280];
set(gca,'xlim',xlim,'ylim',ylim);
string={['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.65;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('PISCES');
title('DO (\muM)');

% TSS
subplot(1,4,3);
fDate=IMOS.dataout.WQ_DIAG_TOT_TSS.Date;
fData=IMOS.dataout.WQ_DIAG_TOT_TSS.Data;
SDate=floor(ESA.csiem.ESA_GC_Polygon_3.SPM.Date);
SData=ESA.csiem.ESA_GC_Polygon_3.SPM.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib),'poly1');
hp=plot(sf,fData(ia)', SData(ib));
hp(1).Color=[0 1 1];
[r,m,b] = regression(fData(ia)', SData(ib),'one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[0 6]; ylim=[0 6];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.65;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('GlobColour');
title('TSS (mg/L)');

% TCHLA
subplot(1,4,4);
fDate=IMOS.dataout.WQ_DIAG_PHY_TCHLA.Date;
fData=IMOS.dataout.WQ_DIAG_PHY_TCHLA.Data;
SDate=floor(ESA.csiem.ESA_SEN_Polygon_3.WQ_DIAG_PHY_TCHLA.Date);
SData=ESA.csiem.ESA_SEN_Polygon_3.WQ_DIAG_PHY_TCHLA.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib),'poly1');
hp=plot(sf,fData(ia)', SData(ib));
hp(1).Color=[0 1 1];
[r,m,b] = regression(fData(ia)', SData(ib),'one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[0 5]; ylim=[0 5];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.65;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('Sentinel');
title('TCHLA (\mug/L)');

img_name ='IMOS_Benchmarking_regression.png';

saveas(gcf,img_name);