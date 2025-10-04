clear; close all;

hsi_functions_posidonia_sinuosa;

%sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

t1=datenum(2023,1,1);
t2=datenum(2023,4,1);

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_OBC_2023_waves_scale_WQ.nc';

dat = tfv_readnetcdf(ncfile,'timestep',1);
clear funcions
cellX=dat.cell_X; cellY=dat.cell_Y;

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

dat = tfv_readnetcdf(ncfile,'time',1);
timesteps=dat.Time;

ind1=find(abs(timesteps-t1)==min(abs(timesteps-t1)));
ind2=find(abs(timesteps-t2)==min(abs(timesteps-t2)));

readdata=1;

if readdata
     tmpfile='extracted_2023_SAL.mat';
     tmp=load(tmpfile);
	 sal0=tmp.output.SAL.bottom;
     sal=mean(sal0(:,ind1:ind2),2);clear tmp sal0;
	 
	 tmpfile='extracted_2023_TEMP.mat';
     tmp=load(tmpfile);
	 temp0=tmp.output.TEMP.bottom;
     temp=mean(temp0(:,ind1:ind2),2);clear tmp temp0;
	 
	 tmpfile1='extracted_2023_V_x.mat';
     tmp1=load(tmpfile1);
	 temp01=tmp1.output.V_x.bottom;
     tmpfile2='extracted_2023_V_y.mat';
     tmp2=load(tmpfile2);
	 temp02=tmp2.output.V_y.bottom;
	 
	 for i=1:ind2-ind1+1
	     vt0(:,i)=sqrt(temp01(:,i+ind1-1).^2+temp02(:,i+ind1-1).^2);
	 end
		 
	 vt=max(vt0,[],2);
	 clear tmp1 temp01 tmp2 temp02;
	 
	 tmpfile='extracted_2023_WQ_DIAG_TOT_EXTC.mat';
     tmp=load(tmpfile);
	 temp0=tmp.output.WQ_DIAG_TOT_EXTC.bottom;
	 temp1=tmp.output.WQ_DIAG_TOT_EXTC.surface;
	 
	 for i=1:ind2-ind1+1
	     extc(:,i)=(temp0(:,i+ind1-1)+temp1(:,i+ind1-1))/2;
	 end
	 
	 D0=ncread(ncfile, 'D');
	 D=D0(:,ind1:ind2);
     extcCON=0.2;
	 
	 for i=1:size(D,1)
	     for j=1:size(D,2)
		     Lper0(i,j)=exp(-extcCON*D(i,j));
		 end
     end
     Lper=mean(Lper0,2);clear tmp temp0 temp1 D0 D;

	 
	 loadwave=0;
	 
	 if loadwave==1
	     wave0=load('../orbital_2023_whole_domain.mat');
         tdiff=datenum(1958,11,17)-datenum(1858,11,17);
		 timestepsW=wave0.output.time-tdiff;
		 indW1=find(abs(timestepsW-t1)==min(abs(timestepsW-t1)));
		 indW2=find(abs(timestepsW-t2)==min(abs(timestepsW-t2)));
		 
		 waveorb=wave0.output.ubot(:,indW1:indW2);
		 save('wave_2023_tmp1.mat','waveorb','-mat','-v7.3');
	 else
		 load('wave_2023_tmp1.mat');
	 end
	
     for i=1:size(waveorb,1)
         waveorbF(i)=prctile(waveorb(i,:),95);
     end
     file='W:\csiem\Model\WAVES\WAVES\2024_addition\his_20240101.nc';
     lon=ncread(file, 'lon');
     lat=ncread(file, 'lat');

     F=scatteredInterpolant(lon, lat, double(waveorbF'));
     waveorbF=F(cellX,cellY);
	 
     save('processed_2023_tmp1_extcCON.mat','sal','temp','vt','Lper','waveorbF','-mat','-v7.3');
else
     load('processed_2023_tmp1_extcCON.mat');
end

     %%

     for i=1:length(sal)
       HSI.sal(i)=interp1(sal_function(:,1), sal_function(:,2), sal(i));
       HSI.temp(i)=interp1(temp_function(:,1), temp_function(:,2), temp(i));
       HSI.Lper(i)=interp1(light_function(:,1), light_function(:,2), Lper(i)*100);
       HSI.vt(i)=interp1(vel_function(:,1), vel_function(:,2), vt(i));
       HSI.wave(i)=interp1(wave_function(:,1), wave_function(:,2), waveorbF(i));
     end

     %%
     shpfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.5\gis_repo\2_benthic\materials\CSOA_Ranae_SGspp_merged_reorder.shp';
     shp=shaperead(shpfile);

     pids=[11 12 13 24];

     type1=inpolygon(cellX, cellY, shp(11).X, shp(11).Y);
     type2=inpolygon(cellX, cellY, shp(12).X, shp(12).Y);
     type3=inpolygon(cellX, cellY, shp(13).X, shp(13).Y);
     type4=inpolygon(cellX, cellY, shp(24).X, shp(24).Y);

     HSI.substrate=type1+type2+type3*0.5+type4;
     HSI.substrate(HSI.substrate>=1)=1;
     HSI.substrate=1-HSI.substrate;
     HSI.substrate=HSI.substrate';

     HSI.overall=HSI.sal.*HSI.temp.*HSI.Lper.*HSI.vt.*HSI.wave.*HSI.substrate;

     %% plotting

     fields={'sal','temp','Lper','vt','wave','substrate','overall'};
     titles={'Salinity','Temperature','Light Availability','Flow Velocity','Wave Exposure','Substrate','Overall'};

     hfig = figure('visible','on','position',[304         166         1800        1275]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 13.5]);

xlim=[115.6000  115.8]; %[155.32-1  155.86+1]; %[115.6000  115.8];
ylim=[-32.3000  -31.9]; %[-32.67-1  -31.67+1]; %[-32.3000  -31.9];

clims1=[400 0 -4 -0.04];
clims2=[2000 200 40 0.2];

m_proj('miller','lon',xlim,'lat',ylim);
hold on;

LONG=double(vert(:,1));LAT=double(vert(:,2));

for k=1:length(LONG)
[X(k),Y(k)]=m_ll2xy(LONG(k),LAT(k));
end
vert2(:,1)=X;vert2(:,2)=Y;

for i=1:length(fields)
    subplot(2,4,i);

    cdata=HSI.(fields{i});

colormap('parula');
patFig = patch('faces',faces,'vertices',vert2,'FaceVertexCData',cdata');shading flat;
set(gca,'box','on');
hold on;

m_grid('box','fancy','tickdir','out');
    hold on;
title(titles{i});

end


img_name ='HSI_map_Jan-Mar2023_extcCON.png';
saveas(gcf,img_name);




