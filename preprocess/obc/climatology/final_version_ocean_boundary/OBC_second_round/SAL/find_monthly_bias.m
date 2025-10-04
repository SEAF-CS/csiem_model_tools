% 
% clear; close all;
% 
% IMOS=load('..\..\datasets\processed_IMOS_udates.mat');
% DWER=load('..\..\datasets\processed_DWER_udates.mat');
% ROMS=load('E:\CS_BC\datasets\ROMS\ROMS_merged_2001_2023.mat');
% CSIRO=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_CSIRO_public.mat');
% 
% vars={'SAL','TEMP'};
% 
% IMOS.dataout.SAL.Data(2835:2890)=NaN;
% IMOS.dataout.SAL.Data(IMOS.dataout.SAL.Data==35.6449)=NaN;
% IMOS.dataout.SAL.Data(3296:3385)=NaN;

%% find monthly bias for IMOS SAL

function [datearray, outdata, newdata]=find_monthly_bias(IMOSdate, IMOSdata, ROMSdate, ROMSdata)
%IMOSdate=IMOS.dataout.SAL.Date;
%IMOSdata=IMOS.dataout.SAL.Data;
IMOSdatevec=datevec(IMOSdate);

%ROMSdate=ROMS.merged.site1.time;
%ROMSdata=ROMS.merged.site1.SAL;
ROMSdatevec=datevec(ROMSdate);

datearray=datenum(1980,1:540,1);
inc=1;

for dd=1:length(datearray)-1
   % output.time(dd)=datearray(dd);
    tmpInd=find(IMOSdate>datearray(dd) & IMOSdate<=datearray(dd+1));
    tmpInd2=find(ROMSdate>datearray(dd) & ROMSdate<=datearray(dd+1));
    if ~isempty(tmpInd) && ~isempty(tmpInd2)
        tmpdata0=IMOSdata(tmpInd);
        tmpdata1=tmpdata0(~isnan(tmpdata0));
        tmpdata2=ROMSdata(tmpInd2);

        if ~isempty(tmpdata1)
            output.time(inc)=datearray(dd);
            output.IMOS(inc)=mean(tmpdata1);
            output.ROMS(inc)=mean(tmpdata2);
            inc=inc+1;
        end
    end
end

dvec1=datevec(output.time);

for mm=1:12
    tmpind3=find(dvec1(:,2)==mm);
    monthlyBias(mm)=mean(output.IMOS(tmpind3))/mean(output.ROMS(tmpind3));
end

%%

vec3=datevec(datearray);
for dd=1:length(datearray)-1
   % output.time(dd)=datearray(dd);
   
    tmpInd=find(IMOSdate>datearray(dd) & IMOSdate<=datearray(dd+1));
    tmpInd2=find(ROMSdate>datearray(dd) & ROMSdate<=datearray(dd+1));
    if ~isempty(tmpInd) && ~isempty(tmpInd2)
        tmpdata0=IMOSdata(tmpInd);
        tmpdata1=tmpdata0(~isnan(tmpdata0));
        tmpdata2=ROMSdata(tmpInd2);

        if ~isempty(tmpdata1)
            outdata(dd)=mean(tmpdata1)/mean(tmpdata2);
        else
            outdata(dd)=monthlyBias(vec3(dd,2));
        end

    else
        outdata(dd)=monthlyBias(vec3(dd,2));

    end
end

%%
for j=1:length(ROMSdate)
    ind4=find(vec3(:,1)==ROMSdatevec(j,1) & vec3(:,2)==ROMSdatevec(j,2));
    newdata(j)=ROMSdata(j)*outdata(ind4);
end


end