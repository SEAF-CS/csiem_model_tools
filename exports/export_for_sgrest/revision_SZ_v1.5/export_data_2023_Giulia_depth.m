clear; close all;
%addpath(genpath('W:\csiem\csiem-marvl\'))

ncfile(1).name='W:\csiem\Model\TFV\csiem_model_tfvaed_1.5_clean\outputs\results\final\BGrid\csiem_B009_20221101_20240401_WQ_WQ.nc';
ncfile(2).name='W:\csiem\Model\TFV\csiem_model_tfvaed_1.5_clean\outputs\results\final\BGrid\csiem_B009_20221101_20240401_WQ_wave.nc';
allvars = tfv_infonetcdf(ncfile(1).name);
dat = tfv_readnetcdf(ncfile(1).name,'timestep',1);
cellx=ncread(ncfile(1).name,'cell_X');
celly=ncread(ncfile(1).name,'cell_Y');

Bottcells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
    Bottcells(length(dat.idx3)) = length(dat.idx3);

    Surfcells=dat.idx3(dat.idx3 > 0);

loadnames={'D'};
short_names={'depth'};
long_names={'depth'};
units ={'m'};

% sitenames={'center','nearshore'};
% siteX=[115.7265 115.7697];
% siteY=[-32.1927 -32.1811];

sitesheet='./GPS_sites_only.xlsx';

[num,txt,raw]=xlsread(sitesheet,'B2:C10');
sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};
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

outDir='.\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end


for ll=1:length(loadnames)
    loadname=loadnames{ll};
    disp(['loading ',loadname,' ...']);
    tic;

        rawData=load_AED_vars(ncfile,1,loadname,allvars);
    
    for site=1:length(sitenames)
        disp(sitenames{site});

             tmp = rawData.data.(loadname)(siteI(site),:);
             output.(sitenames{site}).(loadname)=tmp;

        clear tmp;
    
    end
    
    outfile=[outDir,'extracted_2023_',loadname,'.mat'];
    save(outfile,'output','-mat','-v7.3');clear output;

    toc;
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
