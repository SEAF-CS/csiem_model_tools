clear all; close all;

resdir = 'W:\Work\ROMS\';
fname = 'cwa_XXXX_03__his.nc';
grid_file = 'grid.nc';



S(1).Lat = -22.695109;
S(1).Lon = 113.580141;
S(1).Name = 'Nigaloo_Near_Shore';
S(1).Geometry = 'Point';

S(2).Lat = -22.697182;
S(2).Lon = 111.650886;
S(2).Name = 'Nigaloo_Offshore_Shore';
S(2).Geometry = 'Point';


S(3).Lat = -31.9896;
S(3).Lon = 115.3852;
S(3).Name = 'NRSROT';
S(3).Geometry = 'Point';

tstart  = datenum(2022,01,01); % starting time of download
%tstart  = datenum(2011,05,03); % starting time of download
tfinish  = datenum(2022,12,31); % end time of download
times = tstart:tfinish;

gridfil = [resdir grid_file];

grid.s_rho= ncread(gridfil, 's_rho');
grid.h= ncread(gridfil, 'h');
grid.sigma = -1*grid.s_rho;
grid.lat = ncread(gridfil,'lat_rho');
grid.lon = ncread(gridfil,'lon_rho');

glat = grid.lat(:);
glon = grid.lon(:);
% for bb = 1:length(glat)
%     SS(bb).Lat = glat(bb);
%     SS(bb).Lon = glon(bb);
%     SS(bb).ID = bb;
%     SS(bb).Geometry = 'Point';
% end
% shapewrite(SS,'ROMALL.shp');

% grid.lat_u = ncread(gridfil,'lat_u');
% grid.lon_u = ncread(gridfil,'lon_u');
% grid.lat_v = ncread(gridfil,'lat_v');
% grid.lon_v = ncread(gridfil,'lon_v');

for kk = 1:length(S)





    % S(2).Lat = grid.lat(row,col);
    % S(2).Lon = grid.lon(row,col);
    % S(2).Name = 'ROMS Point';
    % S(2).Geometry = 'Point';

    fid(kk).ID = fopen([S(kk).Name,'_Export_2022.csv'],'wt');
    fprintf(fid(kk).ID,'Date,Salinity Surface,Salinity Bottom,Salinity Mean,Temperature Surface,Temperature Bottom,Temperature Mean\n');
end

for time_i  = 1 :length(times)
    resfil = [resdir strrep(fname, 'XXXX',datestr(times(time_i),'yyyymmdd'))];
    disp(resfil);
    timet = ncread(resfil,'ocean_time')./(24*3600) +  datenum(2000,1,1);

    salt = ncread(resfil, 'salt');
    temp = ncread(resfil, 'temp');

    for k = 1:length(timet)
        for kk = 1:length(S)
            flat = S(kk).Lat;
            flon = S(kk).Lon;

            [kkk,dist] = dsearchn([glat glon],[flat flon]);

            [row,col] = ind2sub(size(grid.lat),kkk);
            saltdata = squeeze(salt(row,col,:,k));
            tempdata = squeeze(temp(row,col,:,k));

            sss = find(~isnan(saltdata)==1);
            ttt = find(~isnan(tempdata)==1);


            fprintf(fid(kk).ID,'%s,%4.4f,%4.4f,%4.4f,%4.4f,%4.4f,%4.4f\n',datestr(timet(k),'dd-mm-yyyy HH:MM:SS'),saltdata(sss(end)),saltdata(sss(1)),mean(saltdata(sss)),tempdata(ttt(end)),tempdata(ttt(2)),mean(tempdata(ttt)));
        end
    end

    clear functions;
end


% shapewrite(S,'ROMS_Export.shp');