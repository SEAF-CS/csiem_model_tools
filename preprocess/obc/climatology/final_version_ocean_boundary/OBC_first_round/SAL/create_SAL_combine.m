clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

south=load('exported_SAL_south.mat');
west=load('exported_SAL_west.mat');

%% scaling to other polygons

output.poly1=south.output.poly6;
output.poly2=south.output.poly6;
output.poly3=west.output.poly4;
output.poly4=west.output.poly4;
output.poly5=south.output.poly6;
output.poly6=south.output.poly6;

save([outDIR,'exported_SAL.mat'],'output','-mat','-v7.3')

%%
hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);


for polys=1:6

clf;

plot(output.(['poly',num2str(polys)]).time,...
        output.(['poly',num2str(polys)]).data,'DisplayName','monthly');
    hold on;
    box on;

    datearray=datenum(1980:5:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[215 245]);
    ylabel('SAL (PSU)')

    title(['SAL - poly',num2str(polys)]);
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');


img_name =[outDIR,'timeseries_SAL_poly_',num2str(polys),'.png'];

saveas(gcf,img_name);

end