clear; close all;

% load in the salinity bias correction factors
load('OBS_salinity_bias_factor.mat');
% define ROMS file to apply the bias correction

inDir='W:/csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\Updated\';
outDir='W:/csiem\Model\TFV\csiem_model_tfvaed_1.5\bc_repo\1_ocean\ROMS\';

files=dir([inDir,'*.nc']);

%%
for f=1 %:length(files)

romsfile=[inDir,files(f).name];
C=split(files(f).name,'.');

outfile=[outDir,C{1},'_bias_correction.nc'];
disp(romsfile);
disp(outfile);
%'W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\Updated\ROMS_UTC+8_20121001_20131231.nc';
% define the output file
%outfile='ROMS_UTC+8_20121001_20131231_bias_correction.nc';

%% Processing
lon=ncread(romsfile,'lon');
lat=ncread(romsfile,'lat');

[LON2, LAT2]=meshgrid(lon,lat);

% find cells within 6 ocean boundary polygons
shp=shaperead('.\shapefile\merged_6OBC.shp');

for i=1:6
   inds.(['poly',num2str(i)])=inpolygon(LON2', LAT2', shp(i).X, shp(i).Y);
end

% modify the salinity based on month and polygons
SAL=ncread(romsfile,'salinity');

time=ncread(romsfile,'time')/24+datenum(1990,1,1);
dvec1=datevec(time);

time2=bias.offshore.time;
dvec2=datevec(time2);

%SAL2=SAL;

for j=1:length(time)
    % find the factor in corresponding time
    tmpind=find(dvec2(:,1)==dvec1(j,1) & dvec2(:,2)==dvec1(j,2));
    fac1=bias.offshore.factor(tmpind);
    fac2=bias.nearshore.factor(tmpind);

    if mod(j,100)==0
        disp(datestr(time(j)));
        disp(datestr(time2(tmpind)));
        disp(fac1);disp(fac2);
    end
  

   % go through each layer and polygon to modify salinity
    for k=1:39

            tmpsal=SAL(:,:,k,j);
            tmpsal=squeeze(tmpsal(:,:,1,1));
            tmpsal2=tmpsal;

        for i=1:6

            if (i==1 || i==6)
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*fac2;
            elseif (i==3 || i==4)
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*fac1;
            else
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*(fac1+fac2)/2;
            end

        end

        SAL(:,:,k,j)=tmpsal2;
    end
end

%% write output 
copyfile(romsfile, outfile);
ncwrite(outfile,'salinity',SAL);

end






