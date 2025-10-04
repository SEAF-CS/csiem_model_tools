clear; close all;

%% this script is to process the WWM wave data into TFV boundary conditions
%  for Cockburn Sound. The exports are in yearly basis with 2-month spinup
%  time, except for year 2010 which only have one year data

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};

inDir1='W:\csiem\Model\WAVES\WWM\2022\';
inDir2='W:\csiem\Model\WAVES\WAVES\2023_addition\';
inDir3='W:\csiem\Model\WAVES\WAVES\2024_addition\';

wwmFile='W:\csiem\Model\WAVES\WAVES\2023_addition\his_20230101.nc';
lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

minlon=min(lon); maxlon=max(lon);
minlat=min(lat); maxlat=max(lat);
int=0.0025;

newlon=minlon:int:maxlon;
newlat=minlat:int:maxlat;

[Xp, Yp]=meshgrid(newlon,newlat);
Xp=Xp';Yp=Yp';
Boundary='.\GIS\Boundary.shp';
BS=shaperead(Boundary);

patchxx=[115.4000 115.4000 115.6930 115.6930 115.6700 NaN];
patchyy=[-31.6336 -31.8151 -31.8151 -31.6676 -31.6336 NaN];

inds1=inpolygon(Xp,Yp,BS.X,BS.Y);
inds2=inpolygon(Xp,Yp,patchxx,patchyy);
inds=inds1+inds2;

%%
readdata=0;

if readdata

years2pro={'2022','2023','2024'};

for yy=2
    
    inc=1;
        m2p={['\his_',years2pro{yy-1},'11'],['\his_',years2pro{yy-1},'12'],['\his_',years2pro{yy},'01'],...
            ['\his_',years2pro{yy},'02'],['\his_',years2pro{yy},'03'],['\his_',years2pro{yy},'04'],...
            ['\his_',years2pro{yy},'05'],['\his_',years2pro{yy},'06'],['\his_',years2pro{yy},'07'],...
            ['\his_',years2pro{yy},'08'],['\his_',years2pro{yy},'09'],['\his_',years2pro{yy},'10'],...
            ['\his_',years2pro{yy},'11'],['\his_',years2pro{yy},'12'],...
            ['\his_',years2pro{yy+1},'01'],['\his_',years2pro{yy+1},'02'],['\his_',years2pro{yy+1},'03']};

    for mm=1:length(m2p)

        if mm<=2
            inDir0=inDir1;
        elseif mm>=15
            inDir0=inDir3;
        else
            inDir0=inDir2;
        end
            files=dir([inDir0,m2p{mm},'*.nc']);

%         if yy>1 && mm<3
%             inDir0=[inDir,years2pro{yy-1},'\'];
%         else
%             inDir0=[inDir,years2pro{yy},'\'];
%         end
        
        
        for ff=1:length(files)
            wwmFile=[inDir0,files(ff).name];
            disp(wwmFile);
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
        
    end
end
save(['output_Bgrid_',years2pro{yy},'.mat'],'output','-mat','-v7.3');

else
    years2pro={'2022','2023','2024'}; yy=2;
load(['output_Bgrid_',years2pro{yy},'.mat']);
end
%% Export to NetCDF

outfile = ['WWM_SWAN_CONV_Bgrid_',years2pro{yy},'.nc'];

%copyfile(tempFile, outfile);
if exist(outfile,'file')
    delete(outfile);
end

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
%     
%     clear output;
% end