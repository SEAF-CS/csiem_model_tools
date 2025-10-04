clear; close all;

ESA=load('W:\csiem\csiem-marvl-dev\data\agency\csiem_ESA_bysite_public.mat');

data=ESA.csiem.ESA_GC_Polygon_3;
data2=ESA.csiem.ESA_GC_Point_11;
vars={'Diato','GREEN','Dino','PROKAR','HAPTO','PROCHLO','MICRO','NANO', 'PICO','WQ_DIAG_PHY_TCHLA'};
varnames={'Diatom','Green Algae','Dinoflagellates','Haptophytes','Prochlorococcus',...
    'Prokaryotes','Microplankton','Nanoplankton','Picoplankton','Total Chlorophyll-a'};

%%

data.GREEN.Data=data.GREEN.Data+data.HAPTO.Data;
data.PROKAR.Data=data.PROKAR.Data+data.PROCHLO.Data;

data2.GREEN.Data=data2.GREEN.Data+data2.HAPTO.Data;
data2.PROKAR.Data=data2.PROKAR.Data+data2.PROCHLO.Data;

for v=1:4
    if v==1
        data.total=data.(vars{v}).Data;
        data2.total=data2.(vars{v}).Data;
    else
        data.total=data.total+data.(vars{v}).Data;
        data2.total=data2.total+data2.(vars{v}).Data;
    end
end

for v=1:4
    rawdata=data.(vars{v}).Data./data.total;
    timearray=data.(vars{v}).Date;
    compos.(vars{v}) = create_monthly_climatology(timearray, rawdata);

    rawdata=data2.(vars{v}).Data./data2.total;
    timearray=data2.(vars{v}).Date;
    compos2.(vars{v})=create_monthly_climatology(timearray, rawdata);
end

IMOS=load('..\..\datasets\processed_IMOS_udates_allvars.mat');
DWER=load('..\..\datasets\processed_DWER_udates_allvars.mat');

rawdata=IMOS.dataout.WQ_DIAG_PHY_TCHLA.Data;
timearray=IMOS.dataout.WQ_DIAG_PHY_TCHLA.Date;
IMOSTCHLA=create_monthly_climatology(timearray, rawdata);

rawdata=DWER.dataout.WQ_DIAG_PHY_TCHLA.Data;
timearray=DWER.dataout.WQ_DIAG_PHY_TCHLA.Date;
DWERTCHLA=create_monthly_climatology(timearray, rawdata);

for v=1:4
    final.(vars{v}) = IMOSTCHLA.data.*compos.(vars{v}).data;
    final2.(vars{v}) = DWERTCHLA.data.*compos2.(vars{v}).data;
end


%%

for v=1:4
    output=[];

for polys=1:6

    if (polys>1 && polys<6)

        output.(['poly',num2str(polys)]).time=IMOSTCHLA.time;
        output.(['poly',num2str(polys)]).data=final.(vars{v});
    else

        output.(['poly',num2str(polys)]).time=DWERTCHLA.time;
        output.(['poly',num2str(polys)]).data=final2.(vars{v});
    end
end

save(['.\','exported_',vars{v},'.mat'],'output','-mat','-v7.3')

end
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

% %% read data
% 
% hfig = figure('visible','on','position',[304         166        1271         812]);
% 
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf,'paperposition',[0.635 6.35 30.32 20]*0.8);
% datearray=datenum(2004:2:2024,1,1);
% 
% %yyaxis left;
% for v=1:4
%     tmp=final.(vars{v});
%     plotdata(v,:)=tmp;
% 
%     tmp2=final2.(vars{v});
%     plotdata2(v,:)=tmp2;
% 
% end
% 
% colors=[228,26,28;...
% 55,126,184;...
% 77,175,74;...
% 152,78,163;...
% 255,127,0;...
% 255,255,51;...
% 166,86,40;...
% 247,129,191;...
% 153,153,153]./255;
% 
% wl=0.8;wd=0.36;
% 
% pos1=[0.1 0.58 wl wd];
% pos2=[0.1 0.08 wl wd];
% % pos3=[0.1 0.38 wl wd];
% % pos4=[0.5 0.38 wl wd];
% % pos5=[0.1 0.08 wl wd];
% % pos6=[0.5 0.08 wl wd];
% % pos7=[0.85 0.72 0.12 0.12];
% % pos8=[0.85 0.43 0.12 0.06];
% % pos9=[0.85 0.18 0.12 0.03];
% 
% axes('Position',pos1);
% 
% ha=area(IMOSTCHLA.time,plotdata','LineStyle','none');
% colororder(colors)
% hold on;
% 
% set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
% ylabel('Biomass (\mug CHLA/L)');
% set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
% title('(a) Monthly Phytoplankton Function Types (PFTs) - IMOS offshore')
% hl=legend('DIATOM','GREEN','DINO','PICO');
% 
% axes('Position',pos2);
% 
% ha=area(DWERTCHLA.time,plotdata2','LineStyle','none');
% colororder(colors)
% hold on;
% 
% set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
% ylabel('Biomass (\mug CHLA/L)');
% set(gca,'ylim',[0 2],'YTick',0:0.5:2,'YTickLabel',{'0.0','0.5','1.0','1.5','2.0'});
% title('(b) Monthly Phytoplankton Function Types (PFTs) - DWER nearshore')
% 
% hl=legend('DIATOM','GREEN','DINO','PICO');
% %set(hl,'Position',pos9);
% 
% 
% img_name ='Phytoplankton_composition_timeseries_monthly.png';
% 
% saveas(gcf,img_name);
% 
% % %% read data
% % 
% % hfig = figure('visible','on','position',[304         166        1271         812]);
% % 
% % set(gcf, 'PaperPositionMode', 'manual');
% % set(gcf, 'PaperUnits', 'centimeters');
% % set(gcf,'paperposition',[0.635 6.35 30.32 25]*0.8);
% % 
% % pos1=[0.1 0.5 0.3 0.3];
% % pos2=[0.5 0.5 0.3 0.3];
% % pos3=[0.1 0.1 0.3 0.3];
% % pos4=[0.5 0.1 0.3 0.3];
% % pos5=[0.85 0.60 0.12 0.2];
% % pos6=[0.85 0.20 0.12 0.1];
% % 
% % axes('Position',pos1);
% % 
% % pie(piedata(1:6)*10);
% % title({'(a) Phytoplankton Functional Types ','at IMOS offshore station'});
% % 
% % axes('Position',pos2);
% % 
% % pie(piedata2(1:6)*10);
% % title({'(b) Phytoplankton Functional Types ','at DWER nearshore station'});
% % 
% % hl=legend(varnames(1:6));
% % set(hl,'Position',pos5);
% % hold on;
% % 
% % axes('Position',pos3);
% % 
% % pie(piedata(7:9)*10);
% % title({'(c) Phytoplankton size composition ','at IMOS offshore station'});
% % 
% % axes('Position',pos4);
% % 
% % pie(piedata2(7:9)*10);
% % title({'(d) Phytoplankton size composition ','at DWER nearshore station'});
% % 
% % hl=legend(varnames(7:9));
% % set(hl,'Position',pos6);
% % img_name ='Phytoplankton_composition_piechart_v2.png';
% % 
% % saveas(gcf,img_name);