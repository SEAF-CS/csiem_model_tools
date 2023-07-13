clear; close all;

swanVars={'Hsig','Dir','TPsmoo'};
wwmVars= {'HS','DM','TPP'};
names =  {'Sig-Height','Direction','Peak-period'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period'};

%swanFile= 'W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\bc_repo\3_waves\SWAN\A_HIND_2013_combined_base.nc';
%swan.Xp=ncread(swanFile,'Xp');
%swan.Yp=ncread(swanFile,'Yp');

% define WWM regional output paths
inDir='D:\WWM_REG\2013\';
files=dir([inDir,'*.nc']);

% get lon and lat
wwmFile='D:\WWM_REG\grid.nc';  %[inDir,files(1).name];
lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

% define the interp grids for output
minlon=115.2; maxlon=115.9;
minlat=-32.8; maxlat=-31.5;
int=0.0045;

newlon=minlon:int:maxlon;
newlat=minlat:int:maxlat;

[Xp, Yp]=meshgrid(newlon,newlat);
Xp=Xp';Yp=Yp';

% boundary shape
Boundary='E:\database\MARVL\examples\Cockburn_Sound\GIS\Boundary.shp';
BS=shaperead(Boundary);

% add a patch for missing grids outside the Cockburn model domain boundary
patchxx=[115.691 115.322 115.322 115.605 NaN];
patchyy=[-31.666 -31.666 -32.674 -32.674 NaN];

inds1=inpolygon(Xp,Yp,BS.X,BS.Y);
inds2=inpolygon(Xp,Yp,patchxx,patchyy);
inds=inds1+inds2;

% read in and interpolate the wave data
readdata=1;
inc=1;

if readdata
    
    for ff=1:length(files)-1
        wwmFile=[inDir,files(ff).name];
        disp(wwmFile);
        oceantime=datenum(1858,11,17)+ncread(wwmFile,'ocean_time')/86400;
        
        for tt=1:length(oceantime)
            disp(datestr(oceantime(tt),'yyyymmddHH'));
            output.time(inc)=oceantime(tt);
            for vv=1:3
                
                tmpW=ncread(wwmFile,wwmVars{vv},[1 tt],[Inf 1]);
                F=scatteredInterpolant(lon, lat, double(tmpW));
                
                newHS=F(Xp,Yp);
                newHS(~inds)=NaN;
                
                output.(swanVars{vv})(:,:,inc)=newHS;
                output.(wwmVars{vv})(:,tt)=tmpW;
                
            end
            inc=inc+1;
        end
    end
    save('output_Agrid.mat','output','-mat','-v7.3');
    
else
    
    load('output_Agrid.mat');
    
end
%% Export to NetCDF

outfile = 'WWM_SWAN_CONV_Agrid.nc';

ncid=netcdf.create(outfile,'NC_NOCLOBBER');
lon_dimID = netcdf.defDim(ncid,'Nx',156);
lat_dimID = netcdf.defDim(ncid,'Ny',289);
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

%varidUbot = netcdf.defVar(ncid,'Ubot','NC_FLOAT',[lon_dimID,lat_dimID,time_dimID]);
%netcdf.putAtt(ncid,varidUbot,'units','m/s');

netcdf.close(ncid);


ncwrite(outfile,'Xp',Xp);
ncwrite(outfile,'Yp',Yp);

newtime=(output.time-datenum(1990,1,1))*24;
ncwrite(outfile,'time',newtime);
ncwrite(outfile,'Hsig',output.Hsig);
ncwrite(outfile,'Dir',output.Dir);
ncwrite(outfile,'TPsmoo',output.TPsmoo);
%ncwrite(outfile,'Ubot',output.Ubot);

%% option to check outputs
plotting=0;

if plotting
    gcf=figure;
    set(gcf,'Position',[100 100 1500 1000]);
    set(0,'DefaultAxesFontSize',15);
    
    limLow = [0 0 0 0];
    limHigh= [4 360 20 2];
    
    xlimi=[115.0 116.0];
    ylimi=[-33. -31.3];
    
    for vv=1:3
        clf;
        
        subplot(1,2,1);
        newHS=output.(swanVars{vv})(:,:,1);
        
        %pcolor(Xp,Yp,squeeze(newHS(:,:,1))); shading flat;
        tmpv=squeeze(newHS(:,:,1));
        scatter(Xp(:),Yp(:),1,tmpv(:),'filled');
        axis equal;
        %caxis([limLow(vv) limHigh(vv)]);
        colorbar;
        box on;
        set(gca,'xlim',xlimi,'ylim',ylimi);
        title([swanVars{vv},': ',names2{vv}]);
        
        subplot(1,2,2);
        
        scatter(lon,lat,1,output.(wwmVars{vv})(:,1),'filled');
        axis equal;
       % caxis([limLow(vv) limHigh(vv)]);
        colorbar;
        box on;
        set(gca,'xlim',xlimi,'ylim',ylimi);
        
        title([wwmVars{vv},': ',names2{vv}]);
        
        print(gcf,['Agrid_',datestr(oceantime(tt),'yyyymmddHH'),'_INTERPOLATION_',names{vv},'.png'],'-dpng');
        
    end
    
end