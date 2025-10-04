clear; close all;

sites={'AWAC1','AWAC2','Cath1','Cath2','DC','Stirling','Parmelia','Rottnest','S01','S02'};
stdvars={'DIR','HS','TPER'};
sources={'SWAN Grid-B';...
    'SWAN Grid-C';...
    'WWM CS';...
    'TFV Grid-B';...
 %   'TFV WWM';...
    'AWAC'};

exports={'SWAN_Grid_B_sites.mat';...
    'SWAN_Grid_C_sites.mat';...
    'WWM_CS_sites.mat';...
    'TFV_Bgrid_sites.mat';...
  %  'TFV_WWM_sites.mat';...
    'AWAC_sites.mat'};

HSuplim=[4 4 4 3 5 2 5 8 2 2];
TPlim=20;

%% 

outdir='.\Whole_comparison_2013SEP_scatter_TFV_WWM\';

if ~exist(outdir,'dir')
    mkdir(outdir);
end

gcf=figure;
    set(gcf,'Position',[100 100 1500 1000]);
    set(0,'DefaultAxesFontSize',15);
    
    datearray=datenum(2013,9,1:5:35); %datenum(2013,4,1:5:35);
    colors=[31,120,180;...
51,160,44;...
227,26,28;...
255,127,0;...
202,178,214;...
106,61,154]./255;
    
for ss=1:length(sites)
    clf;
    disp(sites{ss});
    
    inc=1;
    for ii=1:length(sources)
        data=load(exports{ii});
        data2=data.output;
        
        if isfield(data2,sites{ss})
            disp(sources{ii});
            legends{inc}=sources{ii};inc=inc+1;
            subplot(3,1,1);
           % plot(data2.(sites{ss}).time,data2.(sites{ss}).HS,'Color',colors(ii,:));
           if strcmp(sources{ii},'AWAC')
            scatter(data2.(sites{ss}).time,data2.(sites{ss}).HS,2,...
            'MarkerEdgeColor','k','MarkerFaceColor','k');
        
           elseif strcmp(sources{ii},'WWM CS')
               scatter(data2.(sites{ss}).time+8/24,data2.(sites{ss}).HS,1,...
            'MarkerEdgeColor',colors(ii,:),'MarkerFaceColor',colors(ii,:));
               
           else
               scatter(data2.(sites{ss}).time,data2.(sites{ss}).HS,1,...
            'MarkerEdgeColor',colors(ii,:),'MarkerFaceColor',colors(ii,:));
           end
            hold on;box on;
            
            set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
                datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
            set(gca,'ylim',[0 HSuplim(ss)]);
            title(['(a) ',sites{ss},' - significant wave height']);
            ylabel('m');
            
            subplot(3,1,2);
        %   plot(data2.(sites{ss}).time,data2.(sites{ss}).DIR,'Color',colors(ii,:));
        
        if strcmp(sources{ii},'AWAC')
            scatter(data2.(sites{ss}).time,data2.(sites{ss}).DIR,2,...
            'MarkerEdgeColor','k','MarkerFaceColor','k');
        
           elseif strcmp(sources{ii},'WWM CS')
               scatter(data2.(sites{ss}).time+8/24,data2.(sites{ss}).DIR,1,...
            'MarkerEdgeColor',colors(ii,:),'MarkerFaceColor',colors(ii,:));
               
        else
               
             scatter(data2.(sites{ss}).time,data2.(sites{ss}).DIR,1,...
            'MarkerEdgeColor',colors(ii,:),'MarkerFaceColor',colors(ii,:));
        end
        
            hold on;box on;
            
            set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
                datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
            set(gca,'ylim',[0 360]);
            title(['(b) ',sites{ss},' - wave direction']);
            ylabel('degrees');
            
            subplot(3,1,3);
         %   plot(data2.(sites{ss}).time,data2.(sites{ss}).TPER,'Color',colors(ii,:));
         if strcmp(sources{ii},'AWAC')
            scatter(data2.(sites{ss}).time,data2.(sites{ss}).TPER,2,...
            'MarkerEdgeColor','k','MarkerFaceColor','k');
        
           elseif strcmp(sources{ii},'WWM CS')
               scatter(data2.(sites{ss}).time+8/24,data2.(sites{ss}).TPER,1,...
            'MarkerEdgeColor',colors(ii,:),'MarkerFaceColor',colors(ii,:));
               
        else
             scatter(data2.(sites{ss}).time,data2.(sites{ss}).TPER,1,...
            'MarkerEdgeColor',colors(ii,:),'MarkerFaceColor',colors(ii,:));
         end
            hold on;box on;
            
            set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
                datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
            set(gca,'ylim',[0 20]);
            title(['(c) ',sites{ss},' - wave period']);
            ylabel('seconds');
        end
    end
    
    hl=legend(legends);
    set(hl,'Position',[0.3 0.02 0.4 0.02],'NumColumns',length(legends));
    
    print(gcf,[outdir,'comparison_',sites{ss},'.png'],'-dpng');
    clear legends inc;
end

