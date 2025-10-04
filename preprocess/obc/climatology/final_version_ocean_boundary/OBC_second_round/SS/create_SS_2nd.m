clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

% load IMOS
var='TSSorganic';
IMOS=load('..\..\datasets\processed_IMOS_udates_allvars.mat');
%DWER=load('..\..\datasets\processed_DWER_udates_allvars.mat');
POC_compiled=load('..\POC\exported_POC.mat');

%% check out IMOS BGC data

%TSSorganic=IMOS.dataout.TSSorganic;
TSSinorganic=IMOS.dataout.TSSinorganic;
TSSinorganic.Data(TSSinorganic.Data>2)=NaN;
POC=POC_compiled.raw.poly3;
POC.data=POC.data*12/1000*2;

TSS=IMOS.dataout.WQ_DIAG_TOT_TSS;

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

scatter(POC.time,POC.data); % convert from mg/L to mmol C/m3
hold on;
scatter(TSSinorganic.Date,TSSinorganic.Data); % convert from ug CHLA/L to mmol C/m3
hold on;

[C, ia, ib]=intersect(POC.time, TSSinorganic.Date);

TSSsum.Date=C;
TSSsum.Data=POC.data(ia)+TSSinorganic.Data(ib);

hold on;
scatter(TSS.Date,TSS.Data); % convert from ug CHLA/L to mmol C/m3
hold on;
scatter(TSSsum.Date,TSSsum.Data); % convert from ug CHLA/L to mmol C/m3
hold on;

datearray=datenum(2008:2:2024,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[215 245]);
    ylabel('(\muM carbon)')
    hl=legend('POC','TSS inorganic','TSS','org+inorg');

img_name = '.\data_check.jpg';

saveas(gcf,img_name);

%[C, ia, ib]=intersect(TSS.Date, TSSinorganic.Date);

ratio=mean(TSSinorganic.Data(ib))/mean(POC.data(ia));



%% for TSSorganic
timearray=TSSinorganic.Date;
tmpdata0 =TSSinorganic.Data;

outputTSSinorganic=create_monthly_climatology(timearray, tmpdata0);
% 
% timeD=DWER.dataout.WQ_DIAG_TOT_TSS.Date;
% dataD=DWER.dataout.WQ_DIAG_TOT_TSS.Data;
% outputTSSinorganicDWER=create_monthly_climatology(timeD,dataD);


%% scaling to other polygons
%  use IMOS for Polygon 2-5, and DWER POC for 1&6 with SS/POC ratio of
%  1.1609

%%


for polys=1:6

    if (polys>1 && polys<6)
        raw.(['poly',num2str(polys)]).time=TSSinorganic.Date;
        raw.(['poly',num2str(polys)]).data=TSSinorganic.Data;
        output.(['poly',num2str(polys)]).time=outputTSSinorganic.time;
        output.(['poly',num2str(polys)]).data=outputTSSinorganic.data;
    else
        raw.(['poly',num2str(polys)]).time=POC_compiled.raw.poly3.time;
        raw.(['poly',num2str(polys)]).data=POC_compiled.raw.poly3.data*ratio*12/1000*2;
        output.(['poly',num2str(polys)]).time=POC_compiled.output.poly3.time;
        output.(['poly',num2str(polys)]).data=POC_compiled.output.poly3.data*ratio*12/1000*2;
    end
end
save([outDIR,'exported_SS.mat'],'raw','output','-mat','-v7.3')

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
   % set(gca,'ylim',[0 40]);
    ylabel('SS (mg/L)')

    title(['SS - poly',num2str(polys)]);
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');


img_name =[outDIR,'timeseries_POC_poly_',num2str(polys),'.png'];

saveas(gcf,img_name);

end