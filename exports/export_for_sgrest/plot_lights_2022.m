clear; close all;

load extracted_OASIM_2022.mat;


inc=1;
for bands=1:9
    loadnames{inc}=['WQ_DIAG_OAS_DIR_BAND',num2str(bands,'%1d')];
    inc=inc+1;
end

for bands=1:9
    loadnames{inc}=['WQ_DIAG_OAS_DIF_BAND',num2str(bands,'%1d')];
    inc=inc+1;
end

for bands=1:9
    loadnames{inc}=['WQ_DIAG_OAS_A_BAND',num2str(bands,'%1d')];
    inc=inc+1;
end

for bands=1:9
    loadnames{inc}=['WQ_DIAG_OAS_B_BAND',num2str(bands,'%1d')];
    inc=inc+1;
end

%%
figure(1);
def.dimensions = [20 10]; % Width & Height in cm
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])  ;

vars={'DIR','DIF','A','B','DIR_SF','DIF_SF'};
vars2={'DIR','DIF','A','B','DIR-SF','DIF-SF'};
datearray=datenum(2021,12,2:2:16);

for vv=1:length(vars)
    clf;
    
for bands=1:9
    var=['WQ_DIAG_OAS_',vars{vv},'_BAND',num2str(bands,'%1d')];
    date=output.CS.(var).date;
    data=output.CS.(var).surface;
    
    plot(date,data);hold on;
end

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm'));
hl=legend('Band 1','Band 2','Band 3','Band 4','Band 5','Band 6','Band 7','Band 8',...
    'Band 9');
set(hl,'Location','eastoutside');

set(gca,'FontName','Times New Roman');
title(['WQ-DIAG-OAS-',vars2{vv},' surface']);

outputName=['./light_','WQ-DIAG-OAS-',vars{vv},' surface - 2022','.jpg'];
print(gcf,'-dpng',outputName);

end

