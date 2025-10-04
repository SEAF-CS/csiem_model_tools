clear; close all;

vars={'SAL','TEMP'};
datearray=datenum(2008:2:2024,1,1);
titles={'Salinity','Temperature'};
units={'PSU','degree C'};


IMOS=load('..\processed_IMOS_udates.mat');
DWER=load('..\processed_DWER_udates.mat');
ROMS=load('E:\CS_BC\ROMS\ROMS_merged_2011_2023.mat');

%%

%tbl = readtable('TemperatureData.csv');

%%

hfig3 = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 12]);
datearray=datenum(2008:2:2024,1,1);
%monthOrder = {'January','February','March','April','May','June','July', ...
%    'August','September','October','November','December'};
monthOrder = {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
    'Aug','Sepr','Oct','Nov','Dec'};

for v=1:length(vars)
    subplot(2,2,v);


    date0=IMOS.dataout.(vars{v}).Date;
    data0=IMOS.dataout.(vars{v}).Data;

    dvec=datevec(date0);
    for i=1:length(data0)
        Monthss{i}=monthOrder{dvec(i,2)};
        dataSource{i}='IMOS-offshore';
    end

    date1=ROMS.merged.site1.time; 
    if v==1
    data1=ROMS.merged.site1.SAL; 
    else
    data1=ROMS.merged.site1.TEMP; 
    end

    dvec1=datevec(date1);
    l=length(date0);

    for j=1:length(data1)
        date0(l+j)=date1(j);
        data0(l+j)=data1(j);
        Monthss{l+j}=monthOrder{dvec1(j,2)};
        dataSource{l+j}='ROMS';
    end


    T=table(date0,data0,Monthss,dataSource);
    T.Monthss = categorical(T.Monthss,monthOrder);
    boxchart(T.Monthss,T.data0,'GroupByColor',T.dataSource)

     box on;
     ylabel(units{v})
% 
     title(titles{v});
   %  if v==2
         hl=legend;
   %      set(hl,'Position',[0.8 0.96 0.12 0.01]);
   %  end
     clear data* date* dvec* Monthss T dataSource;
end

for v=1:length(vars)
    subplot(2,2,v+2);


    date0=DWER.dataout.(vars{v}).Date;
    data0=DWER.dataout.(vars{v}).Data;

    dvec=datevec(date0);
    for i=1:length(data0)
        Monthss{i}=monthOrder{dvec(i,2)};
        dataSource{i}='DWER-nearshore';
    end

    date1=ROMS.merged.site2.time; 
    if v==1
    data1=ROMS.merged.site2.SAL; 
    else
    data1=ROMS.merged.site2.TEMP; 
    end

    dvec1=datevec(date1);
    l=length(date0);

    for j=1:length(data1)
        date0(l+j)=date1(j);
        data0(l+j)=data1(j);
        Monthss{l+j}=monthOrder{dvec1(j,2)};
        dataSource{l+j}='ROMS';
    end


    T=table(date0,data0,Monthss,dataSource);
    T.Monthss = categorical(T.Monthss,monthOrder);
    boxchart(T.Monthss,T.data0,'GroupByColor',T.dataSource)

     box on;
     ylabel(units{v})
% 
     title(titles{v});
    % if v==2
         hl=legend;
    %     set(hl,'Position',[0.8 0.96 0.12 0.01]);
    % end
     clear data* date* dvec* Monthss T dataSource;
end

img_name ='boxchat_ROMS.png';

saveas(gcf,img_name);