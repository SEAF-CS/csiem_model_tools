clear; close all;

outDIR = '.\';

if ~exist(outDIR,'dir')
    mkdir(outDIR);
end

% load IMOS
var='SAL';
DWER=load(['..\DWER_data_',var,'.mat']);

%% find sites within SW region

shp=shaperead('W:\csiem\csiem-marvl-dev\gis\MLAU_Zones_v3_ll.shp');

sites=fieldnames(DWER.data);
inc=1;

for ss=1:length(sites)
tmpdata=DWER.data.(sites{ss}).SAL;

if inpolygon(tmpdata.X,tmpdata.Y,shp(10).X,shp(10).Y)
    disp(sites{ss});

    if inc==1
        dateall=tmpdata.Date;
        dataall=tmpdata.Data;
    else
        dateall=[dateall;tmpdata.Date];
        dataall=[dataall;tmpdata.Data];
    end
    inc=inc+1;

end

end

%% check out IMOS BGC data

timearray=dateall;
SAL =dataall;

timeuniq=unique(timearray);
polys=6; % for polygon at IMOS

        for t=1:length(timeuniq)
            tmpind1=find(timearray==(timeuniq(t)));
           % tmpdepth=depth(tmpind1);
            tmpdata=SAL(tmpind1);
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

        save([outDIR,'exported_SAL_south.mat'],'raw','output','-mat','-v7.3')

