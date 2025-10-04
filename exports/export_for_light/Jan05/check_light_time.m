clear; close all;

zen=load('extracted_OASIM_2023_WQ_DIAG_OAS_ZEN.mat');
swr=load('extracted_OASIM_2023_WQ_DIAG_OAS_SWR_SF.mat');


hfig = figure('visible','on','position',[304         166   1200   575]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 8]);

time1=zen.output.Deep_Basin.WQ_DIAG_OAS_ZEN.date;
data1=zen.output.Deep_Basin.WQ_DIAG_OAS_ZEN.bottom;

data2=swr.output.Deep_Basin.WQ_DIAG_OAS_SWR_SF.bottom;

yyaxis left;
plot(time1,data1);
hold on;

yyaxis right;
plot(time1,data2);

datearray=datenum(2023,1,5,1:24,0,0);

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'HH'));

grid on;

img_name ='check_time.png';
saveas(gcf,img_name);

