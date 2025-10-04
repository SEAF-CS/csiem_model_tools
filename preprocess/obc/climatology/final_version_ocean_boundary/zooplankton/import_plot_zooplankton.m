clear all; close all;

zoofile='zooplankton biovolume mm3_m3 Westport.xlsx';

%data=readtable(zoofile);

[~,species,~] = xlsread(zoofile,'A2:A44');
[~,sitedate,~] = xlsread(zoofile,'B1:FY1');
[values,~,~] = xlsread(zoofile,'B2:FY44');

for i=1:length(sitedate)
    C=split(sitedate{i},' ');
    sites{i}=C{1};
    months{i}=C{2};
    years{i}=C{3};
end

for k=1:length(species)
    tmp1=strrep(species{k},' ','_');
    tmp2=strrep(tmp1,'(','');
    tmp3=strrep(tmp2,')','');
    tmp4=strrep(tmp3,'/','_');
    newname{k}=tmp4;
end

uniqSites=unique(sites);
uniqMonths0=unique(months);
newInds=[5 4 8 1 9 7 6 2 12 11 10 3];

for u=1:length(uniqMonths0)
uniqMonths{u}=uniqMonths0{newInds(u)};
end

for j=1:length(uniqSites)
    tmpinds(j).ids=find(strcmp(sites, uniqSites{j}));

    for k=1:length(species)
        
        processed.(uniqSites{j}).(newname{k})=values(k,tmpinds(j).ids);
    end

end

%%

gcf=figure(1);
pos=get(gcf,'Position');
xSize = 38;
ySize = 20;
newPos3=(pos(3)+pos(4))*xSize/(xSize+ySize);
newPos4=(pos(3)+pos(4))*ySize/(xSize+ySize);
set(gcf,'Position',[pos(1) pos(2) newPos3 newPos4]);
%  set(0,'DefaultAxesFontName',master.font);
%  set(0,'DefaultAxesFontSize',master.fontsize);

%--% Paper Size
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0 0 xSize ySize]);

for s=1:length(uniqSites)
clf;

for m=1:length(species)
    plot(processed.(uniqSites{s}).(newname{m}));
    hold on;
end

title(['Zooplankton biomass at ', uniqSites{s},' ']);
%ylim([0 150]);
set(gca,'xlim',[0 13],'XTick',1:12,'XTickLabel',uniqMonths);
ylabel('biovolume mm^3/m^3');

hl=legend(species,'NumColumns',2,'FontSize',9);
set(hl,'Location','eastoutside')
%set(hl,'Position',[0.45 0.02 0.2 0.02])

    pngname=['zooplankton_overveiw_',uniqSites{s},'.png'];

   print(gcf,'-dpng',pngname,'-r300');

end

%%
%%

gcf=figure(1);
pos=get(gcf,'Position');
xSize = 38;
ySize = 20;
newPos3=(pos(3)+pos(4))*xSize/(xSize+ySize);
newPos4=(pos(3)+pos(4))*ySize/(xSize+ySize);
set(gcf,'Position',[pos(1) pos(2) newPos3 newPos4]);
%  set(0,'DefaultAxesFontName',master.font);
%  set(0,'DefaultAxesFontSize',master.fontsize);

%--% Paper Size
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0 0 xSize ySize]);

for s=1:length(uniqSites)
clf;
clear plotdata;
for m=1:length(species)
    plotdata(:,m)=processed.(uniqSites{s}).(newname{m});
end

area(plotdata);
title(['Zooplankton biomass at ', uniqSites{s},' ']);
%ylim([0 150]);
set(gca,'xlim',[0 13],'XTick',1:12,'XTickLabel',uniqMonths);
ylabel('biovolume mm^3/m^3');

hl=legend(species,'NumColumns',2,'FontSize',9);
set(hl,'Location','eastoutside')
%set(hl,'Position',[0.45 0.02 0.2 0.02])

    pngname=['Areaplot_zooplankton_overveiw_',uniqSites{s},'.png'];

   print(gcf,'-dpng',pngname,'-r300');

end