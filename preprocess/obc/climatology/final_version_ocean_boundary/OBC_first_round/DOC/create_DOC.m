clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

do_SS1 = 1;
if do_SS1
    for polys=1:6
        inDIR='W:\csiem\Data\Virtual_Sensor\Updated\ESA\GlobColor\Optics\Polygon\';
        datafile=[inDIR,'CMEMS_optics_polygon_',num2str(polys),'.csv'];
        T=readtable(datafile);
        time=T.time;

        timearray=datetime(time,'InputFormat','yyyy-mm-dd HH:MM:SS');
        timearray=datenum(timearray);
        timevec=datevec(timearray);

        CDM2DOC_ratio=0.5;
        SPM=T.CDM/CDM2DOC_ratio;

        raw.(['poly',num2str(polys)]).time=timearray;
        raw.(['poly',num2str(polys)]).data=SPM;

        for mm=1:12
            inds=find(timevec(:,2)==mm);
            tmpSPM=SPM(inds);
            datamonthly.(['poly',num2str(polys)])(mm)=mean(tmpSPM(~isnan(tmpSPM)));
        end

        datearray=datenum(1980,1:540,1);

        for dd=1:length(datearray)-1
            output.(['poly',num2str(polys)]).time(dd)=datearray(dd);
            tmpInd=find(timearray>datearray(dd) & timearray<=datearray(dd+1));
            if isempty(tmpInd)
                newD=datevec(datearray(dd));
                output.(['poly',num2str(polys)]).data(dd)=datamonthly.(['poly',num2str(polys)])(newD(2));
            else
                newSPM=SPM(tmpInd);
                output.(['poly',num2str(polys)]).data(dd)=mean(newSPM(~isnan(newSPM)));
            end
        end

    end
end
save([outDIR,'exported_DOC.mat'],'raw','output','-mat','-v7.3')

%%
hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);


for polys=1:6

clf;
    plot(raw.(['poly',num2str(polys)]).time,...
        raw.(['poly',num2str(polys)]).data,'DisplayName','ESA');
    hold on;
   plot(output.(['poly',num2str(polys)]).time,...
        output.(['poly',num2str(polys)]).data,'DisplayName','monthly');
    hold on;

    box on;

    datearray=datenum(1980:5:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    set(gca,'ylim',[0 1]);
    ylabel('DOC (\muM)')

    title(['DOC - poly',num2str(polys)]);
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');


img_name =[outDIR,'timeseries_DOC_poly_',num2str(polys),'.png'];

saveas(gcf,img_name);

end