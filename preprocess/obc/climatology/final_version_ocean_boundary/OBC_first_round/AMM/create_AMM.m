clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

% load IMOS
var='WQ_NIT_AMM';
IMOS=load(['..\IMOS_data_',var,'.mat']);

%%

timearray=IMOS.data.IMOS_BGC_NRSROT_BGC_Profile_18.WQ_NIT_AMM.Date;
AMM =IMOS.data.IMOS_BGC_NRSROT_BGC_Profile_18.WQ_NIT_AMM.Data;

timeuniq=unique(timearray);
polys=3; % for polygon at IMOS

        for t=1:length(timeuniq)
            tmpind1=find(timearray==(timeuniq(t)));
           % tmpdepth=depth(tmpind1);
            tmpdata=AMM(tmpind1);
            AMMuniq(t)=mean(tmpdata(~isnan(tmpdata)));
        end


        timevec=datevec(timeuniq);

        raw.(['poly',num2str(polys)]).time=timeuniq;
        raw.(['poly',num2str(polys)]).data=AMMuniq;

        for mm=1:12
            inds=find(timevec(:,2)==mm);
            tmpAMM=AMMuniq(inds);
            datamonthly.(['poly',num2str(polys)])(mm)=mean(tmpAMM(~isnan(tmpAMM)));
        end

        datearray=datenum(1980,1:540,1);

        for dd=1:length(datearray)-1
            output.(['poly',num2str(polys)]).time(dd)=datearray(dd);
            tmpInd=find(timeuniq>datearray(dd) & timeuniq<=datearray(dd+1));
            if isempty(tmpInd)
                newD=datevec(datearray(dd));
                output.(['poly',num2str(polys)]).data(dd)=datamonthly.(['poly',num2str(polys)])(newD(2));
            else
                newAMM=AMMuniq(tmpInd);
                output.(['poly',num2str(polys)]).data(dd)=mean(newAMM(~isnan(newAMM)));
            end
        end

%% scaling to other polygons

% use same scales from the CMEM NIT in polygons
NIT=load('..\NIT\exported_NIT.mat');
scales=NIT.scales;

for polys=1:6
    raw.(['poly',num2str(polys)]).time=raw.(['poly',num2str(3)]).time;
    raw.(['poly',num2str(polys)]).data=raw.(['poly',num2str(3)]).data*scales(polys);

    output.(['poly',num2str(polys)]).time=output.(['poly',num2str(3)]).time;
    output.(['poly',num2str(polys)]).data=output.(['poly',num2str(3)]).data*scales(polys);
end
save([outDIR,'exported_AMM.mat'],'raw','output','scales','-mat','-v7.3')

%%
hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);


for polys=1:6

clf;
    plot(raw.(['poly',num2str(polys)]).time,...
        raw.(['poly',num2str(polys)]).data,'DisplayName','IMOS ANMN');
    hold on;
   plot(output.(['poly',num2str(polys)]).time,...
        output.(['poly',num2str(polys)]).data,'DisplayName','monthly');
    hold on;

    box on;

    datearray=datenum(1980:5:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
  %  set(gca,'ylim',[215 245]);
    ylabel('AMM (\muM)')

    title(['AMM - poly',num2str(polys)]);
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');


img_name =[outDIR,'timeseries_AMM_poly_',num2str(polys),'.png'];

saveas(gcf,img_name);

end