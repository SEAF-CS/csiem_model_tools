%% check SAL

clear; close all;

% % load IMOS
% var='WQ_SIL_RSI';
% IMOS=load(['IMOS_data_',var,'.mat']);

% load R
datafile='W:\csiem\Data\Virtual_Sensor\Updated\ESA\GlobColor\Optics\Point\CMEMS_optics_point_5.csv';
T=readtable(datafile);

%depth=T.depth;
time=T.time;

timearray=datetime(time,'InputFormat','yyyy-mm-dd HH:MM:SS');

%%
% unidepth=unique(depth);
% 
% lim1=[0 -20 -40];
% lim2=[-10 -30 -70];
% 
% RdepthID=[5 14 19];
% titles={'0 - 10 m', '20-30m','40-60m'};
% Dnames={'ANMN','WACA'};

colors=[127,201,127;...
190,174,212;...
56,108,176;...
240,2,127;...
191,91,23]./255;


hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

clf;
  
    dataR =T.CDM;
   % dataR2=dataR(indR);
   % timearray2=timearray(indR);

    plot(datenum(timearray),dataR,'Color',colors(5,:),'DisplayName','ESA');

    hold on;
    box on;

    datearray=datenum(2009:3:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[34 37]);
    ylabel('CDM (\muM)')

    title('CDM');
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');

img_name ='compare_CDM.png';

saveas(gcf,img_name);
