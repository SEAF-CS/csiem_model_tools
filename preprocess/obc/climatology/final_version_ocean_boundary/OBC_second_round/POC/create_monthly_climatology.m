
function [output] = create_monthly_climatology(timearray, rawdata)
%timearray=TSSorganic.Date;
%tmpdata0 =TSSorganic.Data*0.5/12*1000;

timeuniq=unique(timearray);
%polys=3; % for polygon at IMOS

for t=1:length(timeuniq)
    tmpind1=find(timearray==(timeuniq(t)));
    % tmpdepth=depth(tmpind1);
    tmpdata=rawdata(tmpind1);
    Datauniq(t)=mean(tmpdata(~isnan(tmpdata)));
end

timevec=datevec(timeuniq);

rawUniq.time=timeuniq;
rawUniq.data=Datauniq;

for mm=1:12
    inds=find(timevec(:,2)==mm);
    tmpAMM=Datauniq(inds);
    Datamonthly(mm)=mean(tmpAMM(~isnan(tmpAMM)));
end
Datamonthly(isnan(Datamonthly))=mean(Datamonthly(~isnan(Datamonthly)));


datearray=datenum(1980,1:540,1);

for dd=1:length(datearray)-1
    output.time(dd)=datearray(dd);
    tmpInd=find(timeuniq>datearray(dd) & timeuniq<=datearray(dd+1));
    if isempty(tmpInd)
        newD=datevec(datearray(dd));
        output.data(dd)=Datamonthly(newD(2));
    else
        newAMM=Datauniq(tmpInd);
        output.data(dd)=mean(newAMM(~isnan(newAMM)));
    end
end

end