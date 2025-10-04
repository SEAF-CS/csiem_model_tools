clear; close all;

%% load IMOS TEMP
var='TEMP';
aa=load(['..\IMOS_data_',var,'.mat']);

var='SAL';
bb=load(['..\IMOS_data_',var,'.mat']);
%%
tmpdata=aa.data.IMOS_amnmprofile_NRSROT_PROFILE_Profile_13.TEMP;

tmpdepth=tmpdata.Depth;
ind1=find(tmpdepth>-30 & tmpdepth<-20);
data1=tmpdata.Data(ind1);
date1=tmpdata.Date(ind1);
dvec=datevec(date1);
y2s=2015;

for mm=1:12
    ind2=find(dvec(:,1)==y2s & dvec(:,2)==mm);
    data2=data1(ind2);
    outputtemp(1,mm)=mean(data2(~isnan(data2)));
end

ind1=find(tmpdepth>-48 & tmpdepth<-41);
data1=tmpdata.Data(ind1);
date1=tmpdata.Date(ind1);
dvec=datevec(date1);

for mm=1:12
    ind2=find(dvec(:,1)==y2s & dvec(:,2)==mm);
    data2=data1(ind2);
    outputtemp(2,mm)=mean(data2(~isnan(data2)));
end

ind1=find(tmpdepth>-60 & tmpdepth<-55);
data1=tmpdata.Data(ind1);
date1=tmpdata.Date(ind1);
dvec=datevec(date1);

for mm=1:12
    ind2=find( dvec(:,1)==y2s & dvec(:,2)==mm);
    data2=data1(ind2);
    outputtemp(3,mm)=mean(data2(~isnan(data2)));
end

%% load IMOS SAL

tmpdata=bb.data.IMOS_amnmprofile_NRSROT_PROFILE_Profile_11.SAL;
tmpdepth=tmpdata.Depth;
ind1=find(tmpdepth>-30 & tmpdepth<-20);
data1=tmpdata.Data(ind1);
date1=tmpdata.Date(ind1);
dvec=datevec(date1);

for mm=1:12
    ind2=find(dvec(:,1)==y2s & dvec(:,2)==mm);
    data2=data1(ind2);
    outputsal(1,mm)=mean(data2(~isnan(data2)));
end

ind1=find(tmpdepth>-48 & tmpdepth<-41);
data1=tmpdata.Data(ind1);
date1=tmpdata.Date(ind1);
dvec=datevec(date1);

for mm=1:12
    ind2=find(dvec(:,1)==y2s & dvec(:,2)==mm);
    data2=data1(ind2);
    outputsal(2,mm)=mean(data2(~isnan(data2)));
end

ind1=find(tmpdepth>-60 & tmpdepth<-55);
data1=tmpdata.Data(ind1);
date1=tmpdata.Date(ind1);
dvec=datevec(date1);

for mm=1:12
    ind2=find(dvec(:,1)==y2s & dvec(:,2)==mm);
    data2=data1(ind2);
    outputsal(3,mm)=mean(data2(~isnan(data2)));
end


%%
depth=[25 45 58];
for i=1:12
    pressure(:,i)=depth/10+1.013;
end

[rho, rhodif]=seawater_density(outputsal,outputtemp,pressure);
%%


hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);
i2s=[1 3];
colors=[158,1,66;...
213,62,79;...
244,109,67;...
253,174,97;...
254,224,139;...
255,255,191;...
230,245,152;...
171,221,164;...
102,194,165;...
50,136,189;...
94,79,162;...
2,56,88]./255;

        clf;

        axes('Position',[0.07 0.08 0.20 0.8]);
for mm=1:12
        plot(outputsal(i2s,mm),-depth(i2s),'Color',colors(mm,:));
        hold on;
end
     %   xlabel('Salinity (PSU)');
        ylabel('Depth (m)');
     %   legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

        title('(a) Salinity (PSU)');
        xlim([35 36]);

        axes('Position',[0.36 0.08 0.20 0.8]);
for mm=1:12
        plot(outputtemp(i2s,mm),-depth(i2s),'Color',colors(mm,:));
        hold on;
end
     %   xlabel('Temperature (^oC)');
        ylabel('Depth (m)');
     %   legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

      title('(b) Temperature (^oC)');
       xlim([15 25]);

       axes('Position',[0.65 0.08 0.20 0.8]);
for mm=1:12
        plot(rho(i2s,mm),-depth(i2s),'Color',colors(mm,:));
        hold on;
end
       % xlabel('Density (kg/m^2)');
        ylabel('Depth (m)');
        hl=legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
        set(hl,'Position',[0.94 0.3 0.005 0.4],'FontSize',6)

      title('(c) Density (kg/m^2)');
        xlim([1024 1026]);


        img_name ='IMOS_monthly_profile_check.png';

        saveas(gcf,img_name);

% 
% datearray=datenum(2022,1:3:13,1);
% 
% 
% hfig = figure('visible','on','position',[304         166        1271         812]);
% 
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf,'paperposition',[0.635 6.35 20.32 10]);
% 
%         clf;
% 
%         plot(time,salmodel,'k');
%         hold on;
%         scatter(timeuniq,AMMuniq);
%         hold on;
%         set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'mm/yyyy'));
%         %  set(gca,'ylim',[215 245]);
%         ylabel('Salinity (PSU)');
%         legend('ROMS','DWER data');
% 
%       %  title([vars{v}, ' - poly',num2str(polys)]);
% 
%         img_name ='roms_salinity_check.png';
% 
%         saveas(gcf,img_name);