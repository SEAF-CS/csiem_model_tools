clear; close all;

inDir='W:\csiem\Model\WAVES\WWM_SWAN_conversion\WWM_SWAN_CONV_Bgrid_all_years\';
infile=[inDir,'WWM_SWAN_CONV_Bgrid_2021.nc'];

Xp=ncread(infile,'Xp');
Yp=ncread(infile,'Yp');

X0=115.6976;
Y0=-32.1463;

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

fileID = fopen('CS1_model.csv','w');
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
