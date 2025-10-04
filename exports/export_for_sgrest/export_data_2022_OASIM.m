clear; close all;
%addpath(genpath('W:\csiem\csiem-marvl\'))

ncfile(1).name='W:\csiem\Model\TFV\Results_2011_OASIM\csiem_v1_A001_20211101_20230101_WQ_lowRes_newBIN_WQV1.nc';

allvars = tfv_infonetcdf(ncfile(1).name);
dat = tfv_readnetcdf(ncfile(1).name,'timestep',1);
cellx=ncread(ncfile(1).name,'cell_X');
celly=ncread(ncfile(1).name,'cell_Y');

Bottcells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
Bottcells(length(dat.idx3)) = length(dat.idx3);
Surfcells=dat.idx3(dat.idx3 > 0);

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


for bands=1:9
    loadnames{inc}=['WQ_DIAG_OAS_DIR_SF_BAND',num2str(bands,'%1d')];
    inc=inc+1;
end


for bands=1:9
    loadnames{inc}=['WQ_DIAG_OAS_DIF_SF_BAND',num2str(bands,'%1d')];
    inc=inc+1;
end
% loadnames={'WQ_DIAG_NCS_D_TAUB','SAL','TEMP','WQ_DIAG_TOT_LIGHT','WQ_DIAG_TOT_PAR','V_x','V_y','WQ_DIAG_TOT_EXTC','WVHT','WVPER','WVDIR'};
% short_names={'TAUB','SAL','TEMP','LIGHT','PAR','Vx','Vy','EXTC','WVHT','WVPER','WVDIR'};
% long_names={'bottom stress', 'salinity','temperature',...
%     'light','Photosynthetically active radiation','Vx','Vy','EXTC','WVHT','WVPER','WVDIR'};
% units ={'N/m2','PSU','degree C','W/m2','W/m2','m/s','m/s','/m','m','s','degress'};

% sitenames={'center','nearshore'};
% siteX=[115.7265 115.7697];
% siteY=[-32.1927 -32.1811];

sitesheet='./GPS_sites_OASIM.xlsx';

[num,txt,raw]=xlsread(sitesheet,'B2:C3');
sitenames={'CS','offshore'};
for t=1:length(sitenames)
  %  tmp=txt{t};
  %  C=strsplit(tmp,',');
    siteX(t)=num(t,2); %str2double(C{2});
    siteY(t)=num(t,1);
    
    distx=cellx-siteX(t);
    disty=celly-siteY(t);
    distt=sqrt(distx.^2+disty.^2);
    
    inds=find(distt==min(distt));
    siteI(t)=inds(1);
    siteD(t)=dat.D(inds(1));
end

%%

readdata=1;

if readdata

for ll=1:length(loadnames)
    loadname=loadnames{ll};
    disp(['loading ',loadname,' ...']);
    tic;
    
  %  if ll>=9
  %  rawData=load_AED_vars(ncfile,2,loadname,allvars);
  %  else
        rawData=load_AED_vars(ncfile,1,loadname,allvars);
  %  end
    
    for site=1:length(sitenames)
        disp(sitenames{site});
             tmp = tfv_getmodeldatalocation(ncfile(1).name,rawData.data,siteX(site),siteY(site),{loadname});
             output.(sitenames{site}).(loadname)=tmp;
    end
    
    toc;
end

save('extracted_OASIM_2022.mat','output','-mat','-v7.3');

else
    load extracted_OASIM_2022.mat;
end

% %% Export to NetCDF
% %layers=[24 17];
% 
% for site=1:length(sitenames)
%     
%     outfile = ['CS_bottom_property_',sitenames{site},'.nc'];
% 
% ncid=netcdf.create(outfile,'NC_NOCLOBBER');
% %lon_dimID = netcdf.defDim(ncid,'Nx',156);
% %depth_dimID = netcdf.defDim(ncid,'Ny',layers(site));
% time_dimID = netcdf.defDim(ncid,'time',...
%     netcdf.getConstant('NC_UNLIMITED'));
% 
%     varidTIME = netcdf.defVar(ncid,'time','NC_DOUBLE',time_dimID);
%     netcdf.putAtt(ncid,varidTIME,'units','time in days since 01/01/2022 00:00:00');
%     netcdf.putAtt(ncid,varidTIME,'longname','time');
%     netcdf.putAtt(ncid,varidTIME,'reference_time','01/01/2022 00:00:00');
%     netcdf.putAtt(ncid,varidTIME,'tz','UTC+08');
% %     
% %     varidD = netcdf.defVar(ncid,'depth','NC_DOUBLE',depth_dimID);
% %     netcdf.putAtt(ncid,varidTIME,'units','m');
% %     netcdf.putAtt(ncid,varidTIME,'longname','depth');
% 
%     
%     
% for ll=1:length(loadnames)
%     varidTIME = netcdf.defVar(ncid,short_names{ll},'NC_DOUBLE',time_dimID);
%     netcdf.putAtt(ncid,varidTIME,'units',units{ll});
%     netcdf.putAtt(ncid,varidTIME,'longname',long_names{ll});
%     netcdf.putAtt(ncid,varidTIME,'AED_name',loadnames{ll});
% 
% end
% 
% netcdf.close(ncid);
% 
% 
% ncwrite(outfile,'time',output.(sitenames{site}).(loadnames{1}).date-datenum(2022,1,1));
% %ncwrite(outfile,'depth',output.(sitenames{site}).(loadnames{1}).depths);
% 
% for ll=1:length(loadnames) 
%     ncwrite(outfile,short_names{ll},output.(sitenames{site}).(loadnames{ll}).bottom);
% end
% 
% end
