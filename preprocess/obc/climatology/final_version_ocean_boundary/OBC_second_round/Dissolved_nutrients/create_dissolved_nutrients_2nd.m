clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end
addpath(genpath('..\'))
% load IMOS
vars={'WQ_PHS_FRP','WQ_NIT_AMM','WQ_NIT_NIT','WQ_OXY_OXY','WQ_SIL_RSI'};
IMOS=load('..\..\datasets\processed_IMOS_udates_allvars.mat');
DWER=load('..\..\datasets\processed_DWER_udates_allvars.mat');


%% for all vars

for v=1:length(vars)
    var=vars{v};
    timearray1=IMOS.dataout.(var).Date;
    tmpdata1 =IMOS.dataout.(var).Data;
    if v==3
        tmpdata1(tmpdata1>0.6)=0.6;
    end
    outputIMOS=create_monthly_climatology(timearray1, tmpdata1);

    timearray2=DWER.dataout.(var).Date;
    tmpdata2 =DWER.dataout.(var).Data;
    if v==3
        tmpdata2(tmpdata2>0.6)=0.6;
    end

    outputDWER=create_monthly_climatology(timearray2, tmpdata2);

    %% scaling to other polygons
    %  use IMOS for Polygon 2-5, and DWER chl for 1&6

    %%
    for polys=1:6

        if (polys>1 && polys<6)
            raw.(['poly',num2str(polys)]).time=timearray1;
            raw.(['poly',num2str(polys)]).data=tmpdata1;
            output.(['poly',num2str(polys)]).time=outputIMOS.time;
            output.(['poly',num2str(polys)]).data=outputIMOS.data;
        else
            raw.(['poly',num2str(polys)]).time=timearray2;
            raw.(['poly',num2str(polys)]).data=tmpdata2;
            output.(['poly',num2str(polys)]).time=outputDWER.time;
            output.(['poly',num2str(polys)]).data=outputDWER.data;
        end
    end
    save([outDIR,'exported_',var,'.mat'],'raw','output','-mat','-v7.3')

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
       varname=strrep(var,'_','-');
        ylabel([varname,' (\muM)'])

        title([varname, ' - poly',num2str(polys)]);
        hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
        set(hl,'Location','eastoutside');


        img_name =[outDIR,'timeseries_',var,'_poly_',num2str(polys),'.png'];

        saveas(gcf,img_name);

    end

end