clear; close all;

IMOS=load('..\processed_IMOS_udates.mat');
DWER=load('..\processed_DWER_udates.mat');
ROMS=load('E:\CS_BC\ROMS\ROMS_merged_2001_2023.mat');
CSIRO=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_CSIRO_public.mat');

vars={'SAL','TEMP'};

%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2008:2:2024,1,1);
titles={'Salinity','Temperature'};
units={'PSU','degree C'};
c2f='b';
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
        scatter(ROMS.merged.site1.time,ROMS.merged.site1.SAL,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([35 37]);
        hold on;
        hl=legend; 
        set(hl,'Location','northwest');
    elseif v==2
        scatter(ROMS.merged.site1.time,ROMS.merged.site1.TEMP,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([16 30]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');
    
    end

    set(hl,'FontSize',6)

end

for v=1:length(vars)
    subplot(3,2,v+2);
    scatter(DWER.dataout.(vars{v}).Date,DWER.dataout.(vars{v}).Data,ms,'k','filled','MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6,'DisplayName','DWER-nearshore');
    hold on;

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel(units{v})

    title(titles{v});

    if v==1
        scatter(ROMS.merged.site2.time,ROMS.merged.site2.SAL,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([34 38]);
        hold on;
        hl=legend; 
        set(hl,'Location','northwest');
    elseif v==2
        scatter(ROMS.merged.site2.time,ROMS.merged.site2.TEMP,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([16 30]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');
    
    end

    set(hl,'FontSize',6)

end

for v=1:length(vars)
    subplot(3,2,v+4);
    scatter(CSIRO.csiem.A_SBE4534_10m.(vars{v}).Date,CSIRO.csiem.A_SBE4534_10m.(vars{v}).Data,ms,'k','filled','MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6,'DisplayName','CSIRO-nearshore');
    hold on;
    datearray2=datenum(2000:2:2016,1,1);
    set(gca,'xlim',[datearray2(1) datearray2(end)],'XTick',datearray2,'XTickLabel',datestr(datearray2,'yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel(units{v})

    title(titles{v});

    if v==1
        scatter(ROMS.merged.site3.time,ROMS.merged.site3.SAL,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([34 38]);
        hold on;
        hl=legend; 
        set(hl,'Location','northwest');
    elseif v==2
        scatter(ROMS.merged.site3.time,ROMS.merged.site3.TEMP,ms,c2f,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2,'DisplayName','ROMS');
        ylim([16 30]);
        hold on;
        hl=legend; 
        % set(hl,'Location','eastoutside');
    
    end

    set(hl,'FontSize',6)

end

img_name ='ROMS_Benchmarking_timeseries_TwoRocks.png';

saveas(gcf,img_name);

%%

hfig3 = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 32 20]);

% SAL
subplot(2,3,1);
fDate=IMOS.dataout.SAL.Date;
fData=IMOS.dataout.SAL.Data;

tmpT=floor(ROMS.merged.site1.time);
tmpD=ROMS.merged.site1.SAL;

tmpT2=unique(tmpT);

for j=1:length(tmpT2)
    t2i=tmpT2(j);
    tmpD2(j)=mean(tmpD(tmpT==t2i));
end

SDate=tmpT2; %floor(NASA.csiem.NASA_Polygon_3.TEMP.Date);
SData=tmpD2; %NASA.csiem.NASA_Polygon_3.TEMP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib)','poly1');
plot(sf,fData(ia)', SData(ib)');
[r,m,b] = regression(fData(ia)', SData(ib)','one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[35 37]; ylim=[35 37];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.7;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('ROMS');
title('SAL (^oC)');

% TEMP
subplot(2,3,4);
fDate=IMOS.dataout.TEMP.Date;
fData=IMOS.dataout.TEMP.Data;

tmpT=floor(ROMS.merged.site1.time);
tmpD=ROMS.merged.site1.TEMP;

tmpT2=unique(tmpT);

for j=1:length(tmpT2)
    t2i=tmpT2(j);
    tmpD2(j)=mean(tmpD(tmpT==t2i));
end

SDate=tmpT2; %floor(NASA.csiem.NASA_Polygon_3.TEMP.Date);
SData=tmpD2; %NASA.csiem.NASA_Polygon_3.TEMP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib)','poly1');
plot(sf,fData(ia)', SData(ib)');
[r,m,b] = regression(fData(ia)', SData(ib)','one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[12 30]; ylim=[12 30];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.7;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('ROMS');
title('TEMP (^oC)');

% SAL
subplot(2,3,2);
fDate=DWER.dataout.SAL.Date;
fData=DWER.dataout.SAL.Data;

tmpT=floor(ROMS.merged.site2.time);
tmpD=ROMS.merged.site2.SAL;

tmpT2=unique(tmpT);

for j=1:length(tmpT2)
    t2i=tmpT2(j);
    tmpD2(j)=mean(tmpD(tmpT==t2i));
end

SDate=tmpT2; %floor(NASA.csiem.NASA_Polygon_3.TEMP.Date);
SData=tmpD2; %NASA.csiem.NASA_Polygon_3.TEMP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib)','poly1');
plot(sf,fData(ia)', SData(ib)');
[r,m,b] = regression(fData(ia)', SData(ib)','one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[34 38]; ylim=[34 38];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.7;

text(xx,yy,string); hold on;
xlabel('DWER'); ylabel('ROMS');
title('SAL (^oC)');

% TEMP
subplot(2,3,5);
fDate=DWER.dataout.TEMP.Date;
fData=DWER.dataout.TEMP.Data;

tmpT=floor(ROMS.merged.site2.time);
tmpD=ROMS.merged.site2.TEMP;

tmpT2=unique(tmpT);

for j=1:length(tmpT2)
    t2i=tmpT2(j);
    tmpD2(j)=mean(tmpD(tmpT==t2i));
end

SDate=tmpT2; %floor(NASA.csiem.NASA_Polygon_3.TEMP.Date);
SData=tmpD2; %NASA.csiem.NASA_Polygon_3.TEMP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia)', SData(ib)','poly1');
plot(sf,fData(ia)', SData(ib)');
[r,m,b] = regression(fData(ia)', SData(ib)','one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[12 30]; ylim=[12 30];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.7;

text(xx,yy,string); hold on;
xlabel('IMOS'); ylabel('ROMS');
title('TEMP (^oC)');

% SAL
subplot(2,3,3);
fDate=CSIRO.csiem.A_SBE4534_10m.SAL.Date;
fData=CSIRO.csiem.A_SBE4534_10m.SAL.Data;

tmpT=floor(ROMS.merged.site3.time);
tmpD=ROMS.merged.site3.SAL;

tmpT2=unique(tmpT);

for j=1:length(tmpT2)
    t2i=tmpT2(j);
    tmpD2(j)=mean(tmpD(tmpT==t2i));
end

SDate=tmpT2; %floor(NASA.csiem.NASA_Polygon_3.TEMP.Date);
SData=tmpD2; %NASA.csiem.NASA_Polygon_3.TEMP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia), SData(ib)','poly1');
plot(sf,fData(ia), SData(ib)');
[r,m,b] = regression(fData(ia), SData(ib)','one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[34 38]; ylim=[34 38];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.7;

text(xx,yy,string); hold on;
xlabel('CSIRO'); ylabel('ROMS');
title('SAL (^oC)');

% TEMP
subplot(2,3,6);
fDate=CSIRO.csiem.A_SBE4534_10m.TEMP.Date;
fData=CSIRO.csiem.A_SBE4534_10m.TEMP.Data;

tmpT=floor(ROMS.merged.site2.time);
tmpD=ROMS.merged.site3.TEMP;

tmpT2=unique(tmpT);

for j=1:length(tmpT2)
    t2i=tmpT2(j);
    tmpD2(j)=mean(tmpD(tmpT==t2i));
end

SDate=tmpT2; %floor(NASA.csiem.NASA_Polygon_3.TEMP.Date);
SData=tmpD2; %NASA.csiem.NASA_Polygon_3.TEMP.Data;
[C, ia, ib]=intersect(fDate,SDate);
%scatter(fData(ia), SData(ib),ms,c2f,'filled','MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5);
hold on;
sf = fit(fData(ia), SData(ib)','poly1');
plot(sf,fData(ia), SData(ib)');
[r,m,b] = regression(fData(ia), SData(ib)','one');
hl=legend; set(hl,'Location','northwest');
hold on; box on; axis equal;
xlim=[12 30]; ylim=[12 30];
set(gca,'xlim',xlim,'ylim',ylim);
string={['y=',num2str(m,'%4.4f'),'x+',num2str(b,'%4.4f')],...
    ['r=',num2str(r,'%4.4f')],['bias=',num2str((mean(fData(ia))-mean(SData(ia)))/mean(fData(ia))*100,'%4.2f'),'%']};
xx=xlim(1)+(xlim(2)-xlim(1))*0.05;
yy=ylim(1)+(ylim(2)-ylim(1))*0.7;

text(xx,yy,string); hold on;
xlabel('CSIRO'); ylabel('ROMS');
title('TEMP (^oC)');

img_name ='ROMS_Benchmarking_regression_TwoRocks.png';

saveas(gcf,img_name);