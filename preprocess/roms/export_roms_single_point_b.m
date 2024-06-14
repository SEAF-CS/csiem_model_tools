clear all; close all;fclose all;

resdir = 'W:\Work\ROMS\';
fname = 'W:\Work\Climate_scenario\CMIP6_SSP585\CWA_subset_2035_2039.nc';




% grid_file = 'grid.nc';

flat = -31.9896;
flon = 115.3852;

S(1).Lat = flat;
S(1).Lon = flon;
S(1).Name = 'My Point';
S(1).Geometry = 'Point';

% tstart  = datenum(2022,01,01); % starting time of download
% %tstart  = datenum(2011,05,03); % starting time of download
% tfinish  = datenum(2022,12,31); % end time of download
% times = tstart:tfinish;

% gridfil = [resdir grid_file];
% 
% grid.s_rho= ncread(gridfil, 's_rho');
% grid.h= ncread(gridfil, 'h');
% grid.sigma = -1*grid.s_rho;
grid.lat = ncread(fname,'lat_rho');
grid.lon = ncread(fname,'lon_rho');

glat = grid.lat(:);
glon = grid.lon(:);
for bb = 1:length(glat)
    SS(bb).Lat = glat(bb);
    SS(bb).Lon = glon(bb);
    SS(bb).ID = bb;
    SS(bb).Geometry = 'Point';
end
shapewrite(SS,'ROMAClim.shp');

% grid.lat_u = ncread(gridfil,'lat_u');
% grid.lon_u = ncread(gridfil,'lon_u');
% grid.lat_v = ncread(gridfil,'lat_v');
% grid.lon_v = ncread(gridfil,'lon_v');

[k,dist] = dsearchn([glat glon],[flat flon]);

[row,col] = ind2sub(size(grid.lat),k);


S(2).Lat = grid.lat(row,col);
S(2).Lon = grid.lon(row,col);
S(2).Name = 'ROMS Point';
S(2).Geometry = 'Point';


fid = fopen('NRSROT_ROMS_Export_CMIP6_SSP585_CWA_subset_2035_2039.csv','wt');
fprintf(fid,'Date,Salinity Surface,Salinity Bottom,Salinity Mean,Temperature Surface,Temperature Bottom,Temperature Mean\n');


    % resfil = [resdir strrep(fname, 'XXXX',datestr(times(time_i),'yyyymmdd'))];
    % disp(resfil);
    timet = ncread(fname,'ocean_time')./(24*3600) +  datenum(2000,1,1);

    salt = ncread(fname, 'salt');
    temp = ncread(fname, 'temp');
    
    for k = 1:length(timet)

        saltdata = squeeze(salt(row,col,:,k));
        tempdata = squeeze(temp(row,col,:,k));   

        sss = find(~isnan(saltdata)==1);
        ttt = find(~isnan(tempdata)==1);


        fprintf(fid,'%s,%4.4f,%4.4f,%4.4f,%4.4f,%4.4f,%4.4f\n',datestr(timet(k),'dd-mm-yyyy HH:MM:SS'),saltdata(sss(end)),saltdata(sss(1)),mean(saltdata(sss)),tempdata(ttt(end)),tempdata(ttt(1)),mean(tempdata(ttt)));
    end

    clear functions;
