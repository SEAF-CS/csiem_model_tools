clear; close all;
%addpath(genpath('W:\csiem\csiem-marvl\'))

outDir='CSIEM20_PHY\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

ncfile(1).name='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\outputs\results\csiem_A001_20221101_20240401_WQ_WQ.nc';

allvars = tfv_infonetcdf(ncfile(1).name);
NumBands=16;
inc=1;
% 
% loadnames{inc}='WQ_DIAG_OAS_ZEN';inc=inc+1;
% loadnames{inc}='WQ_DIAG_OAS_SWR_SF';inc=inc+1;

for i=1:length(allvars)
     var=allvars{i};

     if strfind(var,'WQ_DIAG_PHY_')>0
         loadnames{inc}=var; inc=inc+1;
     end
end
% 
% loadnames{inc}='WQ_DIAG_PHY_TCHLA';inc=inc+1;
% loadnames{inc}='WQ_OGM_POC';inc=inc+1;
% loadnames{inc}='WQ_OGM_DOC';inc=inc+1;
% loadnames{inc}='WQ_NCS_SS1';inc=inc+1;

loadnames2=loadnames';


%%
% sitenames={'center','nearshore'};
% siteX=[115.7265 115.7697];
% siteY=[-32.1927 -32.1811];
dat = tfv_readnetcdf(ncfile(1).name,'timestep',1);
cellx=ncread(ncfile(1).name,'cell_X');
celly=ncread(ncfile(1).name,'cell_Y');

Bottcells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
Bottcells(length(dat.idx3)) = length(dat.idx3);
Surfcells=dat.idx3(dat.idx3 > 0);

sitesheet='./GPS_sites_OASIM.xlsx';

[num,txt,raw]=xlsread(sitesheet,'B2:C10');
sitenames={'Freshwater_Bay','Mullaloo_Beach','West_Rottnest','Owen_Anchorage',...
    'Kwinana_Shelf','Deep_Basin','Mangles_Bay','East_Garden_Island','Validation'};
for t=6 %1:length(sitenames)
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

for ll=1:length(loadnames)
    loadname=loadnames{ll};
    tic;
    
  %  if ll>=9
  %  rawData=load_AED_vars(ncfile,2,loadname,allvars);
  %  else
        rawData=load_AED_vars(ncfile,1,loadname,allvars);
  %  end

  if size(rawData.data.(loadname),1)==length(dat.idx2)
      disp(['loading 3D ',loadname,' ...']);
    
    for site=6 %1:length(sitenames)
        disp(sitenames{site});
             tmp = tfv_getmodeldatalocation(ncfile(1).name,rawData.data,siteX(site),siteY(site),{loadname});
             output.(sitenames{site}).(loadname)=tmp;clear tmp;
    end
  else
      disp(['loading 2D ',loadname,' ...']);
    for site=6 %1:length(sitenames)
        disp(sitenames{site});
        tmp = rawData.data.(loadname)(siteI(site),:);
          %   tmp = tfv_getmodeldatalocation(ncfile(1).name,rawData.data,siteX(site),siteY(site),{loadname});
             output.(sitenames{site}).(loadname)=tmp;clear tmp;
    end
  end

    outfile=[outDir,'extracted_PHY_2023_',loadname,'.mat'];
    save(outfile,'output','-mat','-v7.3');clear output;
    
    toc;
end

