clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

    for polys=1:6
        inDIR='W:\csiem\Data\Virtual_Sensor\Updated\MOI\PISCES\Model_bio\Polygon\';
        datafile=[inDIR,'CMEMS_bio_polygon_',num2str(polys),'.csv'];
        T=readtable(datafile);
        time=T.time;
        depth=T.depth;
        OXY=T.o2;

      %  timearray=datetime(time,'InputFormat','yyyy-mm-dd HH:MM:SS');
        timearray=datenum(time);
        timeuniq=unique(timearray);

        for t=1:length(timeuniq)
            tmpind1=find(timearray==(timeuniq(t)));
            tmpdepth=depth(tmpind1);
            tmpdata=OXY(tmpind1);
            OXYuniq(t)=mean(tmpdata(~isnan(tmpdata)));
        end
            
        timevec=datevec(timeuniq);

        raw.(['poly',num2str(polys)]).time=timeuniq;
        raw.(['poly',num2str(polys)]).data=OXYuniq;

        for mm=1:12
            inds=find(timevec(:,2)==mm);
            tmpOXY=OXYuniq(inds);
            datamonthly.(['poly',num2str(polys)])(mm)=mean(tmpOXY(~isnan(tmpOXY)));
        end

        datearray=datenum(1980,1:540,1);

        for dd=1:length(datearray)-1
            output.(['poly',num2str(polys)]).time(dd)=datearray(dd);
            tmpInd=find(timeuniq>datearray(dd) & timeuniq<=datearray(dd+1));
            if isempty(tmpInd)
                newD=datevec(datearray(dd));
                output.(['poly',num2str(polys)]).data(dd)=datamonthly.(['poly',num2str(polys)])(newD(2));
            else
                newOXY=OXYuniq(tmpInd);
                output.(['poly',num2str(polys)]).data(dd)=mean(newOXY(~isnan(newOXY)));
            end
        end

    end

save([outDIR,'exported_OXY.mat'],'raw','output','-mat','-v7.3')

%%
hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);


for polys=1:6

clf;
    plot(raw.(['poly',num2str(polys)]).time,...
        raw.(['poly',num2str(polys)]).data,'DisplayName','MOI BIO');
    hold on;
   plot(output.(['poly',num2str(polys)]).time,...
        output.(['poly',num2str(polys)]).data,'DisplayName','monthly');
    hold on;

    box on;

    datearray=datenum(1980:5:2025,1,1);

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    set(gca,'ylim',[215 245]);
    ylabel('DO (\muM)')

    title(['DO - poly',num2str(polys)]);
    hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    set(hl,'Location','eastoutside');


img_name =[outDIR,'timeseries_OXY_poly_',num2str(polys),'.png'];

saveas(gcf,img_name);

end