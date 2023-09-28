clear; close all;

%% this script is to process the WWM wave data into TFV boundary conditions
%  for Cockburn Sound. The exports are in yearly basis with 2-month spinup
%  time, except for year 2010 which only have one year data

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};

inDir='D:\WWM\';

wwmFile='D:\WWM\2010\his_20100101.nc';
lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

minlon=115.67; maxlon=115.78;
minlat=-32.28; maxlat=-32.135;
int=0.00045;

newlon=minlon:int:maxlon;
newlat=minlat:int:maxlat;

[Xp, Yp]=meshgrid(newlon,newlat);
Xp=Xp';Yp=Yp';
Boundary='E:\database\MARVL\examples\Cockburn_Sound\GIS\Boundary.shp';
BS=shaperead(Boundary);

inds1=inpolygon(Xp,Yp,BS.X,BS.Y);
inds=inds1; %+inds2;

%%

years2pro={'2010','2011','2012','2013','2014','2015','2016','2017','2018',...
    '2019','2020','2021','2022'};

for yy=1:length(years2pro)
    
    inc=1;
    
    if yy>1
        m2p={[years2pro{yy-1},'\his_',years2pro{yy-1},'11'],[years2pro{yy-1},'\his_',years2pro{yy-1},'12'],[years2pro{yy},'\his_',years2pro{yy},'01'],...
            [years2pro{yy},'\his_',years2pro{yy},'02'],[years2pro{yy},'\his_',years2pro{yy},'03'],[years2pro{yy},'\his_',years2pro{yy},'04'],...
            [years2pro{yy},'\his_',years2pro{yy},'05'],[years2pro{yy},'\his_',years2pro{yy},'06'],[years2pro{yy},'\his_',years2pro{yy},'07'],...
            [years2pro{yy},'\his_',years2pro{yy},'08'],[years2pro{yy},'\his_',years2pro{yy},'09'],[years2pro{yy},'\his_',years2pro{yy},'10'],...
            [years2pro{yy},'\his_',years2pro{yy},'11'],[years2pro{yy},'\his_',years2pro{yy},'12']};
    else
        m2p={[years2pro{yy},'\his_',years2pro{yy},'01'],...
            [years2pro{yy},'\his_',years2pro{yy},'02'],[years2pro{yy},'\his_',years2pro{yy},'03'],[years2pro{yy},'\his_',years2pro{yy},'04'],...
            [years2pro{yy},'\his_',years2pro{yy},'05'],[years2pro{yy},'\his_',years2pro{yy},'06'],[years2pro{yy},'\his_',years2pro{yy},'07'],...
            [years2pro{yy},'\his_',years2pro{yy},'08'],[years2pro{yy},'\his_',years2pro{yy},'09'],[years2pro{yy},'\his_',years2pro{yy},'10'],...
            [years2pro{yy},'\his_',years2pro{yy},'11'],[years2pro{yy},'\his_',years2pro{yy},'12']};
    end
    
    for mm=1:length(m2p)
        
        files=dir([inDir,m2p{mm},'*.nc']);
        if yy>1 && mm<3
            inDir0=[inDir,years2pro{yy-1},'\'];
        else
            inDir0=[inDir,years2pro{yy},'\'];
        end
        
        for ff=1:length(files)
            wwmFile=[inDir0,files(ff).name];
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
                    %  output.(wwmVars{vv})(:,tt)=tmpW;
                    
                end
                inc=inc+1;
            end
        end
       
    end
    %% Export to NetCDF
    
    outfile = ['WWM_SWAN_CONV_Cgrid_',years2pro{yy},'.nc'];
    
    %copyfile(tempFile, outfile);
    
    ncid=netcdf.create(outfile,'NC_NOCLOBBER');
    lon_dimID = netcdf.defDim(ncid,'Nx',245);
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
    
    %%
    plotting=1;
    
    if plotting
        gcf=figure;
        set(gcf,'Position',[100 100 1500 1000]);
        set(0,'DefaultAxesFontSize',15);
        
        limLow = [0 0 0 0];
        limHigh= [4 360 20 2];
        
        xlimi=[115.67 115.78];
        ylimi=[-32.28 -32.13];
        
        for vv=1:4
            clf;

            newHS=output.(swanVars{vv})(:,:,24);
            
            %pcolor(Xp,Yp,squeeze(newHS(:,:,1))); shading flat;
            tmpv=squeeze(newHS(:,:,1));
            scatter(Xp(:),Yp(:),1,tmpv(:),'filled');
            axis equal;
            caxis([limLow(vv) limHigh(vv)]);
            colorbar;
            box on;
            set(gca,'xlim',xlimi,'ylim',ylimi);
            title([swanVars{vv},': ',names2{vv}]);
            
            print(gcf,['Cgrid_',datestr(oceantime(tt),'yyyymmddHH'),'_INTERPOLATION_',names{vv},'.png'],'-dpng');
            
        end
        
    end
    save(['output_Cgrid_',years2pro{yy},'.mat'],'output','-mat','-v7.3');
    clear output;
end