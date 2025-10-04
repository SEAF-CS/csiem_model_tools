clear; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\Updated\';

for yy=2001:2023

%     if yy==2015
%       infile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\ROMS_UTC+8_20150101_20160101.nc';
%     elseif yy==2022
%       infile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\ROMS_UTC+8_20220101_20221231.nc';
%     else
    infile=[inDir,'ROMS_UTC+8_',num2str(yy-1,'%4d'),'1001_',num2str(yy,'%4d'),'1231.nc'];
%     end
    disp(infile);

    lon=ncread(infile,'lon');
    lat=ncread(infile,'lat');
    depth=ncread(infile,'depth');
    time=ncread(infile,'time')/24+datenum(1990,1,1);

    lons=[115.4167 115.6850 115.5583 115.3650 115.2217];
    lats=[-32.0000 -32.3410 -31.5367 -31.6183 -31.6817];  

    for i=1:length(lons)

        ind1=find(abs(lon-lons(i))==min(abs(lon-lons(i))));
        ind2=find(abs(lat-lats(i))==min(abs(lat-lats(i))));

        if yy==2001
        disp(ind1);disp(ind2);
        end

        sal2=ncread(infile,'salinity',[ind1 ind2 1 1],[1 1 Inf Inf]);
        sal2=squeeze(sal2(1,1,:,:));

        temp2=ncread(infile,'water_temp',[ind1 ind2 1 1],[1 1 Inf Inf]);
        temp2=squeeze(temp2(1,1,:,:));

        outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).time=time;
        outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).depth=depth;
        outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).SAL=sal2;
        outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).TEMP=temp2;
    end

end

save('ROMS_site_profiles_2001_2023.mat','outdata','-mat');