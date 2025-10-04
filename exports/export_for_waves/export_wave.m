clear; close all;

inDir='W:\csiem\Model\WAVES\WWM_SWAN_conversion\WWM_SWAN_CONV_Bgrid_all_years\';
infile=[inDir,'WWM_SWAN_CONV_Bgrid_2022.nc'];

Xp=ncread(infile,'Xp');
Yp=ncread(infile,'Yp');

sitenames={'PB','SBA','SBB','PBA','PBB'};
siteXutm=[381417.02, 379268.75, 380032.24, 378568.03, 379279.01];
siteYutm=[6455449.94, 6449572.59, 6448864.65, 6445541.44, 6444071.61];

[~, ~, grid_zone] = ll2utm (115.6976, -32.1463);

for ss=1:length(sitenames)
    [siteX(ss), siteY(ss)] = utm2ll (siteXutm(ss), siteYutm(ss), grid_zone);
end

for ss=1:length(sitenames)

X0=siteX(ss);
Y0=siteY(ss);

X1=Xp-X0;
Y1=Yp-Y0;

Td=sqrt(X1.^2+Y1.^2);
tmp1=min(Td,[],2);
ind1=find(tmp1==min(tmp1));

tmp2=min(Td,[],1);
ind2=find(tmp2==min(tmp2));

time=ncread(infile,'time')/24+datenum(1990,1,1);
tmp=ncread(infile,'Hsig',[ind1,ind2,1],[1 1 Inf]);
Hs=squeeze(tmp(1,1,:));

tmp=ncread(infile,'Dir',[ind1,ind2,1],[1 1 Inf]);
Dir=squeeze(tmp(1,1,:));

tmp=ncread(infile,'TPsmoo',[ind1,ind2,1],[1 1 Inf]);
TP=squeeze(tmp(1,1,:));


%%

fileID = fopen(['Export_waves_',sitenames{ss},'.csv'],'w');
fprintf(fileID,'%s\n','Time,WaveHeight,WaveDirection,WavePeriod');

for t=1:length(time)
    if mod(t,100)==0
        disp(datestr(time(t),'HH:MM:SS dd/mm/yyyy'));
    end
    fprintf(fileID,'%s,',datestr(time(t),'dd/mm/yyyy HH:MM:SS'));
    fprintf(fileID,'%4.4f,',Hs(t));
    fprintf(fileID,'%4.4f,',Dir(t));
    fprintf(fileID,'%4.4f\n',TP(t));
end

fclose(fileID);

end