%% check SAL

clear; close all;

% load IMOS
var='WQ_PHS_FRP';
IMOS=load(['IMOS_data_',var,'.mat']);

% load R
datafile='W:\csiem\Data\Virtual_Sensor\Model_Nut\Points\CMEMS_nut_point_5.csv';
T=readtable(datafile);

depth=T.depth;
time=T.time;

timearray=datetime(time,'InputFormat','yyyy-mm-dd HH:MM:SS');

%%
unidepth=unique(depth);

lim1=[0 -20 -40];
lim2=[-10 -30 -70];

RdepthID=[5 14 19];
titles={'0 - 10 m', '20-30m','40-60m'};
Dnames={'ANMN','WACA'};

colors=[127,201,127;...
190,174,212;...
56,108,176;...
240,2,127;...
191,91,23]./255;


hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 20]);

for l=1:length(lim1)

    subplot(3,1,l);

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

        plot(datetmp2,datatmp2,'Color',colors(ss,:),'DisplayName',Dnames{ss});
        hold on;

        end
    end

    indR=find(depth==unidepth(RdepthID(l)));

    depth2=depth(indR);
    dataR =T.po4;
    dataR2=dataR(indR);
    timearray2=timearray(indR);

    plot(datenum(timearray2),dataR2,'Color',colors(5,:),'DisplayName','CMEM');

    hold on;
    box on;

    datearray=datenum(2009:3:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[34 37]);
    ylabel('NO3 (\muM)')

    title(titles{l});
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');

end

img_name ='compare_po4.png';

saveas(gcf,img_name);
