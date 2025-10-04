clear; close all;

shpFile='E:\CS benthic map\SZ_merged\CSOA_Ranae_SGspp_merged.shp';
shp=shaperead(shpFile);

% Material zone orders:
% material == 1! entire model domain 
% material == 16! swan river
% material == 21, 22, 23, 24, 25, 26, 27! sed grainsize
% material == 61! soft substrate sand
% material == 68, 89! hard substrate reef (68 is from previous version and outside CSOA (from various sources), 89 is from Ranae's latest version and in CSOA only)
% material == 70! mixed substrate
% material == 60! Seagrass (Swan River)(no species info)
% material == 66! Seagrass (Perennial) (no species info)
% material == 80,81,82,83,84,85,86,87! Seagrass (with species info)
% material == 59! artificial structure

orders  =[1 16 21:27           61  68 89 70  60 66 80:87 59];
fs1_zone=[0 0.4 0.4:-0.05:0.1 0.05 0   0 0.01 0  0 0 0 0 0 0 0 0 0 0];
MPB_zone=[0 10 10:-1.25:2.5   0.00 50 50 0.00 0  0 0 0 0 0 0 0 0 0 0]; 

for ss=1:length(shp)
    matid(ss)=shp(ss).Material;
end

for oo=1:length(orders)
    k=find(matid==orders(oo));
    processOrder(oo)=k;
    neworders(oo)=shp(k).Material;
    shp(k).fs1=fs1_zone(oo);
    shp(k).MPB=MPB_zone(oo);
end

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_PH_map_light1_WQ.nc';

cellx=ncread(ncfile,'cell_X');
celly=ncread(ncfile,'cell_Y');

Mids=ones(size(cellx));
FS1ids=ones(size(cellx));
MPBids=ones(size(cellx));

for pp=1:length(processOrder)
    shpID=processOrder(pp);
    inds=inpolygon(cellx,celly,shp(shpID).X,shp(shpID).Y);
    Mids(inds)=shp(shpID).Material;
    FS1ids(inds)=shp(shpID).fs1;
    MPBids(inds)=shp(shpID).MPB;
end

% %%
% 
% outfile='Material_zone_in_Cells_LowRes.csv';
% fileID = fopen(outfile,'w');
% fprintf(fileID,'%s\n','ID,Material_ID');
% 
% for ii=1:length(Mids)
%     fprintf(fileID,'%6d,',ii);
%     fprintf(fileID,'%6d\n',Mids(ii));
% end
% 
% fclose(fileID);

%%

dat = tfv_readnetcdf(ncfile,'timestep',1);
vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

surf_cells=dat.idx3(dat.idx3 > 0);
bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cells(length(dat.idx3)) = length(dat.idx3);

hfig = figure('visible','on','position',[304         166        675         1200]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 13.5 24]);

patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',Mids);shading flat;
axis equal;
colorbar;

img_name ='LowRes_Material_zones.png';
saveas(gcf,img_name);

clf;
patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',FS1ids);shading flat;
axis equal;
colorbar;

img_name ='LowRes_FS1.png';
saveas(gcf,img_name);

    
%% creating IC file

zones=[60,66, 80,81,82,83,84,85,86,87];
minBiomass=[1,1,1,1,1,1,1,1,1,1];     % min biomass
maxBiomass=[1,1,1,1,1,1,1,1,1,1]*2.7;   % max biomass
minDepth  =[1,1,1,1,1,1,1,1,1,1]*3;     % min depth above which is max biomass;
maxDepth  =[1,1,1,1,1,1,1,1,1,1]*12;     % max depth below which is 0 biomass;
names={'Swan','Perennial', 'P-coriacea-Amphibolis','P-sinuosa','P-australis-P-sinuosa',...
    'P-australis','P-sinuosa-Amphibolis','P-coriacea','Amphibolis','Halophila'};
names_family={'Swan','Perennial', 'PosAmp','Posidoniaceae','Posidoniaceae)',...
    'Posidoniaceae','PosAmp','Posidoniaceae','Amphibolis','Halophila'};

Depth=ncread(ncfile,'cell_Zb');
% minBiomass=1;     % min biomass
% maxBiomass=2.7;   % max biomass
% minDepth  =3;     % min depth above which is max biomass;
% maxDepth  =12;     % max depth below which is 0 biomass;
Biomass=zeros(length(Depth), length(zones));  % allocate biomass array

% loop through the depth for biomass
for i=1:length(names)
        scale=12/(maxDepth(i)-minDepth(i));
        offset=-6/scale-minDepth(i);

        Inds=find(Mids==zones(i));
        a=(-Depth(Inds)+offset)*scale;
        Biomass(Inds,i)=minBiomass(i)+exp(-a)./(1+exp(-a))*(maxBiomass(i)-minBiomass(i));
        Biomass(Inds,i)=10.^(Biomass(Inds,i))/2/14*1000;
end

totalBiomass=sum(Biomass,2);

for m=1:length(MPBids)
    dd=Depth(m);
    scale=12/(12-3);
    offset=-6/scale-3;
    a=(-dd+offset)*scale;
    tmp=-2+exp(-a)./(1+exp(-a))*(log10(MPBids(m))+2);
    MPBids2(m)=10.^tmp;
end

MPBids2(MPBids2<=0.01)=0;
MPBids2(isnan(MPBids2))=0;
%MPBids2=MPBids.*totalBiomass./(max(totalBiomass));

hfig = figure('visible','on','position',[304         166        675         1200]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 13.5 24]);

clf;
patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',MPBids2');shading flat;
axis equal;
colorbar;

img_name ='LowRes_MPB.png';
saveas(gcf,img_name);

hfig = figure('visible','on','position',[304         166        1675         1200]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 33.5 24]);

for i=1:length(names)

    subplot(2,6,i);
patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',Biomass(:,i));shading flat;
axis equal;
%colorbar;
clim([0 16000]);
title(names{i});
end

subplot(2,6,11);
patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',totalBiomass);shading flat;
axis equal;
clim([0 16000]);
hc=colorbar;
title('Total Biomass');
set(hc,'Position',[0.85 0.15 0.01 0.3])

img_name ='LowRes_MAC_allBiomass.jpg';
saveas(gcf,img_name);

%%
outfile='csiem_aed_benthic_map_A001_AUG2024.csv';
fileID = fopen(outfile,'w');
fprintf(fileID,'%s\n','ID,MAC_seagrass_ag,MAC_seagrass_bg,MAC_seagrass_fr,NCS_fs1,PHY_mpb');

for ii=1:length(totalBiomass)
    fprintf(fileID,'%6d,',ii);
    fprintf(fileID,'%6.4f,',totalBiomass(ii));
    fprintf(fileID,'%6.4f,',totalBiomass(ii));
    fprintf(fileID,'%6.4f,',0);
    fprintf(fileID,'%6.4f,',FS1ids(ii));
    fprintf(fileID,'%6.4f\n',MPBids2(ii));
end

fclose(fileID);