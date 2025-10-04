clear; close all;
%addpath(genpath('W:\csiem\csiem-marvl\'))

ncfile(1).name='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_OBC_2023_waves_scale_WQ.nc';

allvars = tfv_infonetcdf(ncfile(1).name);
NumBands=16;
inc=1;

for i=1:length(allvars)
     var=allvars{i};

     if strfind(var,'WQ_DIAG_OAS_')>0
         loadnames{inc}=var; inc=inc+1;
     end
end

loadnames{inc}='WQ_DIAG_PHY_TCHLA';inc=inc+1;
loadnames{inc}='WQ_OGM_POC';inc=inc+1;
loadnames{inc}='WQ_OGM_DOC';inc=inc+1;
loadnames{inc}='WQ_NCS_SS1';inc=inc+1;

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

    tmp=find(dat.idx2==siteI(t));
    NLEV(t)=length(tmp);
end


