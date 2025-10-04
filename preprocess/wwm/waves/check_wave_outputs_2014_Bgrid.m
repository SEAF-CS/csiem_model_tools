clear;close all;

swanFile= 'W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\bc_repo\3_waves\SWAN\B_HIND_2013_combined_base.nc';
%'W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\bc_repo\3_waves\SWAN\SWAN_B_2013.nc';
wwmFile='W:\csiem\Model\WAVES\his_20140101.nc';

swanVars={'Hsig','Dir','TPsmoo','Ubot'};
wwmVars= {'HS','DM','TPP','UBOT'};
names =  {'Sig-Height','Direction','Peak-period','UBOT'};
names2 =  {'Significant Wave Height','Wave Direction','Wave Peak Period','Bottom Velocity'};
limLow = [0 0 0 0];
limHigh= [4 360 20 2];
swan.Xp=ncread(swanFile,'Xp');
swan.Yp=ncread(swanFile,'Yp');

swan.time=datenum(1990,1,1)+ncread(swanFile,'time')/24;

lon=ncread(wwmFile,'lon');
lat=ncread(wwmFile,'lat');

oceantime=datenum(1858,11,17)+ncread(wwmFile,'ocean_time')/86400;

%%
gcf=figure;
set(gcf,'Position',[100 100 1500 1000]);
set(0,'DefaultAxesFontSize',15);

xlimi=[115.3 115.92];
ylimi=[-32.45 -31.6];

for tt=0%:7
    
for vv=1%:length(swanVars)
    clf;
    tmpS=ncread(swanFile,swanVars{vv},[1 1 8762+tt],[Inf Inf 1]);
    tmpW=ncread(wwmFile,wwmVars{vv},[1 1+tt],[Inf 1]);

subplot(1,2,1);
pcolor(swan.Xp,swan.Yp,tmpS); shading flat;
axis equal;
caxis([limLow(vv) limHigh(vv)]);
colorbar;
box on;
set(gca,'xlim',xlimi,'ylim',ylimi);
title({['SWAN B-HIND: ',datestr(swan.time(8762+tt),'yyyy-mm-dd HH:MM')],[swanVars{vv},': ',names2{vv}]});

subplot(1,2,2);
scatter(lon,lat,3,tmpW,'filled');
axis equal;
caxis([limLow(vv) limHigh(vv)]);
colorbar;
box on;
set(gca,'xlim',xlimi,'ylim',ylimi);

title({['WWM: ',datestr(oceantime(1+tt),'yyyy-mm-dd HH:MM')],[wwmVars{vv},': ',names2{vv}]});

%print(gcf,[datestr(oceantime(1+tt),'yyyymmddHH'),'_comparison_',names{vv},'.png'],'-dpng');

end

end