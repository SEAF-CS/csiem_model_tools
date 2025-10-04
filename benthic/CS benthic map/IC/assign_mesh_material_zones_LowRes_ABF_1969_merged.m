clear; close all;

shpFile='.\history\cambridge_polygon_1954-1962.shp';
shp=shaperead(shpFile);

T1=readtable('csiem_aed_benthic_map_A001_history1969.csv');
T2=readtable('W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\gis_repo\2_benthic\ecology\csiem_aed_benthic_map_A001_AUG2024_ABF.csv');


%%

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_PH_map_light1_WQ.nc';

cellx=ncread(ncfile,'cell_X');
celly=ncread(ncfile,'cell_Y');

Mids=zeros(size(cellx));
%FS1ids=ones(size(cellx));
%MPBids=ones(size(cellx));

for pp=1:length(shp)
    shpID=pp;
    inds=inpolygon(cellx,celly,shp(shpID).X,shp(shpID).Y);
    Mids(inds)=1; %shp(shpID).Material;
   % FS1ids(inds)=shp(shpID).fs1;
   % MPBids(inds)=shp(shpID).MPB;
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

img_name ='LowRes_Material_zones_1969.png';
saveas(gcf,img_name);

    
%% creating IC file

ag1=T1.MAC_seagrass_ag;
ag2=T2.MAC_seagrass_ag;
ag3=ag1;

for cc=1:length(ag1)

    if (Mids(cc)==0 && ag2(cc)>0)
        ag3(cc)=ag2(cc);
    end
end

hfig = figure('visible','on','position',[304         166        1675         1200]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 33.5 24]);

patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',ag3);shading flat;
axis equal;
clim([0 16000]);
hc=colorbar;
title('Total Biomass');
set(hc,'Position',[0.85 0.15 0.01 0.3])

img_name ='LowRes_MAC_allBiomass_1969.jpg';
saveas(gcf,img_name);

%%
outfile='csiem_aed_benthic_map_A001_history1969_merged.csv';
fileID = fopen(outfile,'w');
fprintf(fileID,'%s\n','ID,MAC_seagrass_ag,MAC_seagrass_bg,MAC_seagrass_fr');

for ii=1:length(ag3)
    fprintf(fileID,'%6d,',ii);
    fprintf(fileID,'%6.4f,',ag3(ii));
    fprintf(fileID,'%6.4f,',ag3(ii));
    fprintf(fileID,'%6.4f\n',0);
end

fclose(fileID);