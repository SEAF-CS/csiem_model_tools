clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

% load IMOS
var='TSSorganic';
IMOS=load('..\..\datasets\processed_IMOS_udates_allvars.mat');
DWER=load('..\..\datasets\processed_DWER_udates_allvars.mat');

%% check out IMOS BGC data

TSSorganic=IMOS.dataout.TSSorganic;
TCHLA=IMOS.dataout.WQ_DIAG_PHY_TCHLA;

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

scatter(TSSorganic.Date,TSSorganic.Data*0.5*1000/12); % convert from mg/L to mmol C/m3
hold on;
scatter(TCHLA.Date,TCHLA.Data*50/12); % convert from ug CHLA/L to mmol C/m3
hold on;

[C, ia, ib]=intersect(TSSorganic.Date, TCHLA.Date);

POC.Date=C;
POC.Data=TSSorganic.Data(ia)*0.5*1000/12-TCHLA.Data(ib)*50/12;
POC.Data(POC.Data<0)=0;
hold on;
scatter(POC.Date,POC.Data); % convert from ug CHLA/L to mmol C/m3
hold on;

datearray=datenum(2008:2:2024,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[215 245]);
    ylabel('(\muM carbon)')
    hl=legend('TSS organic','TCHLA','POC');

img_name = '.\data_check.jpg';

saveas(gcf,img_name);

%% chla/TSSorganic ratio

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

yyaxis left;
scatter(TSSorganic.Date,TSSorganic.Data*0.5*1000); % convert from mg/L to mmol C/m3
hold on;
scatter(TCHLA.Date,TCHLA.Data,'k'); % convert from ug CHLA/L to mmol C/m3
hold on;

[C, ia, ib]=intersect(TSSorganic.Date, TCHLA.Date);

POC.Date=C;
POC.Data=TSSorganic.Data(ia)*0.5*1000/12-TCHLA.Data(ib)*50/12;
POC.Data(POC.Data<0)=0;
hold on;
% scatter(POC.Date,POC.Data); % convert from ug CHLA/L to mmol C/m3
% hold on;
ratio1=mean(TCHLA.Data)/mean(TSSorganic.Data*0.5*1000);
ratio2=mean(TCHLA.Data(ib))/mean(TSSorganic.Data(ia)*0.5*1000);
ylim([0 500]);
ylabel('(\muM carbon)')

yyaxis right;

datearray=datenum(2008:2:2024,1,1);
plot(datearray,datearray*0+ratio1);
    ylabel('CHL/POC ratio')
    ylim([0 0.01]);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[215 245]);

    hl=legend('TSS organic','TCHLA','POC');

img_name = '.\data_check_chlPOC_ratio.jpg';

saveas(gcf,img_name);

%% for TSSorganic
timearray=TSSorganic.Date;
tmpdata0 =TSSorganic.Data*0.5/12*1000;

outputTSSorganic=create_monthly_climatology(timearray, tmpdata0);
outputTCHLA=create_monthly_climatology(TCHLA.Date, TCHLA.Data);
outputPOC=create_monthly_climatology(POC.Date, POC.Data);
outputPOC.data(outputPOC.data>20)=12;

timeD=DWER.dataout.WQ_DIAG_PHY_TCHLA.Date;
dataD=DWER.dataout.WQ_DIAG_PHY_TCHLA.Data;
outputTCHLADWER=create_monthly_climatology(timeD,dataD);
outputTCHLADWER.data(outputTCHLADWER.data>0.82)=0.82;


%% scaling to other polygons
%  use IMOS for Polygon 2-5, and DWER chl for 1&6 with CHL/POC ratio of
%  0.0044

%%
for polys=1:6

    if (polys>1 && polys<6)
        raw.(['poly',num2str(polys)]).time=POC.Date;
        raw.(['poly',num2str(polys)]).data=POC.Data;
        output.(['poly',num2str(polys)]).time=outputPOC.time;
        output.(['poly',num2str(polys)]).data=outputPOC.data;
    else
        raw.(['poly',num2str(polys)]).time=timeD;
        raw.(['poly',num2str(polys)]).data=dataD/ratio1/12;
        output.(['poly',num2str(polys)]).time=outputTCHLADWER.time;
        output.(['poly',num2str(polys)]).data=outputTCHLADWER.data/ratio1/12;
    end
end
save([outDIR,'exported_POC_3rd.mat'],'raw','output','-mat','-v7.3')

%%
hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);


for polys=1:6

clf;
    plot(raw.(['poly',num2str(polys)]).time,...
        raw.(['poly',num2str(polys)]).data,'DisplayName','raw');
    hold on;
    plot(output.(['poly',num2str(polys)]).time,...
        output.(['poly',num2str(polys)]).data,'DisplayName','monthly');
    hold on;
    box on;

    datearray=datenum(1980:5:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    set(gca,'ylim',[0 40]);
    ylabel('POC (\muM)')

    title(['POC - poly',num2str(polys)]);
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');


img_name =[outDIR,'timeseries_POC_poly_',num2str(polys),'_3rd.png'];

saveas(gcf,img_name);

end