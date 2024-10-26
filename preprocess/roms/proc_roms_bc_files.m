function proc_roms_bc_files(tstart,tfinish)

tic

addpath(genpath('toolbox'));

%% User input for a
resdir = 'G:\ROMS\';
fname = 'cwa_XXXX_03__his.nc';
fname2 = 'cwa_his_XXXX.nc';
grid_file = 'grid.nc';
%zfile = 'M:\UWA\A11348_Cockburn_Sound_BCG_Model\2Exectn\2Modelling\2TUFLOWFV\model\geo\z_layer\SEP_zlayer_0p25.csv';

xlim = [114.3  115.8];
ylim = [-33.7  -30.5];
zf = [0 2:0.5:5 6:2:14 15:5:50 60:10:90 100:20:180 200:50:400 500:500:2000];
%zlim = [0 5000];
%tstart  = datenum(2001,10,01); % starting time of download
%tstart  = datenum(2011,05,03); % starting time of download
%tfinish  = datenum(2002,12,31); % end time of download
times = tstart:tfinish;
var2extract  = {'zeta', 'u', 'v', 'salt','temp'};
nn = 2; % Horizontal grid coarsening factor.  1 recommended to preserve ROMS resolution
% Higher nn value to reduce processing speed at the expense of resoulion in
% set the initial conditions. nn = 2 is still a good trade-off. Values less
% than 1 will perform the same as 1 and take extremely longer time to
% process
%% User input to b_combine_ROMS.m
% -- INPUT
%addpath(genpath('L:\Z_Matlab\wbm\'));
tag = 'ROMS'; % Name for files, best to include timezone
creator = 'KabirSuara'; % For file metadata
jobno = '11348'; % For file metadata
timezone = 8; % Hours to add to GMT
timezone_Name = 'UTC+8';
inpat = 'G:\ROMS\Inputs\';
outinpat = [inpat 'nc/'];
if ~exist(inpat); mkdir(inpat); end
if ~exist(outinpat); mkdir(outinpat); end
%% Extract grid information
gridfil = [resdir grid_file];
% % grid_var = {'h','s_rho','hc','Cs_r'};
% %
% % for i = 1:length(grid_var)
% %     grid.(grid_var{i}) = ncread(gridfil, grid_var{i});
% % end
grid.s_rho= ncread(gridfil, 's_rho');
grid.h= ncread(gridfil, 'h');
grid.sigma = -1*grid.s_rho;
grid.lat = ncread(gridfil,'lat_rho');
grid.lon = ncread(gridfil,'lon_rho');
grid.lat_u = ncread(gridfil,'lat_u');
grid.lon_u = ncread(gridfil,'lon_u');
grid.lat_v = ncread(gridfil,'lat_v');
grid.lon_v = ncread(gridfil,'lon_v');
%% Trim down domain size before processing
polyx = [min(xlim) min(xlim) max(xlim) max(xlim) min(xlim)];
polyy  = [min(ylim) max(ylim) max(ylim) min(ylim) min(ylim)];

[inpoly, ~] = inpolygon(grid.lon, grid.lat,polyx,polyy);
[row.rho,col.rho] = find(inpoly >0); % Rho bounds
mod.grid.lon = grid.lon(min(row.rho):max(row.rho),min(col.rho):max(col.rho));
mod.grid.lat = grid.lat(min(row.rho):max(row.rho),min(col.rho):max(col.rho));
mod.grid.h = grid.h(min(row.rho):max(row.rho),min(col.rho):max(col.rho));
mod.grid.lon = repmat(mod.grid.lon,1,1,length(grid.sigma));
mod.grid.lat = repmat(mod.grid.lat,1,1,length(grid.sigma));


[inpoly, ~] = inpolygon(grid.lon_u, grid.lat_u,polyx,polyy);
[row.u,col.u] = find(inpoly >0); % u bounds
mod.grid.lon_u = grid.lon_u(min(row.u):max(row.u),min(col.u):max(col.u));
mod.grid.lat_u = grid.lat_u(min(row.u):max(row.u),min(col.u):max(col.u));
mod.grid.lon_u = repmat(mod.grid.lon_u,1,1,length(grid.sigma));
mod.grid.lat_u = repmat(mod.grid.lat_u,1,1,length(grid.sigma));


[inpoly, ~] = inpolygon(grid.lon_v, grid.lat_v,polyx,polyy);
[row.v,col.v] = find(inpoly >0); % v bounds
mod.grid.lon_v = grid.lon_v(min(row.v):max(row.v),min(col.v):max(col.v));
mod.grid.lat_v = grid.lat_v(min(row.v):max(row.v),min(col.v):max(col.v));
mod.grid.lon_v = repmat(mod.grid.lon_v,1,1,length(grid.sigma));
mod.grid.lat_v = repmat(mod.grid.lat_v,1,1,length(grid.sigma));

%% Create three dimesional structured and fixed z grid
%
x = linspace(min(xlim),max(xlim),floor(size(mod.grid.h,1)/nn)); % out x coordinate
y = linspace(min(ylim),max(ylim),floor(size(mod.grid.h,2)/nn)); % out y coordinate

[xx,yy,zz] = ndgrid(x,y,zf); % 3D Structured grid
[xw,yw] = ndgrid(x,y); % 2D grid structure for water level

% get bathymetry of the x,y reular grid
xin = mod.grid.lon(:,:,1);
yin = mod.grid.lat(:,:,1);
zlast_ind = zeros(length(x),length(y));
Fbathy = scatteredInterpolant(xin(:),yin(:),mod.grid.h(:)); % Negeative to turn to depth
bathy = Fbathy(xw,yw);
for ii = 1:size(bathy,1)
    for jj = 1:size(bathy,2)
        [~,ind] = min(abs(zf-bathy(ii,jj)));
        zlast_ind(ii,jj) = ind;
    end
end
%%

for time_i  = 1 :length(times)
    resfil = [resdir strrep(fname, 'XXXX',datestr(times(time_i),'yyyymmdd'))];
    if ~exist(resfil,'file')
        resfil = regexprep(resfil,'_03__','_00__');
    end
    if ~exist(resfil,'file')
        resfil = regexprep(resfil,'_00__','_15__');
    end
    
    if ~exist(resfil,'file')
        resfil = [resdir strrep(fname2, 'XXXX',datestr(times(time_i),'yyyymmdd'))];
        %resfil = regexprep(resfil,'_00__','_15__');
    end


    timet = ncread(resfil,'ocean_time')./(24*3600) +  datenum(2000,1,1);

    filename = [inpat 'ROMS_' datestr(times(time_i),'yyyymmdd') '.mat'];
if ~exist(filename,'file')

    for i = 1:length(var2extract)
        tmp = ncread(resfil, var2extract{i});
        if strcmp(var2extract{i},'zeta')
            mod.(var2extract{i}) = tmp(min(row.rho):max(row.rho),min(col.rho):max(col.rho),:);
        elseif ismember(var2extract{i},{'salt','temp'})
            mod.(var2extract{i}) = tmp(min(row.rho):max(row.rho),min(col.rho):max(col.rho),:,:);
        else
            mod.(var2extract{i}) = tmp(min(row.(var2extract{i})):max(row.(var2extract{i})),min(col.(var2extract{i})):max(col.(var2extract{i})),:,:);
        end
    end
    H = zeros(length(x),length(y),length(timet));
    salt = zeros(length(x),length(y),length(zf),length(timet));
    temp = zeros(length(x),length(y),length(zf),length(timet));
    u = zeros(length(x),length(y),length(zf),length(timet));
    v = zeros(length(x),length(y),length(zf),length(timet));

    for subt_i = 1:length(timet)
        zt  = repmat(zeros(size(mod.grid.h)),1,1,length(grid.s_rho));
        tmz = double(mod.zeta(:,:,subt_i)); % Extract water leve at given time
        tmzz = tmz  + mod.grid.h; % add bathymetry in m

        for lev_i = 1:length(grid.s_rho)
            zt(:,:,lev_i) = tmz + (tmzz)*grid.s_rho(lev_i);
        end
        zin = -1*zt;
        zin_u = -1*zt(1:size(mod.grid.lon_u,1),1:size(mod.grid.lon_u,2),:);  % Negeative to turn to depth
        zin_v = -1*zt(1:size(mod.grid.lon_v,1),1:size(mod.grid.lon_v,2),:);  % Negeative to turn to depth
        % Interpolate Salt
        saltin = mod.salt(:,:,:,subt_i);
        ind = find(~isnan(saltin(:)));
        Fsalt = scatteredInterpolant(mod.grid.lon(ind),mod.grid.lat(ind),zin(ind),saltin(ind)); % Negeative to turn to depth
        Fsalt.ExtrapolationMethod = 'none';
        salt(:,:,:,subt_i) = Fsalt(xx,yy,zz);

        % Interpolate Temperature
        tempin = mod.temp(:,:,:,subt_i);
        ind = find(~isnan(tempin(:))); % Negeative to turn to depth
        Ftemp = scatteredInterpolant(mod.grid.lon(ind),mod.grid.lat(ind),zin(ind),tempin(ind)); % Negeative to turn to depth
        Ftemp.ExtrapolationMethod = 'none';
        temp(:,:,:,subt_i) = Ftemp(xx,yy,zz);

        % Interpolate velocities
        uin = mod.u(:,:,:,subt_i);
        ind = find(~isnan(uin(:)));
        Fu = scatteredInterpolant(mod.grid.lon_u(ind),mod.grid.lat_u(ind),zin_u(ind),uin(ind)); % Negeative to turn to depth
        Fu.ExtrapolationMethod = 'none';
        u(:,:,:,subt_i) = Fu(xx,yy,zz);

        vin = mod.v(:,:,:,subt_i);
        ind = find(~isnan(vin(:)));
        Fv = scatteredInterpolant(mod.grid.lon_v(ind),mod.grid.lat_v(ind),zin_v(ind),vin(ind)); % Negeative to turn to depth
        Fv.ExtrapolationMethod = 'none';
        v(:,:,:,subt_i) = Fv(xx,yy,zz);


        ind = find(~isnan(tmz(:)));
        xin = mod.grid.lon(:,:,1);
        yin = mod.grid.lat(:,:,1);
        FH = scatteredInterpolant(xin(ind),yin(ind),tmz(ind)); % Negeative to turn to depth
        FH.ExtrapolationMethod = 'none';
        H(:,:,subt_i) = FH(xw,yw);


    end
    %% Pad down horizontally turning interpolated value deeper than actual bathy to nan (avoiding artifact of exptrapolation)
    for ii = 1:size(xw,1)
        for jj = 1:size(xw,2)
            salt(ii,jj,zlast_ind(ii,jj):end,:) = nan;
            u(ii,jj,zlast_ind(ii,jj):end,:) = nan;
            v(ii,jj,zlast_ind(ii,jj):end,:) = nan;
            temp(ii,jj,zlast_ind(ii,jj):end,:) = nan;

        end
    end
    %% Write data into strcuture
    S.ssh=H;
    S.u=u;
    S.v=v;
    S.temperature=temp;
    S.salinity=salt;
    S.z = zf';
    S.x = x';
    S.y = y';
    S.t = timet + (timezone/24); % Add timezone correction
    filename = [inpat 'ROMS_' datestr(times(time_i),'yyyymmdd') '.mat'];
    save(filename,'S','-mat');
    disp(['saved for timestep ' datestr(times(time_i),'yyyy-mm-dd') ])
end
end
toc
%% Combine into netCDF file
disp('Interpolation and conversion to gridded format completed, all matfile saved')

disp('Combining matfiles into a single .nc file')

ext_in = '.mat';
fils = dir([inpat tag '_*' ext_in]);

if strcmp(ext_in, '.nc')
    for aa = 1 : length(fils)
        fil = [inpat fils(aa).name];

        nci = netcdf.open(fil,'NOWRITE');
        tmptime = netcdf.getVar(nci, netcdf.inqVarID(nci,'time'),'double')./24 + datenum(2000,1,1);
        netcdf.close(nci);

        if aa>1
            keep = [keep; tmptime(:)>time(end)];
            time = [time;tmptime(:)];
            mod = [mod;repmat(aa,length(tmptime),1)];
            index = [index;(1:length(tmptime))'-1];
        else
            keep = true(length(tmptime),1);
            time = tmptime(:);
            mod = repmat(aa,length(tmptime),1);
            index = (1:length(tmptime))'-1;
        end
    end



    % Create new file here:
    schem = ncinfo([inpat fils(1).name]); % Get Basic Schema from First File

    % Make Time unlimited Dimension
    timdim = find(strcmpi({schem.Dimensions(:).Name},'time'));
    schem.Dimensions(timdim).Length = inf;
    schem.Dimensions(timdim).Unlimited = true;
    if timezone>0
        tz_str = sprintf('UTC+%2.1f',timezone);
    elseif timezone<0
        tz_str = sprintf('UTC+%2.1f',timezone);
    elseif timezone==0
        tz_str = sprintf('UTC');
    else
        error('Bonkers')
    end
    schem.Attributes = struct('Name',{'Source','CreationDate','Creator','JobNo.','Timezone'},'Value',{'Hycom GOFS 3.1 Archive Data on GLBv0.08 grid',datestr(now,'yyyymmdd.HHMMSS'),creator,jobno,tz_str});

    nvars = length(schem.Variables);
    for aa = 1 : nvars

        sz = schem.Variables(aa).Size;
        if length(sz)>1
            schem.Variables(aa).ChunkSize = [sz(1:end-1),1];
            schem.Variables(aa).DeflateLevel = 9;
        end
        if strcmpi(schem.Variables(aa).Name,'time')
            schem.Variables(aa).Attributes = struct('Name',{'long_name','units','time_origin','calendar','axis','_CoordinateAxisType'},'Value',{'Valid Time','hours since 1990-01-01 00:00:00','1990-01-01 00:00:00','gregorian','T','Time'});
        end
    end
    schem.Variables = rmfield(schem.Variables,'Size');


    newfil = [outinpat sprintf('%s_%s_%s_%s.nc',tag,timezone_Name,datestr(time(1)+timezone./24,'yyyymmdd'),datestr(time(end)+timezone./24,'yyyymmdd'))];
    if exist(newfil,'file')
        delete(newfil);
    end
    ncwriteschema(newfil, schem);

    % --
    nci = netcdf.open(newfil,'WRITE');
    xid = netcdf.inqVarID(nci, 'lon');
    yid = netcdf.inqVarID(nci, 'lat');
    zid = netcdf.inqVarID(nci, 'depth');
    tid = netcdf.inqVarID(nci, 'time');
    wtid = netcdf.inqVarID(nci, 'water_temp');
    said = netcdf.inqVarID(nci, 'salinity');
    seid = netcdf.inqVarID(nci, 'surf_el');
    wuid = netcdf.inqVarID(nci, 'water_u');
    wvid = netcdf.inqVarID(nci, 'water_v');

    % -- Initial Data
    ncitmp = netcdf.open([inpat fils(1).name],'NOWRITE');
    lon = netcdf.getVar(ncitmp,netcdf.inqVarID(ncitmp,'lon'));
    nx = length(lon);
    netcdf.putVar(nci,xid,lon);

    lat = netcdf.getVar(ncitmp,netcdf.inqVarID(ncitmp,'lat'));
    ny = length(lat);
    netcdf.putVar(nci,yid,lat);

    depth = netcdf.getVar(ncitmp,netcdf.inqVarID(ncitmp,'depth'));
    nz = length(depth);
    netcdf.putVar(nci,zid,depth);

    curid = 1;

    tic;
    inc = [];
    k=-1;
    % Loop through
    for aa = 1 : length(time)
        if mod(aa)~=curid
            netcdf.close(ncitmp);

            curid = mod(aa);
            fil = [inpat fils(curid).name];
            ncitmp = netcdf.open(fil,'NOWRITE');
        end

        if keep(aa)
            k=k+1;
            % Keep track of time
            inc = mytimer(aa,[1 length(time)],inc);

            % Write Time
            netcdf.putVar(nci,tid,k,1,convtime(time(aa)));

            % Get and write surf_el
            tmp2 = netcdf.getVar(ncitmp, netcdf.inqVarID(ncitmp, 'surf_el'), [0,0,index(aa)], [nx,ny,1]);
            netcdf.putVar(nci,seid,[0,0,k], [nx,ny,1], tmp2);

            % Get and write water_temp
            tmp3 = netcdf.getVar(ncitmp, netcdf.inqVarID(ncitmp, 'water_temp'), [0,0,0,index(aa)], [nx,ny,nz,1]);
            netcdf.putVar(nci,wtid,[0,0,0,k], [nx,ny,nz,1], tmp3);

            % Get and write salinity
            tmp3 = netcdf.getVar(ncitmp, netcdf.inqVarID(ncitmp, 'salinity'), [0,0,0,index(aa)], [nx,ny,nz,1]);
            netcdf.putVar(nci,said,[0,0,0,k], [nx,ny,nz,1], tmp3);

            % Get and write water_u
            tmp3 = netcdf.getVar(ncitmp, netcdf.inqVarID(ncitmp, 'water_u'), [0,0,0,index(aa)], [nx,ny,nz,1]);
            netcdf.putVar(nci,wuid,[0,0,0,k], [nx,ny,nz,1], tmp3);

            % Get and write water_v
            tmp3 = netcdf.getVar(ncitmp, netcdf.inqVarID(ncitmp, 'water_v'), [0,0,0,index(aa)], [nx,ny,nz,1]);
            netcdf.putVar(nci,wvid,[0,0,0,k], [nx,ny,nz,1], tmp3);

        end
    end
    netcdf.close(ncitmp);
    netcdf.close(nci);






    %% .mat HYCOM processing
elseif strcmp(ext_in, '.mat')

    % Set params
    hnams = sprintf('%s_%s_%s_%s',tag,timezone_Name,datestr(tstart,'yyyymmdd'),datestr(tfinish,'yyyymmdd'));
    newfil = [outinpat hnams '.nc'];
    if exist(newfil,'file')
        delete(newfil);
    end

    % Retrieve relevant files
    for ii = 1:length(fils)
        fname = fils(ii).name;
        date_str = strsplit(fname,'_');
        dats(ii,1) = datenum(date_str{end}(1:end-4),'yyyymmdd');
    end

    XX = find(dats >= tstart & dats <= tfinish);

    % - Create netCDF4 Output File
    varnames={'u'; 'v'};

    load([inpat fils(XX(1,1)).name]);
    %S = D;
    dims.lon = length(S.x); % 1st dimension
    dims.lat = length(S.y); % 2nd dimension
    dims.depth = length(S.z); % 3rd dimension
    dims.time = 'UNLIMITED'; % 4th dimension

    vars.time.nctype       = 'NC_DOUBLE';
    vars.time.dimensions   = 'time';
    vars.time.long_name    = 'Valid Time';
    vars.time.units        = 'hours since 1990-01-01 00:00:00';
    vars.time.time_origin  = '1990-01-01 00:00:00';
    vars.time.calendar     = 'gregorian';
    vars.time.axis         = 'T';
    vars.time.reference    = timezone_Name;
    vars.time.CoordinateAxisType = 'Time';

    vars.lon.nctype        = 'NC_FLOAT';
    vars.lon.dimensions    = 'lon';
    vars.lon.long_name     = 'Longitude';
    vars.lon.standard_name = 'longitude';
    vars.lon.units         = 'degrees_east';
    vars.lon.modulo        = '360 degrees';
    vars.lon.axis          = 'X';
    vars.lon.NAVO_code     = 2;
    vars.lon.projection    = 'LL_WGS84';
    vars.lon.CoordinateAxisType = 'Lon';

    vars.lat.nctype        = 'NC_FLOAT';
    vars.lat.dimensions    = 'lat';
    vars.lat.long_name     = 'Latitude';
    vars.lat.standard_name = 'latitude';
    vars.lat.units         = 'degrees_north';
    vars.lat.axis          = 'Y';
    vars.lat.NAVO_code     = 1;
    vars.lat.projection    = 'LL_WGS84';
    vars.lat.CoordinateAxisType = 'Lat';

    vars.depth.nctype        ='NC_FLOAT';
    vars.depth.dimensions    ='depth';
    vars.depth.long_name     ='Depth';
    vars.depth.standard_name ='depth';
    vars.depth.units         ='m';
    vars.depth.positive      ='down';
    vars.depth.axis          ='Z';
    vars.depth.NAVO_code     = 5;
    vars.depth.CoordinateAxisType    = 'Height';
    vars.depth.CoordinateZisPositive = 'down';

    vars.water_u.nctype         = 'NC_FLOAT';
    vars.water_u.dimensions     = {'lon','lat','depth','time'};
    vars.water_u.FillValue      = -30000;
    vars.water_u.CoordinateAxes = 'time depth lat lon ';
    vars.water_u.long_name      = 'Eastward Water Velocity';
    vars.water_u.standard_name  = 'eastward_sea_water_velocity';
    vars.water_u.units          = 'm/s';
    vars.water_u.missing_value  = -30000;
    vars.water_u.scale_factor   = 0.001;
    vars.water_u.add_offset     = 0;
    vars.water_u.NAVO_code      = 17;
    vars.water_u.coordinates    = 'time depth lat lon ';

    vars.water_v.nctype         = 'NC_FLOAT';
    vars.water_v.dimensions     = {'lon','lat','depth','time'};
    vars.water_v.FillValue      = -30000;
    vars.water_v.CoordinateAxes = 'time depth lat lon ';
    vars.water_v.long_name      = 'Northward Water Velocity';
    vars.water_v.standard_name  = 'northward_sea_water_velocity';
    vars.water_v.units          = 'm/s';
    vars.water_v.missing_value  = -30000;
    vars.water_v.scale_factor   = 0.001;
    vars.water_v.add_offset     = 0;
    vars.water_v.NAVO_code      = 18;
    vars.water_v.coordinates    = 'time depth lat lon ';

    vars.surf_el.nctype = 'NC_FLOAT';
    vars.surf_el.dimensions = {'lon','lat','time'};
    vars.surf_el.FillValue = -30000;
    vars.surf_el.CoordinateAxes = 'time lat lon ';
    vars.surf_el.long_name = 'Water Surface Elevation';
    vars.surf_el.standard_name = 'sea_surface_elevation';
    vars.surf_el.units = 'm';
    vars.surf_el.missing_value = -30000;
    vars.surf_el.scale_factor = 0.001;
    vars.surf_el.add_offset = 0;
    vars.surf_el.NAVO_code = 32;
    vars.surf_el.coordinates = 'time lat lon ';

    vars.water_temp.nctype         = 'NC_FLOAT';
    vars.water_temp.dimensions     = {'lon','lat','depth','time'};
    vars.water_temp.CoordinateAxes = 'time depth lat lon ';
    vars.water_temp.long_name      = 'Water Temperature';
    vars.water_temp.standard_name  = 'sea_water_temperature';
    vars.water_temp.units          = 'degC';
    vars.water_temp.missing_value  = -30000;
    vars.water_temp.scale_factor   = 0.001;
    vars.water_temp.add_offset     = 20;
    vars.water_temp.NAVO_code      = 15;
    vars.water_temp.comment        = 'in-situ temperature';
    vars.water_temp.coordinates    = 'time depth lat lon ';

    vars.salinity.nctype         = 'NC_FLOAT';
    vars.salinity.dimensions     = {'lon','lat','depth','time'};
    vars.salinity.FillValue      = -30000;
    vars.salinity.CoordinateAxes = 'time depth lat lon ';
    vars.salinity.long_name      = 'Salinity';
    vars.salinity.standard_name  = 'sea_water_salinity';
    vars.salinity.units          = 'psu';
    vars.salinity.missing_value  = -30000;
    vars.salinity.scale_factor   = 0.001;
    vars.salinity.add_offset     = 20;
    vars.salinity.NAVO_code      = 16;
    vars.salinity.coordinates    = 'time depth lat lon ';

    atts = struct();

    netcdf_define(newfil, dims, vars, atts);

    netcdf_put_var(newfil, 'lon', S.x);
    netcdf_put_var(newfil, 'lat', S.y);
    netcdf_put_var(newfil, 'depth', S.z);

    %% - Put in the Vars
    nf = numel(XX);
    time = [];
    bad_time = [];

    ctr1 = 1; ctr2 = 1; tic; inc = [];
    for aa = 1:nf
        inc = mytimer(aa, [1, nf], inc);
        load([inpat fils(XX(aa,1)).name]);
        %S = D; % aew quick fix
        %S.t = dats(aa);
        % Index to clean overlap
        if aa == 1
            I = [1:numel(S.t)];
        else
            I = find(S.t > time(end));
        end

        time = [time; S.t(I)];

        for bb = 1:length(I)
            ii = I(bb);

            try
                dat = squeeze(S.ssh(:, :, ii));
                netcdf_put_var(newfil, 'surf_el', dat, ctr1);

                dat = squeeze(S.temperature(:, :, :, ii));
                netcdf_put_var(newfil, 'water_temp', dat, ctr1);

                dat = squeeze(S.salinity(:, :, :, ii));
                netcdf_put_var(newfil, 'salinity', dat, ctr1);

                dat = squeeze(S.u(:, :, :, ii));
                netcdf_put_var(newfil, 'water_u', dat, ctr1);

                dat = squeeze(S.v(:, :, :, ii));
                netcdf_put_var(newfil, 'water_v', dat, ctr1);

                time_stamp = convtime(S.t(ii));
                netcdf_put_var(newfil, 'time', time_stamp, ctr1);

                ctr1 = ctr1 + 1;
            catch
                bad_time(ctr2) = S.t(ii);

                ctr2 = ctr2+1;
            end
        end
    end

    for aa = 1:ctr2-1
        fprintf([datestr(bad_time(aa)) '\n']);
    end




end

disp('Done :)')
