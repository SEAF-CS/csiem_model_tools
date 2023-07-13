clear; close all;

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};

%swanFile= 'W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\bc_repo\3_waves\SWAN\C_HIND_2013_combined_base.nc';
%swan.Xp=ncread(swanFile,'Xp');
%swan.Yp=ncread(swanFile,'Yp');

% define the WWM wave files and lon/lat
inDir='D:\WWM\2013\';
files=dir([inDir,'*.nc']);

wwmFile=[inDir,files(1).name];
lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

minlon=min(lon); maxlon=max(lon);
minlat=min(lat); maxlat=max(lat);
int=0.0025;

newlon=minlon:int:maxlon;
newlat=minlat:int:maxlat;

[Xp, Yp]=meshgrid(newlon,newlat);
Xp=Xp';Yp=Yp';

% boundary shape
Boundary='E:\database\MARVL\examples\Cockburn_Sound\GIS\Boundary.shp';
BS=shaperead(Boundary);
% add a patch for missing grids outside the Cockburn model domain boundary
patchxx=[115.4000 115.4000 115.6930 115.6930 115.6700 NaN];
patchyy=[-31.6336 -31.8151 -31.8151 -31.6676 -31.6336 NaN];

inds1=inpolygon(Xp,Yp,BS.X,BS.Y);
inds2=inpolygon(Xp,Yp,patchxx,patchyy);
inds=inds1+inds2;

% read in and interpolate the wave data
readdata=1;
inc=1;

if readdata
    
    for ff=1:length(files)
        wwmFile=[inDir,files(ff).name];
        oceantime=datenum(1858,11,17)+ncread(wwmFile,'ocean_time')/86400;
        
        for tt=1:length(oceantime)
            disp(datestr(oceantime(tt),'yyyymmddHH'));
            output.time(inc)=oceantime(tt);
            for vv=1:4
                
                tmpW=ncread(wwmFile,wwmVars{vv},[1 tt],[Inf 1]);
                F=scatteredInterpolant(lon, lat, double(tmpW));
                
                newHS=F(Xp,Yp);
                newHS(~inds)=NaN;
                
                output.(swanVars{vv})(:,:,inc)=newHS;
                %   output.(wwmVars{vv})(:,tt)=tmpW;
                
            end
            inc=inc+1;
        end
    end
    save('output_Bgrid.mat','output','-mat','-v7.3');
    
else
    
    load('output_Bgrid.mat');
    
end
%% Export to NetCDF

dims.time = [];
dims.Nx = length(newlon);
dims.Ny = length(newlat);

vars.time.nctype = 'NC_DOUBLE';
vars.time.dimensions = 'time';
vars.time.units = 'time in hours since 1990-01-01 00:00:00';
vars.time.longname = 'Time';
vars.time.reference_time = '01/01/1990 00:00:00';

%%
%tempFile='C_HIND_2013_template.nc';
outfile = 'WWM_SWAN_CONV_Bgrid.nc';

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
ncwrite(outfile,'Ubot',output.Ubot);

%% option to check outputs
plotting=0;

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
        
        subplot(1,2,1);
        newHS=output.(swanVars{vv})(:,:,1);
        
        pcolor(Xp,Yp,squeeze(newHS(:,:,1))); shading flat;
        axis equal;
        caxis([limLow(vv) limHigh(vv)]);
        colorbar;
        box on;
        %set(gca,'xlim',xlimi,'ylim',ylimi);
        title([swanVars{vv},': ',names2{vv}]);
        
        subplot(1,2,2);
        
        scatter(lon,lat,3,output.(wwmVars{vv})(:,1),'filled');
        axis equal;
        caxis([limLow(vv) limHigh(vv)]);
        colorbar;
        box on;
        %set(gca,'xlim',xlimi,'ylim',ylimi);
        
        title([wwmVars{vv},': ',names2{vv}]);
        
        print(gcf,[datestr(oceantime(tt),'yyyymmddHH'),'_INTERPOLATION_',names{vv},'.png'],'-dpng');
        
    end
    
end