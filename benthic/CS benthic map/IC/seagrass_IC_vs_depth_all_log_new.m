%%
clear; close all;

depths=0:0.1:12;  % depth array
minBiomass=1;     % min biomass
maxBiomass=2.7;   % max biomass
minDepth  =3;     % min depth above which is max biomass;
maxDepth  =12;     % max depth below which is 0 biomass;
Biomass=zeros(size(depths));  % allocate biomass array

% loop through the depth for biomass
for i=1:length(depths)
        scale=12/(maxDepth-minDepth);
        offset=-6/scale-minDepth;
        a=(depths(i)+offset)*scale;
        Biomass(i)=minBiomass+exp(-a)./(1+exp(-a))*(maxBiomass-minBiomass);
end

%% load in field data

infile='D:\AED Dropbox\AED_Cockburn_db\CSIEM\Data\data-swamp\WAMSI\WWMSP2.2 - Seagrass Monitoring\seagrass biomass (version 1).xlsb.xlsx';
depthE0=xlsread(infile,'biomass_all','D3:D32');
inds=[1:22,27:30];
depthE=depthE0(inds);
BiomassE0=xlsread(infile,'biomass_all','F3:F32');
BiomassE1=BiomassE0(inds);
BiomassE=log10(BiomassE1);

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
scatter(depthE(1:18),BiomassE(1:18));
hold on;
scatter(depthE(19:26),BiomassE(19:26));
hold on;

[r b]=regression(BiomassE,bb2','one')
legend('fit','2003','2015');
text(9,0.5,['r=',num2str(r,'%4.4f')]);
set(gca,'ylim',[0 4]);
xlabel('depth (m)')
ylabel('biomass log10 (gDW/m2)')

print(gcf,'Biomass_vs_depth_all_log_new.png','-dpng');