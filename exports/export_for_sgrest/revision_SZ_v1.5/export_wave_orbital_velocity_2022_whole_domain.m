clear; close all;

file='W:\csiem\Model\WAVES\WWM\2022\his_20220101.nc';
lon=ncread(file, 'lon');
lat=ncread(file, 'lat');
depth=ncread(file, 'depth');
% 
% sitesheet='./GPS_sites_only.xlsx';
% 
% [num,txt,raw]=xlsread(sitesheet,'B2:C10');
% sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};
% for t=1:length(sitenames)
%   %  tmp=txt{t};
%   %  C=strsplit(tmp,',');
%     siteX(t)=num(t,2); %str2double(C{2});
%     siteY(t)=num(t,1);
%     
%     distx=lon-siteX(t);
%     disty=lat-siteY(t);
%     distt=sqrt(distx.^2+disty.^2);
%     
%     inds=find(distt==min(distt));
%     siteI(t)=inds(1);
%     siteD(t)=depth(inds(1));
% end

inDir='W:\csiem\Model\WAVES\WWM\2022\';

t1=datenum(2022,1,1);
t2=datenum(2022,12,31);

for t=t1:t2
    infile=[inDir,'his_',datestr(t,'yyyymmdd'),'.nc'];
    disp(infile);

    ocean_time=ncread(infile,'ocean_time');
    time=datenum(1958,11,17)+ocean_time/86400;
    ubot0=ncread(infile,'UBOT');
    orb0=ncread(infile,'ORBITAL');

   % ubot=ubot0(siteI,:);
   % orb=orb0(siteI,:);

    if t==t1
        output.time=time;
        output.ubot=ubot0;
        output.orb=orb0;
    else
        l1=length(output.time);
        l2=length(time);

        output.time(l1+1:l1+l2)=time;
        output.ubot(:,l1+1:l1+l2)=ubot0;
        output.orb(:,l1+1:l1+l2)=orb0;
    end

end

output.lat=lat;
output.lon=lon;
output.depth=depth;

save('orbital_2022_whole_domain.mat','output','-mat','-v6');