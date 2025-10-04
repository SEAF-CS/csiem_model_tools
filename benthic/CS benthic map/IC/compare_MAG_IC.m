clear; close all;

infile='csiem_aed_benthic_map_B009.csv';
oriData=tfv_readBCfile(infile);

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\csiem_v1_B009_20130101_20131231_HD_CLN2_W14.nc';

dat=tfv_readnetcdf(ncfile,'timestep',1);


vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

    surf_cells=dat.idx3(dat.idx3 > 0);
    bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
    bottom_cells(length(dat.idx3)) = length(dat.idx3);

    %%
    
 %%           
        hfig = figure('visible','on','position',[304         166        1271         812]);
        
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf,'paperposition',[0.635 6.35 20.32 15.24]);
        
        subplot(1,3,1);
        cdata1=oriData.MAC_seagrass;
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata1);shading flat
        set(gca,'box','on');

           caxis([0 24000]);  
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
        
        axis off;
        axis equal;

        cb = colorbar;
        title('(a) CSIEM1.0 initial condition','FontSize',12);

        subplot(1,3,2);
        cdata2=dat.cell_Zb;
        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',cdata2);shading flat
        set(gca,'box','on');

       caxis([-20 0]);  
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
        
        axis off;
        axis equal;

        cb = colorbar;
        title('(b) water depth (m)','FontSize',12);
        
        subplot(1,3,3);
        depths=-dat.cell_Zb;
% 
% minBiomass=10;     % min biomass
% maxBiomass=500;   % max biomass
% minDepth  =3;     % min depth above which is max biomass;
% maxDepth  =9;     % max depth below which is 0 biomass;

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

Biomass=10.^(Biomass);
Biomass=Biomass*0.5/12*1000;
Biomass(cdata1==0)=0;

        patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',Biomass);shading flat
        set(gca,'box','on');

       caxis([0 24000]);  
        
        set(findobj(gca,'type','surface'),...
            'FaceLighting','phong',...
            'AmbientStrength',.3,'DiffuseStrength',.8,...
            'SpecularStrength',.9,'SpecularExponent',25,...
            'BackFaceLighting','unlit');
        
        axis off;
        axis equal;

        cb = colorbar;
        title('(c) new initial condition','FontSize',12);
        
        img_name ='./seagraa_IC_compare.png';
        
        saveas(gcf,img_name);