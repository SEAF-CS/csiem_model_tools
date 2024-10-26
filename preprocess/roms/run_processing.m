clear all; close all;

% allstart = datenum(2018:01:2021,10,01);
% allfinish = datenum(2019:01:2022,12,31);
allstart = datenum(2022,10,01);
allfinish = datenum(2023,12,31);
for i = 1:length(allstart)
    proc_roms_bc_files(allstart(i),allfinish(i));clear functions
end