clear; close all;

IMOS=load('..\..\datasets\processed_IMOS_udates.mat');
DWER=load('..\..\datasets\processed_DWER_udates.mat');
ROMS=load('E:\CS_BC\datasets\ROMS\ROMS_merged_2001_2023.mat');
%CSIRO=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_CSIRO_public.mat');

vars={'SAL','TEMP'};

IMOS.dataout.SAL.Data(2835:2890)=NaN;
IMOS.dataout.SAL.Data(IMOS.dataout.SAL.Data==35.6449)=NaN;
IMOS.dataout.SAL.Data(3296:3385)=NaN;

IMOSdate=IMOS.dataout.SAL.Date;
IMOSdata=IMOS.dataout.SAL.Data;

ROMSdate=ROMS.merged.site1.time;
ROMSdata=ROMS.merged.site1.SAL;

DWERdate=DWER.dataout.SAL.Date;
DWERdata=DWER.dataout.SAL.Data;

ROMSdate2=ROMS.merged.site2.time;
ROMSdata2=ROMS.merged.site2.SAL;

[datelt, IMOSsbias, newIMOSSAL]=find_monthly_bias(IMOSdate, IMOSdata, ROMSdate, ROMSdata);
[~, DWERsbias, newDWERSAL]=find_monthly_bias(DWERdate, DWERdata, ROMSdate2, ROMSdata2);

%%
bias.offshore.time=datelt;
bias.offshore.factor=IMOSsbias;

bias.nearshore.time=datelt;
bias.nearshore.factor=DWERsbias;

save('OBS_salinity_bias_factor.mat','bias','-v7.3');
%%

romsfile='ROMS_UTC+8_20220101_20221231.nc';
lon=ncread(romsfile,'lon');
lat=ncread(romsfile,'lat');

[LON2, LAT2]=meshgrid(lon,lat);

shp=shaperead('E:\CS_BC\shapefile\merged_6OBC.shp');

for i=1:6
   inds.(['poly',num2str(i)])=inpolygon(LON2', LAT2', shp(i).X, shp(i).Y);
end

SAL=ncread(romsfile,'salinity');

time=ncread(romsfile,'time')/24+datenum(1990,1,1);
dvec1=datevec(time);

time2=datelt;
dvec2=datevec(time2);

%%

SAL2=SAL;

for j=1:length(time)

    tmpind=find(dvec2(:,1)==dvec1(j,1) & dvec2(:,2)==dvec1(j,2));
    fac1=IMOSsbias(tmpind);
    fac2=DWERsbias(tmpind);

    disp(datestr(time2(tmpind)));
    disp(fac1);disp(fac2);

    for k=1:39
        for i=1:6
    
            tmpsal=SAL(:,:,k,j);
            tmpsal=squeeze(tmpsal(:,:,1,1));
            tmpsal2=tmpsal;

            if (i>1 || i<6)
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*fac1;
            else
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*fac2;
            end

        end

        SAL2(:,:,k,j)=tmpsal2;
    end
end

%%
outfile='ROMS_UTC+8_20220101_20221231_bias_correction.nc';
ncwrite(outfile,'salinity',SAL2);

%%





