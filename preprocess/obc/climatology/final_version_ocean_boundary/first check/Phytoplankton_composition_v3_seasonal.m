clear; close all;

ESA=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_ESA_bysite_public.mat');

data=ESA.csiem.ESA_GC_Polygon_3;
data2=ESA.csiem.ESA_GC_Point_11;
vars={'Diato','GREEN','Dino','HAPTO','PROCHLO','PROKAR','MICRO','NANO', 'PICO','WQ_DIAG_PHY_TCHLA'};
varnames={'Diatom','Green Algae','Dinoflagellates','Haptophytes','Prochlorococcus',...
    'Prokaryotes','Microplankton','Nanoplankton','Picoplankton','Total Chlorophyll-a'};

%% Phytoplankton product information
% expressed as Chlorophyll a concentration in sea water
% (mg m-3), includes the following variables: DIATO
% (Diatoms), DINO (Dinophytes or Dinoflagellates), CRYPTO
% (Cryptophytes), GREEN (Green algae & Prochlorophytes)
% and PROKAR (Prokaryotes); MICRO (Micro-
% phytoplankton), NANO (Nano-phytoplankton) and PICO
% (Pico-phytoplankton) also known as “Phytoplankton Size
% Classes” (PSCs). MICRO consist of DIATO and DINO, NANO
% of CRYPTO and half of the GREEN group and PICO includes
% half GREEN and PROKAR. Note: the development of the
% algorithms applied for the PFT retrieval in this product is
% based on a different methodology than that used for the
% PFT estimate provided in other products (GLO and ATL).
% For more details see the relevant documentation

%% read data

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]*1.0);
datearray=datenum(2004:2:2024,1,1);

%yyaxis left;
for v=1:length(vars)-1
    tmp=data.(vars{v}).Data;tmp(tmp>2)=mean(tmp(tmp<=2));
    plotdata(v,:)=tmp;
    piedata(v)=mean(tmp);
    tmp2=data2.(vars{v}).Data;tmp2(tmp2>4)=mean(tmp2(tmp2<=4));
    plotdata2(v,:)=tmp2;
    piedata2(v)=mean(tmp2);
end

colors=[228,26,28;...
55,126,184;...
77,175,74;...
152,78,163;...
255,127,0;...
255,255,51;...
166,86,40;...
247,129,191;...
153,153,153]./255;

wl=0.35;wd=0.16; wd2=0.23;


for i=1:4
    pos(i,:)=  [0.06 0.975-i*wd2 wl wd];
    pos(i+4,:)=[0.49 0.975-i*wd2 wl wd];
end

pos(9,:)=[0.86 0.65 0.12 0.12];
pos(10,:)=[0.86 0.15 0.12 0.06];

% pos1=[0.1 0.68 wl wd];
% pos2=[0.5 0.68 wl wd];
% pos3=[0.1 0.38 wl wd];
% pos4=[0.5 0.38 wl wd];
% pos5=[0.1 0.08 wl wd];
% pos6=[0.5 0.08 wl wd];
% pos7=[0.85 0.72 0.12 0.12];
% pos8=[0.85 0.43 0.12 0.06];
% pos9=[0.85 0.18 0.12 0.03];

axes('Position',pos(1,:));

