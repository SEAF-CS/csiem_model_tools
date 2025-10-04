clear;close all;

swanFile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\bc_repo\3_waves\SWAN\SWAN_B_2013.nc';
wwmFile='W:\csiem\Model\WAVES\his_20221228.nc';

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
limLow = [0 0 0 0];
limHigh= [4 360 20 2];
swan.Xp=ncread(swanFile,'Xp');
swan.Yp=ncread(swanFile,'Yp');

swan.time=datenum(1970,1,1)+ncread(swanFile,'time')/86400;

lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

oceantime=datenum(1858,11,17)+ncread(wwmFile,'ocean_time')/86400;

%%
figure;

for vv=1:length(swanVars)
    clf;
    tmpS=ncread(swanFile,swanVars{vv},[1 1 8769],[Inf Inf 1]);
    tmpW=ncread(wwmFile,wwmVars{vv},[1 1],[Inf 1]);

subplot(1,2,1);
pcolor(swan.Xp,swan.Yp,tmpS); shading flat;
axis equal;
caxis([limLow(vv) limHigh(vv)]);
colorbar;
box on;
title({['SWAN: ',datestr(swan.time(end),'yyyy-mm-dd HH:MM')],swanVars{vv}});

subplot(1,2,2);
scatter(lon,lat,3,tmpW,'filled');
axis equal;
caxis([limLow(vv) limHigh(vv)]);
colorbar;
box on;
title({['WWM: ',datestr(oceantime(1),'yyyy-mm-dd HH:MM')],wwmVars{vv}});

print(gcf,['comparison_',names{vv},'.png'],'-dpng');

end