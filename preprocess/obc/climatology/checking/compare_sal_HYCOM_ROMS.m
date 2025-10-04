%% check SAL

clear; close all;

% load IMOS
var='SAL';
IMOS=load(['IMOS_data_',var,'.mat']);

% load R
datafile='W:\csiem\Data\Virtual_Sensor\Model_salinity\Points\CMEMS_Salt_point_5.csv';
T=readtable(datafile);

depth=T.depth;
time=T.time;

timearray=datetime(time,'InputFormat','yyyy-mm-dd HH:MM:SS');

%% roms and HYCOM
ncfile1='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\HYCOM\GoC_HYCOM.nc';

XX0=IMOS.data.IMOS_BGC_NRSROT_BGC_Profile_61.SAL.Lon;
YY0=IMOS.data.IMOS_BGC_NRSROT_BGC_Profile_61.SAL.Lat;

t1=double(ncread(ncfile1,'local_time'))/24+datenum(1990,1,1);
lon1=ncread(ncfile1,'longitude');
lat1=ncread(ncfile1,'latitude');
depth1=ncread(ncfile1,'depth');

indx1=find(abs(lon1-XX0)==min(abs(lon1-XX0)));
indy1=find(abs(lat1-YY0)==min(abs(lat1-YY0)));

sal1=ncread(ncfile1,'salinity',[indx1 indy1 1 1],[1 1 Inf Inf]);
sal1=squeeze(sal1(1,1,:,:));

%
ncfile2='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\ROMS\ROMS_UTC+8_20220101_20221231.nc';
t2=double(ncread(ncfile2,'time'))/24+datenum(1990,1,1);
lon2=ncread(ncfile2,'lon');
lat2=ncread(ncfile2,'lat');
depth2=ncread(ncfile2,'depth');

indx2=find(abs(lon2-XX0)==min(abs(lon2-XX0)));
indy2=find(abs(lat2-YY0)==min(abs(lat2-YY0)));

sal2=ncread(ncfile2,'salinity',[indx2 indy2 1 1],[1 1 Inf Inf]);
sal2=squeeze(sal2(1,1,:,:));

%%
unidepth=unique(depth);

lim1=[0 -20 -40];
lim2=[-10 -30 -70];

RdepthID=[5 14 19];
HdepthID=[3 10 15];
ROMdepthID=[8 14 21];

titles={'0 - 10 m', '20-30m','40-60m'};
Dnames={'ANMN2','ANMN5','ANMN11','BGC'};

colors=[127,201,127;...
190,174,212;...
56,108,176;...
240,2,127;...
191,91,23]./255;


hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 30]);

for l=1:3 

    subplot(3,1,l);

    % IMOS
    sites=fieldnames(IMOS.data);

    for ss=1:length(sites)

        datatmp=IMOS.data.(sites{ss}).(var);

        depthtmp=datatmp.Depth;
        datetmp =datatmp.Date;
        datatmp =datatmp.Data;

        inds=find(depthtmp>=lim2(l) & depthtmp<=lim1(l));

        depthtmp2=depthtmp(inds);
        datetmp2 =datetmp(inds);
        datatmp2 =datatmp(inds);

        if ~isempty(datetmp2)

        plot(datetmp2,datatmp2,'DisplayName',Dnames{ss});
        hold on;

        end
    end


    % CMEM
    indR=find(depth==unidepth(RdepthID(l)));

    depth2=depth(indR);
    dataR =T.so;
    dataR2=dataR(indR);
    timearray2=timearray(indR);

    plot(datenum(timearray2),dataR2,'DisplayName','CMEM');

    hold on;
    
    plot(t1, sal1(HdepthID(l),:),'DisplayName','HYCOM');
    hold on;

    plot(t2, sal2(ROMdepthID(l),:),'DisplayName','ROMS');
    hold on;
    
    box on;

    datearray=datenum(2022,1:3:13,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    set(gca,'ylim',[34 37]);
    ylabel('SAL (psu)')

    title('salinity');
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');

end

img_name ='compare_sal_HYCOM_ROMS.png';

saveas(gcf,img_name);
