clear; close all;

%% this script is to process the WWM wave data into TFV boundary conditions
%  for Cockburn Sound. The exports are in yearly basis with 2-month spinup
%  time, except for year 2010 which only have one year data

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};

inDir='.\exported_Bgrid_monthly\';

wwmFile='D:\WWM\2010\his_20100101.nc';
lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

minlon=min(lon); maxlon=max(lon);
minlat=min(lat); maxlat=max(lat);
int=0.0025;

newlon=minlon:int:maxlon;
newlat=minlat:int:maxlat;

[Xp, Yp]=meshgrid(newlon,newlat);
Xp=Xp';Yp=Yp';

%%

years2pro={'2010','2011','2012','2013','2014','2015','2016','2017','2018',...
    '2019','2020','2021','2022'};

for yy=10:length(years2pro)

    if yy>1
        m2p={[years2pro{yy-1},'11'],[years2pro{yy-1},'12'],[years2pro{yy},'01'],...
            [years2pro{yy},'02'],[years2pro{yy},'03'],[years2pro{yy},'04'],...
            [years2pro{yy},'05'],[years2pro{yy},'06'],[years2pro{yy},'07'],...
            [years2pro{yy},'08'],[years2pro{yy},'09'],[years2pro{yy},'10'],...
            [years2pro{yy},'11'],[years2pro{yy},'12']};
    else
        m2p={[years2pro{yy},'01'],...
            [years2pro{yy},'02'],[years2pro{yy},'03'],[years2pro{yy},'04'],...
            [years2pro{yy},'05'],[years2pro{yy},'06'],[years2pro{yy},'07'],...
            [years2pro{yy},'08'],[years2pro{yy},'09'],[years2pro{yy},'10'],...
            [years2pro{yy},'11'],[years2pro{yy},'12']};
    end
    
    for mm=1:length(m2p)
            wwmFile=[inDir,'output_Bgrid_',m2p{mm},'.mat'];
            disp(wwmFile);
            tmp=load(wwmFile);
            
            if mm==1
                output=tmp.output;
            else
                ll1=length(output.time);
                ll2=length(tmp.output.time);
                output.time(ll1+1:ll1+ll2)=tmp.output.time;
                
                for vv=1:length(swanVars)
                    output.(swanVars{vv})(:,:,ll1+1:ll1+ll2)=tmp.output.(swanVars{vv});
                end
                
            end
            clear tmp;
    end

%% Export to NetCDF

outfile = ['WWM_SWAN_CONV_Bgrid_',years2pro{yy},'.nc'];

%copyfile(tempFile, outfile);

ncid=netcdf.create(outfile,'NC_NOCLOBBER');
lon_dimID = netcdf.defDim(ncid,'Nx',205);
lat_dimID = netcdf.defDim(ncid,'Ny',323);
time_dimID = netcdf.defDim(ncid,'time',...
    netcdf.getConstant('NC_UNLIMITED'));

varidXP = netcdf.defVar(ncid,'Xp','NC_FLOAT',[lon_dimID,lat_dimID]);
netcdf.putAtt(ncid,varidXP,'units','degrees');
varidYP = netcdf.defVar(ncid,'Yp','NC_FLOAT',[lon_dimID,lat_dimID]);
netcdf.putAtt(ncid,varidYP,'units','degrees');

varidTIME = netcdf.defVar(ncid,'time','NC_DOUBLE',time_dimID);
netcdf.putAtt(ncid,varidTIME,'units','time in hours since 01/01/1990 00:00:00');
netcdf.putAtt(ncid,varidTIME,'longname','time');
netcdf.putAtt(ncid,varidTIME,'reference_time','01/01/1990 00:00:00');

varidDIR = netcdf.defVar(ncid,'Dir','NC_FLOAT',[lon_dimID,lat_dimID,time_dimID]);
netcdf.putAtt(ncid,varidDIR,'units','degrees');

varidHS = netcdf.defVar(ncid,'Hsig','NC_FLOAT',[lon_dimID,lat_dimID,time_dimID]);
netcdf.putAtt(ncid,varidHS,'units','m');

varidTP = netcdf.defVar(ncid,'TPsmoo','NC_FLOAT',[lon_dimID,lat_dimID,time_dimID]);
netcdf.putAtt(ncid,varidTP,'units','s');

varidUbot = netcdf.defVar(ncid,'Ubot','NC_FLOAT',[lon_dimID,lat_dimID,time_dimID]);
netcdf.putAtt(ncid,varidUbot,'units','m/s');

netcdf.close(ncid);


ncwrite(outfile,'Xp',Xp);
ncwrite(outfile,'Yp',Yp);

newtime=(output.time-datenum(1990,1,1))*24;
ncwrite(outfile,'time',newtime);
ncwrite(outfile,'Hsig',output.Hsig);
ncwrite(outfile,'Dir',output.Dir);
ncwrite(outfile,'TPsmoo',output.TPsmoo);
%ncwrite(outfile,'Ubot',output.Ubot);

%%
plotting=1;

if plotting
    gcf=figure;
    set(gcf,'Position',[100 100 1500 1000]);
    set(0,'DefaultAxesFontSize',15);
    
    limLow = [0 0 0 0];
    limHigh= [4 360 20 2];
    
    xlimi=[115.3 115.92];
    ylimi=[-32.45 -31.6];
    
    for vv=1:4
        clf;
        
        newHS=output.(swanVars{vv})(:,:,24);
        
        pcolor(Xp,Yp,squeeze(newHS(:,:,1))); shading flat;
        axis equal;
        caxis([limLow(vv) limHigh(vv)]);
        colorbar;
        box on;
        %set(gca,'xlim',xlimi,'ylim',ylimi);
        title([swanVars{vv},': ',names2{vv}]);
        
        print(gcf,[datestr(output.time(24),'yyyymmddHH'),'_INTERPOLATION_',names{vv},'.png'],'-dpng');
        
    end
    
end
    save(['output_Bgrid_',years2pro{yy},'.mat'],'output','-mat','-v7.3');
    clear output;
end