ha=area(data.Diato.Date,plotdata(1:6,:)','LineStyle','none');
for i=1:6
    ha(i).FaceColor=colors(i,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(a) Phytoplankton Function Types (PFTs) biomass - IMOS offshore');

axes('Position',pos(2,:));

sumdata=sum(plotdata(1:6,:),1);
for i=1:6
plotdatas(i,:)=plotdata(i,:)./sumdata*100;
end

ha=area(data.Diato.Date,plotdatas','LineStyle','none');
for i=1:6
    ha(i).FaceColor=colors(i,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Composition (%)');
set(gca,'ylim',[0 100],'YTick',0:20:100);
title('(c) Phytoplankton Function Types (PFTs) composition - IMOS offshore');

axes('Position',pos(3,:));

ha=area(data.Diato.Date,plotdata(7:9,:)','LineStyle','none');
for i=1:3
    ha(i).FaceColor=colors(i+6,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(e) Phytoplankton size classes biomass - IMOS offshore');

axes('Position',pos(4,:));

sumdata2=sum(plotdata(7:9,:),1);
for i=7:9
plotdatas(i,:)=plotdata(i,:)./sumdata2*100;
end

ha=area(data.Diato.Date,plotdatas(7:9,:)','LineStyle','none');
for i=1:3
    ha(i).FaceColor=colors(i+6,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 100],'YTick',0:20:100);
title('(g) Phytoplankton size classes composition - IMOS offshore')



%%
clear plotdatas;
axes('Position',pos(5,:));

ha=area(data2.Diato.Date,plotdata2(1:6,:)','LineStyle','none');
for i=1:6
    ha(i).FaceColor=colors(i,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(b) Phytoplankton Function Types (PFTs) biomass- DWER nearshore');

axes('Position',pos(6,:));

sumdata=sum(plotdata2(1:6,:),1);
for i=1:6
plotdatas(i,:)=plotdata2(i,:)./sumdata*100;
end

ha=area(data2.Diato.Date,plotdatas','LineStyle','none');
for i=1:6
    ha(i).FaceColor=colors(i,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Composition (%)');
set(gca,'ylim',[0 100],'YTick',0:20:100);
title('(d) Phytoplankton Function Types (PFTs) composition - DWER nearshore');

hl=legend(varnames(1:6));
set(hl,'Position',pos(9,:));

axes('Position',pos(7,:));

ha=area(data2.Diato.Date,plotdata2(7:9,:)','LineStyle','none');
for i=1:3
    ha(i).FaceColor=colors(i+6,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
title('(f) Phytoplankton size classes biomass- DWER nearshore');

axes('Position',pos(8,:));

sumdata2=sum(plotdata2(7:9,:),1);
for i=7:9
plotdatas(i,:)=plotdata2(i,:)./sumdata2*100;
end

ha=area(data2.Diato.Date,plotdatas(7:9,:)','LineStyle','none');
for i=1:3
    ha(i).FaceColor=colors(i+6,:);
end
%colororder(colors)
hold on;

set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
ylabel('Biomass (\mug CHLA/L)');
set(gca,'ylim',[0 100],'YTick',0:20:100);
title('(i) Phytoplankton size classes composition - DWER nearshore')


hl=legend(varnames(7:9));
set(hl,'Position',pos(10,:));


img_name ='Phytoplankton_composition_seasonal.png';

saveas(gcf,img_name);

%%

t0=datenum(2016,5,1);

ind01=find(abs(data.Diato.Date-t0)==min(abs(data.Diato.Date-t0)));
ind02=find(abs(data2.Diato.Date-t0)==min(abs(data2.Diato.Date-t0)));

tset1=data.Diato.Date(1:ind01);
dset1=plotdata(:,1:ind01);

dvec1=datevec(tset1);

for m=1:12
    inds=find(dvec1(:,2)==m);
    outdata1(m,:)=mean(dset1(:,inds),2);
end

tset12=data.Diato.Date(ind01+1:end);
dset12=plotdata(:,ind01+1:end);

dvec12=datevec(tset1);

for m=1:12
    inds=find(dvec12(:,2)==m);
    outdata12(m,:)=mean(dset12(:,inds),2);
end

tset2=data2.Diato.Date(1:ind02);
dset2=plotdata2(:,1:ind02);

dvec2=datevec(tset2);

for m=1:12
    inds=find(dvec2(:,2)==m);
    outdata2(m,:)=mean(dset2(:,inds),2);
end

tset22=data2.Diato.Date(ind02+1:end);
dset22=plotdata2(:,ind02+1:end);

dvec22=datevec(tset2);

for m=1:12
    inds=find(dvec22(:,2)==m);
    outdata22(m,:)=mean(dset22(:,inds),2);
end

%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2008:2:2024,1,1);

subplot(2,2,1);
tmp=outdata1(:,1:6);
tmps=sum(tmp,2);
for j=1:6
    tmpp(:,j)=tmp(:,j)./tmps;
end

bar(tmpp*100,'stacked');
xlabel('months');ylabel('composition (%)');

subplot(2,2,2);
tmp=outdata12(:,1:6);
tmps=sum(tmp,2);
for j=1:6
    tmpp(:,j)=tmp(:,j)./tmps;
end

bar(tmpp*100,'stacked');
xlabel('months');ylabel('composition (%)');


subplot(2,2,3);
tmp=outdata2(:,1:6);
tmps=sum(tmp,2);
for j=1:6
    tmpp(:,j)=tmp(:,j)./tmps;
end

bar(tmpp*100,'stacked');
xlabel('months');ylabel('composition (%)');

subplot(2,2,4);
tmp=outdata22(:,1:6);
tmps=sum(tmp,2);
for j=1:6
    tmpp(:,j)=tmp(:,j)./tmps;
end

bar(tmpp*100,'stacked');
xlabel('months');ylabel('composition (%)');
