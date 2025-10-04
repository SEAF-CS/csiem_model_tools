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

%%

colors=[127,201,127;...
190,174,212;...
253,192,134;...
56,108,176;...
240,2,127;...
191,91,23]./255;

conv=1; %0.1415; % C=0.1415 gWW/mmol C

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

for l=1:6

        plot(datenum(outdata(l).timearray),outdata(l).zooc*conv,'Color',colors(l,:),'DisplayName',['Polygon-',num2str(l)]);
        hold on;

end


    box on;

    datearray=datenum(2007:3:2023,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[34 37]);
    ylabel('Zooplankton biomass (gWW/m^2)')

   % title(titles{l});
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');

img_name ='SEAPODYM-zooplankton.png';

saveas(gcf,img_name);