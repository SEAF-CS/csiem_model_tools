clear; close all;

%% this script is to process the WWM wave data into TFV boundary conditions
%  for Cockburn Sound. The exports are in yearly basis with 2-month spinup
%  time, except for year 2010 which only have one year data

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};

inDir='D:\WWM\';
outDir='./exported_Cgrid_monthly/';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

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
    
    m2p={'01','02','03','04','05','06','07','08','09','10','11','12'};
    inDir0=[inDir,years2pro{yy},'\'];
    
    for mm=1:length(m2p)
        output=[];
        inc=1;
        files=dir([inDir0,'his_',years2pro{yy},m2p{mm},'*.nc']);

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
                    %   output.(wwmVars{vv})(:,tt)=tmpW;
                    
                end
                inc=inc+1;
            end
        end
        save([outDir,'output_Cgrid_',years2pro{yy},m2p{mm},'.mat'],'output','-mat','-v7.3');
        clear output;
    end

    
end
