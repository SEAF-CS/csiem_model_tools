clear; close all;

infiles={'A','B','C'};

for i=2:length(infiles)
    infile=['WWM_SWAN_CONV_',infiles{i},'grid_2022.nc'];
    disp(infile);
    newtime=ncread(infile,'time')+8;
    ncwrite(infile,'time',newtime);
    ncwriteatt(infile,'time','tz','UTC+08');
end

