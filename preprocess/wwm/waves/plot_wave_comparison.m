clear; close all;

sites={'AWAC1','AWAC2','Cath1','Cath2','DC','Stirling','Parmelia','Rottnest','S01','S02'};
stdvars={'DIR','HS','TPER'};
sources={'SWAN Grid-A';...
    'SWAN Grid-B';...
    'SWAN Grid-C';...
    'WWM REG';...
    'WWM CS';...
    'INTERP Grid-A';...
    'INTERP Grid-B';...
    'INTERP Grid-C';...
    'AWAC'};

exports={'SWAN_Grid_A_sites.mat';...
    'SWAN_Grid_B_sites.mat';...
    'SWAN_Grid_C_sites.mat';...
    'WWM_REG_sites.mat';...
    'WWM_CS_sites.mat';...
    'INTERP_Grid_A_sites.mat';...
    'INTERP_Grid_B_sites.mat';...
    'INTERP_Grid_C_sites.mat';...
    'AWAC_sites.mat'};

HSuplim=[4 4 4 3 5 2 5 8 2 2];
TPlim=20;

%% 

outdir='.\Whole_comparison_2013\';

if ~exist(outdir,'dir')
    mkdir(outdir);
end

gcf=figure;
    set(gcf,'Position',[100 100 1500 1000]);
    set(0,'DefaultAxesFontSize',15);
    
    datearray=datenum(2013,1:3:13,1);
    colors=[166,206,227;...
31,120,180;...
178,223,138;...
51,160,44;...
251,154,153;...
227,26,28;...
253,191,111;...
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
            plot(data2.(sites{ss}).time,data2.(sites{ss}).HS,'Color',colors(ii,:));
            hold on;
            
            set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
                datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
            set(gca,'ylim',[0 HSuplim(ss)]);
            title(['(a) ',sites{ss},' - significant wave height']);
            ylabel('m');
            
            subplot(3,1,2);
            plot(data2.(sites{ss}).time,data2.(sites{ss}).DIR,'Color',colors(ii,:));
            hold on;
            
            set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
                datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
            set(gca,'ylim',[0 360]);
            title(['(b) ',sites{ss},' - wave direction']);
            ylabel('degrees');
            
            subplot(3,1,3);
            plot(data2.(sites{ss}).time,data2.(sites{ss}).TPER,'Color',colors(ii,:));
            hold on;
            
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

