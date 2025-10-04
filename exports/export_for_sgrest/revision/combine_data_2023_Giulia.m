clear; close all;

loadnames={'WQ_DIAG_NCS_D_TAUB','SAL','TEMP','WQ_DIAG_TOT_LIGHT','WQ_DIAG_TOT_PAR','V_x','V_y','WQ_DIAG_TOT_EXTC','WVHT','WVDIR','WVPER','TAUC','TAUW','TAUCW'};
short_names={'TAUB','SAL','TEMP','LIGHT','PAR','Vx','Vy','EXTC','WVHT','WVDIR','WVPER','TAUC','TAUW','TAUCW'};
long_names={'bottom stress', 'salinity','temperature',...
    'light','Photosynthetically active radiation','Vx','Vy','EXTC','WVHT','WVDIR','WVPER','TAUC','TAUW','TAUCW'};
units ={'N/m2','PSU','degrees','W/m2','W/m2','m/s','m/s','/m','m','degree','s','N/m2','N/m2','N/m2'};

sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

%%

outDir='.\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end


for ll=1:length(loadnames)
    tic;

    loadname=loadnames{ll};
    disp(['loading ',loadname,' ...']);
    
    infile=[outDir,'extracted_2023_',loadname,'.mat'];
    data=load(infile);
    
    for site=1:length(sitenames)
        disp(sitenames{site});
        tmp=data.output.(sitenames{site}).(loadname);

        output.(sitenames{site}).(loadname)=tmp;
    end

    toc;
end

outfile=[outDir,'extracted_2023_combined.mat'];
save(outfile,'output','-mat','-v7.3');

%% plot export

outDir='.\plotting\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

figure(1);
def.dimensions = [20 10]; % Width & Height in cm
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])  ;

datearray=datenum(2022,11:3:29,1);
timesteps=output.Collection.SAL.date-8/24;

for vv=1:length(loadnames)
    clf;
    loadname=loadnames{vv};
for site=1:length(sitenames)

    if vv<9
    plot(timesteps,output.(sitenames{site}).(loadname).bottom);hold on;
    else
    plot(timesteps,output.(sitenames{site}).(loadname));hold on;
    end
end

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm'));
hl=legend(sitenames);
set(hl,'Location','east');

set(gca,'FontName','Times New Roman');
title(strrep(loadname,'_','-'));

outputName=[outDir,'timeseries-',loadname,'.jpg'];
print(gcf,'-dpng',outputName);

end

%%

figure(1);
def.dimensions = [20 10]; % Width & Height in cm
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters','PaperOrientation', 'Portrait');
xSize = def.dimensions(1);
ySize = def.dimensions(2);
xLeft = (21-xSize)/2;
yTop = (30-ySize)/2;
set(gcf,'paperposition',[0 0 xSize ySize])  ;

colors=[228,26,28;...
55,126,184;...
77,175,74;...
152,78,163;...
255,127,0;...
255,255,51;...
166,86,40;...
247,129,191;...
153,153,153]./255;

datearray=datenum(2022,11:3:29,1);
timesteps=output.Collection.SAL.date;

for vv=1:length(loadnames)+1
    clf;
    if vv<length(loadnames)+1
    loadname=loadnames{vv};
    else
    loadname='Current_Speed';

    end
for site=1:length(sitenames)

    if vv<9
        if site==8
         plot(timesteps,movmean(output.(sitenames{site}).(loadname).bottom,6*30),'k');hold on;
        else
    plot(timesteps,movmean(output.(sitenames{site}).(loadname).bottom,6*30),'Color',colors(site,:));hold on;
        end
    elseif vv==length(loadnames)+1
        v1=output.(sitenames{site}).V_x.bottom;
        v2=output.(sitenames{site}).V_y.bottom;
        tv=sqrt(v1.^2+v2.^2);

        if site==8
         plot(timesteps,movmean(tv,6*30),'k');hold on;
        else
    plot(timesteps,movmean(tv,6*30),'Color',colors(site,:));hold on;
        end

    else
        if site==8
         plot(timesteps,movmean(output.(sitenames{site}).(loadname),6*30),'k');hold on;
        else
    plot(timesteps,movmean(output.(sitenames{site}).(loadname),6*30),'Color',colors(site,:));hold on;
        end
    end
end

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mm'));
hl=legend(sitenames);
set(hl,'Location','east');

set(gca,'FontName','Times New Roman');
title(strrep(loadname,'_','-'));

outputName=[outDir,'movmean-timeseries-',loadname,'.jpg'];
print(gcf,'-dpng',outputName);

end

