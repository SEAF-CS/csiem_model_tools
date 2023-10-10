
clear; close all;

siteshpFile='D:\github\csiem-data\data-mapping\By Theme\Hydrodynamics\data locations_hydrodynamics_2.shp';
shp=shaperead(siteshpFile);

inc=1;

for ss=1:length(shp)
    if strcmp(shp(ss).Type_Stati,'Wave buoy')
        disp([shp(ss).AgencyID,'-',shp(ss).Site_Name,'-',shp(ss).Type_Stati]);
        sites(inc).AgencyID=shp(ss).AgencyID;
        sites(inc).SiteID=shp(ss).SiteID;
        sites(inc).Latitude=shp(ss).Latitude;
        sites(inc).Longitude=shp(ss).Longitude;
        inc=inc+1;
    elseif (strcmp(shp(ss).Type_Stati,'AWAC (multi-sensor)') && strcmp(shp(ss).AgencyID,'DOT'))
        disp([shp(ss).AgencyID,'-',shp(ss).Site_Name,'-',shp(ss).Type_Stati]);
        sites(inc).AgencyID=shp(ss).AgencyID;
        sites(inc).SiteID=shp(ss).SiteID;
        sites(inc).Latitude=shp(ss).Latitude;
        sites(inc).Longitude=shp(ss).Longitude;
        inc=inc+1;
        
    end
end


%%
% 
% sites={'AWAC1','AWAC2','Cath1','Cath2','DC','Stirling','Parmelia','Rottnest','S01','S02'};
% agencies={'CCL','CCL','CoC','CoC','FPA','FPA','FPA','DoT','JPPL','JPPL'};
% depths=[-14.6,-7.4,-6.5,-8.5,-13.0,-13.8,-9.0,-73.0,-10,-18];
% lons  =[115.704160,  115.679512, 115.728092, 115.745646, 115.686667, 115.744336, 115.701664, 115.407778, 115.762710, 115.730832];
% lats  =[-32.079398,  -32.095191, -32.078775, -32.090541, -31.977779, -32.203214, -32.130005, -32.094167, -32.200942, -32.180925];
% %InGridA =[1 1 1 1 1 1 1 1 1 1];
% %InGridB =[1 1 1 1 1 1 1 0 1 1];
% %InGridC =[0 0 0 0 0 1 0 0 1 1];
 inWWMGRE=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% inWWMLOC=[1 1 1 1 1 1 1 0 1 1];
% %inExpGdA=[1 1 1 1 1 1 1 1 1 1];
% %inExpGdB=[1 1 1 1 1 1 1 0 1 1];
% %inExpGdC=[0 0 0 0 0 1 0 0 1 1];

exportDir='.\wave_export_site_key\';
if ~exist(exportDir,'dir')
    mkdir(exportDir);
end

%% export WWM regional grids


years2pro={'2010','2011','2012','2013','2014','2015','2016','2017','2018',...
    '2019','2020','2021','2022'};

for yy=1:length(years2pro)
    
