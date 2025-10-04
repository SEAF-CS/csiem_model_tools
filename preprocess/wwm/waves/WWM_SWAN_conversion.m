clear; close all;

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};

swanFile= 'W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\bc_repo\3_waves\SWAN\B_HIND_2013_combined_base.nc';
swan.Xp=ncread(swanFile,'Xp');
swan.Yp=ncread(swanFile,'Yp');

wwmFile='W:\csiem\Model\WAVES\his_20140101.nc';
lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');
oceantime=datenum(1858,11,17)+ncread(wwmFile,'ocean_time')/86400;

minlon=min(lon); maxlon=max(lon);
minlat=min(lat); maxlat=max(lat);
int=0.001;

newlon=minlon:int:maxlon;
newlat=minlat:int:maxlat;

[Xp, Yp]=meshgrid(newlon,newlat);
Xp=Xp';Yp=Yp';
Boundary='E:\database\MARVL\examples\Cockburn_Sound\GIS\Boundary.shp';
BS=shaperead(Boundary);

patchxx=[115.4000 115.4000 115.6930 115.6930 115.6700 NaN];
patchyy=[-31.6336 -31.8151 -31.8151 -31.6676 -31.6336 NaN];

inds1=inpolygon(Xp,Yp,BS.X,BS.Y);
inds2=inpolygon(Xp,Yp,patchxx,patchyy);
inds=inds1+inds2;

for tt=1:length(oceantime)
    disp(datestr(oceantime(tt),'yyyymmddHH'));
    for vv=1:4

    tmpW=ncread(wwmFile,wwmVars{vv},[1 tt],[Inf 1]);
    F=scatteredInterpolant(lon, lat, double(tmpW));

    newHS=F(Xp,Yp);
    newHS(~inds)=NaN;
    
    output.(swanVars{vv})(:,:,tt)=newHS;
 %   output.(wwmVars{vv})(:,tt)=tmpW;
    
    end
end

%%

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