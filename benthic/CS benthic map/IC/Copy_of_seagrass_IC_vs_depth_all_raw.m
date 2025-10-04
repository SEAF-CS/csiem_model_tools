%%
clear; close all;

depths=0:0.1:12;  % depth array
minBiomass=0;     % min biomass
maxBiomass=400;   % max biomass
minDepth  =4;     % min depth above which is max biomass;
maxDepth  =10;     % max depth below which is 0 biomass;
Biomass=zeros(size(depths));  % allocate biomass array

% loop through the depth for biomass
for i=1:length(depths)
        scale=12/(maxDepth-minDepth);
        offset=-6/scale-minDepth;
        a=(depths(i)+offset)*scale;
        Biomass(i)=minBiomass+exp(-a)./(1+exp(-a))*(maxBiomass-minBiomass);
end

%% load in field data

infile='D:\AED Dropbox\AED_Cockburn_db\CSIEM\Data\data-swamp\WAMSI\WWMSP2.2 - Seagrass Monitoring\seagrass biomass.xlsx';
depthE=xlsread(infile,'biomass_all','D3:D32');
BiomassE=xlsread(infile,'biomass_all','F3:F32');


for j=1:length(depthE)
    bb2(j)=interp1(depths,Biomass,depthE(j));
end
%%
gcf=figure;
set(gcf,'Position',[100 100 800 500]);
set(0,'DefaultAxesFontSize',15);

clf;

plot(depths,Biomass);
hold on;
scatter(depthE,BiomassE);
hold on;

[r b]=regression(BiomassE,bb2','one')
legend('fit','data');
text(9.5,300,['r=',num2str(r,'%4.4f')]);

xlabel('depth (m)')
ylabel('biomass (gDW/m2)')

print(gcf,'Biomass_vs_depth_all_raw.png','-dpng');