inDir=['D:\WWM_REG\',years2pro{yy},'\'];
files=dir([inDir,'his_*.nc']);

wwmFile='D:\WWM_REG\grid.nc';  %[inDir,files(1).name];
lonWWM=ncread(wwmFile,'lon');
latWWM=ncread(wwmFile,'lat');

exports=[exportDir,'WWM_REG_sites_',years2pro{yy},'.mat'];
InGrid=inWWMGRE;

disp(wwmFile);
disp(InGrid);

stdvars={'DIR','HS','TPER'};
vars={'DM','HS','TPP'};

for ss=1:length(sites)
    
    if InGrid(ss)==1
        slon=sites(ss).Longitude;
        slat=sites(ss).Latitude;
        
        diffx=lonWWM-slon;
        diffy=latWWM-slat;
        difft=diffx.^2+diffy.^2;
        
        inds(ss)=find(abs(difft-min(difft))==min(abs(difft-min(difft))));
        
        disp(sites(ss).SiteID);
        disp(lonWWM(inds(ss)));
        disp(latWWM(inds(ss)));
        
    else
        indy(ss)=NaN;
        indx(ss)=NaN;
        disp([sites(ss).SiteID,' is not in domain']);
        
    end
end

for ff=1:length(files)
    infile=[inDir,files(ff).name];
    disp(infile);
    oceantime=datenum(1858,11,17)+ncread(infile,'ocean_time')/86400;
    
    if ff>1
        l1=length(output.(sites(ss).SiteID).time);
        l2=length(oceantime);
    end
    
    for vv=1:length(stdvars)
        disp(stdvars{vv});
        % tmp=ncread(infile,vars{vv},[indx indy 1],[1 1 Inf]);
        tmp=ncread(infile,vars{vv});
        
        if ff==1
            for ss=1:length(sites)
                if InGrid(ss)==1
                    output.(sites(ss).SiteID).(stdvars{vv})=tmp(inds(ss),:);
                    if vv==1
                        output.(sites(ss).SiteID).time=oceantime;
                    end
                end
                
            end
        else
            
            for ss=1:length(sites)
                if InGrid(ss)==1
                    output.(sites(ss).SiteID).(stdvars{vv})(l1+1:l1+l2)=tmp(inds(ss),:);
                    if vv==1
                        output.(sites(ss).SiteID).time(l1+1:l1+l2)=oceantime;
                    end
                end
                
            end
        end
        clear tmp;
    end
    
end

save(exports,'output','-mat','-v7.3');
clear output;

%% export WWM regional grids

inDir=['D:\WWM\',years2pro{yy},'\'];
files=dir([inDir,'his*.nc']);

wwmFile=[inDir,files(1).name];
lonWWM=ncread(wwmFile,'lon');
latWWM=ncread(wwmFile,'lat');

exports=[exportDir,'WWM_CS_sites_',years2pro{yy},'.mat'];

InGrid=zeros(18,1);
for ss=1:length(sites)
    xxx=sites(ss).Longitude;
    yyy=sites(ss).Latitude;
    
    if (xxx<115.8 && xxx>115.4)
        if (yyy<-31.63 && yyy>-32.43)
            InGrid(ss)=1;
        end
    end
end

disp(wwmFile);
disp(InGrid);

stdvars={'DIR','HS','TPER'};
vars={'DM','HS','TPP'};

for ss=1:length(sites)
    
    if InGrid(ss)==1
        slon=sites(ss).Longitude;
        slat=sites(ss).Latitude;
        
        diffx=lonWWM-slon;
        diffy=latWWM-slat;
        difft=diffx.^2+diffy.^2;
        
        inds(ss)=find(abs(difft-min(difft))==min(abs(difft-min(difft))));
        
        disp(sites(ss).SiteID);
        disp(lonWWM(inds(ss)));
        disp(latWWM(inds(ss)));
        
    else
        indy(ss)=NaN;
        indx(ss)=NaN;
        disp([sites(ss).SiteID,' is not in domain']);
        
    end
end

for ff=1:length(files)
    infile=[inDir,files(ff).name];
    disp(infile);
    oceantime=datenum(1858,11,17)+ncread(infile,'ocean_time')/86400;
    
    if ff>1
        l1=length(output.(sites(ss).SiteID).time);
        l2=length(oceantime);
    end
    
    for vv=1:length(stdvars)
        disp(stdvars{vv});
        % tmp=ncread(infile,vars{vv},[indx indy 1],[1 1 Inf]);
        tmp=ncread(infile,vars{vv});
        
        if ff==1
            for ss=1:length(sites)
                if InGrid(ss)==1
                    output.(sites(ss).SiteID).(stdvars{vv})=tmp(inds(ss),:);
                    if vv==1
                        output.(sites(ss).SiteID).time=oceantime;
                    end
                end
                
            end
        else
            for ss=1:length(sites)
                if InGrid(ss)==1
                    
                    output.(sites(ss).SiteID).(stdvars{vv})(l1+1:l1+l2)=tmp(inds(ss),:);
                    if vv==1
                        output.(sites(ss).SiteID).time(l1+1:l1+l2)=oceantime;
                    end
                end
                
            end
        end
        clear tmp;
    end
    
end

save(exports,'output','-mat','-v7.3');
clear output;

end