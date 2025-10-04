
clear; close all;

phy_g={'MIXED','DINO','PICO','DIATOM'};
fLs={'FT','FI','FNIT','FPHO','FSAL'};

inDir='W:\csiem\csiem-marvl-dev\others\CSIEM20_PHY\';

% for f=1:length(fLs)
%     for p=1:length(phy_g)
%         tmp=load(['extracted_PHY_2023_WQ_DIAG_PHY_',phy_g{g},'_',fLs{f},'.mat']);
% 
%         data2p.(phy_g{g})=tmp.;
% 
%     end
% end

for p=1:length(phy_g)

    for f=1:length(fLs)

        tmp=load([inDir,'extracted_PHY_2023_WQ_DIAG_PHY_',phy_g{p},'_',fLs{f},'.mat']);

        data2p.(phy_g{p}).(fLs{f})=tmp.output.Deep_Basin.(['WQ_DIAG_PHY_',phy_g{p},'_',fLs{f}]).surface;

    end
end

data2p.time=tmp.output.Deep_Basin.(['WQ_DIAG_PHY_',phy_g{p},'_',fLs{f}]).date;

%%

hfig = figure('visible','on','position',[304         166   1200   575]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 8]);

outDir='CSIEM20_PHY\';

for f=1:length(fLs)
    clf;

    for p=1:length(phy_g)
    plot(data2p.time(3:end),data2p.(phy_g{p}).(fLs{f})(3:end));
    hold on;

    end

datearray=datenum(2022,11:16,1);

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'HH'));

grid on;
hl=legend(phy_g);

img_name =[outDir,'check_lim_',fLs{f},'.png'];
saveas(gcf,img_name);


end


