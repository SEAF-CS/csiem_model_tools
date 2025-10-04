clear; close all;

sites={'AWAC1','AWAC2','Cath1','Cath2','DC','Stirling','Parmelia','Rottnest','S01','S02'};
agencies={'CCL','CCL','CoC','CoC','FPA','FPA','FPA','DoT','JPPL','JPPL'};
depths=[-14.6,-7.4,-6.5,-8.5,-13.0,-13.8,-9.0,-73.0,-10,-18];
lons  =[115.704160,  115.679512, 115.728092, 115.745646, 115.686667, 115.744336, 115.701664, 115.407778, 115.762710, 115.730832];
lats  =[-32.079398,  -32.095191, -32.078775, -32.090541, -31.977779, -32.203214, -32.130005, -32.094167, -32.200942, -32.180925];


stdvars={'DIR','HS','TPER'};
sources={'SWAN Grid-A';...
    'SWAN Grid-B';...
    'WWM REG';...
    'WWM CS'};

exports={'SWAN_Grid_A_sites.mat';...
    'SWAN_Grid_B_sites.mat';...
    'WWM_REG_sites.mat';...
    'WWM_CS_sites.mat'};

for ee=1:length(exports)
    data(ee).data=load(exports{ee});
end

HSuplim=[4 4 4 3 5 2 5 8 2 2];
TPlim=20;

%% 

outdir='.\export_to_datalake\';

if ~exist(outdir,'dir')
    mkdir(outdir);
end

for ss=1:length(sites)
    
    if strcmp(sites{ss},'Rottnest')
        data1=data(1).data;
        data2=data(3).data;
    else
        data1=data(2).data;
        data2=data(4).data;
    end
    
    for vv=1:length(stdvars)
        waves.(['SWAN_',sites{ss}]).(stdvars{vv}).data=data1.output.(sites{ss}).(stdvars{vv});
        waves.(['SWAN_',sites{ss}]).(stdvars{vv}).date=data1.output.(sites{ss}).time;
        waves.(['SWAN_',sites{ss}]).(stdvars{vv}).X=lons(ss);
        waves.(['SWAN_',sites{ss}]).(stdvars{vv}).Y=lats(ss);
        
        waves.(['WWM_',sites{ss}]).(stdvars{vv}).data=data2.output.(sites{ss}).(stdvars{vv});
        waves.(['WWM_',sites{ss}]).(stdvars{vv}).date=data2.output.(sites{ss}).time;
        waves.(['WWM_',sites{ss}]).(stdvars{vv}).X=lons(ss);
        waves.(['WWM_',sites{ss}]).(stdvars{vv}).Y=lats(ss);
    end
end

outfile=[outdir,'wave_export.mat'];
save(outfile,'waves','-mat','-v7.3');
        
% 
% gcf=figure;
%     set(gcf,'Position',[100 100 1500 1000]);
%     set(0,'DefaultAxesFontSize',15);
%     
%     datearray=datenum(2013,9,1:5:35);
%     colors=[166,206,227;...
% 31,120,180;...
% 178,223,138;...
% 51,160,44;...
% 251,154,153;...
% 227,26,28;...
% 253,191,111;...
% 255,127,0;...
% 202,178,214;...
% 106,61,154]./255;
%     
% for ss=1:length(sites)
%     clf;
%     disp(sites{ss});
%     
%     inc=1;
%     for ii=1:length(sources)
%         data=load(exports{ii});
%         data2=data.output;
%         
%         if isfield(data2,sites{ss})
%             disp(sources{ii});
%             legends{inc}=sources{ii};inc=inc+1;
%             subplot(3,1,1);
%            % plot(data2.(sites{ss}).time,data2.(sites{ss}).HS,'Color',colors(ii,:));
%            if strcmp(sources{ii},'AWAC')
%             scatter(data2.(sites{ss}).time,data2.(sites{ss}).HS,2,...
%             'MarkerEdgeColor','k','MarkerFaceColor','k');
%         
%            else
%                scatter(data2.(sites{ss}).time,data2.(sites{ss}).HS,1,...
%             'MarkerEdgeColor',colors(ii,:));
%            end
%             hold on;box on;
%             
%             set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
%                 datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
%             set(gca,'ylim',[0 HSuplim(ss)]);
%             title(['(a) ',sites{ss},' - significant wave height']);
%             ylabel('m');
%             
%             subplot(3,1,2);
%         %   plot(data2.(sites{ss}).time,data2.(sites{ss}).DIR,'Color',colors(ii,:));
%         
%         if strcmp(sources{ii},'AWAC')
%             scatter(data2.(sites{ss}).time,data2.(sites{ss}).DIR,2,...
%             'MarkerEdgeColor','k','MarkerFaceColor','k');
%         
%            else
%              scatter(data2.(sites{ss}).time,data2.(sites{ss}).DIR,1,...
%             'MarkerEdgeColor',colors(ii,:));
%         end
%         
%             hold on;box on;
%             
%             set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
%                 datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
%             set(gca,'ylim',[0 360]);
%             title(['(b) ',sites{ss},' - wave direction']);
%             ylabel('degrees');
%             
%             subplot(3,1,3);
%          %   plot(data2.(sites{ss}).time,data2.(sites{ss}).TPER,'Color',colors(ii,:));
%          if strcmp(sources{ii},'AWAC')
%             scatter(data2.(sites{ss}).time,data2.(sites{ss}).TPER,2,...
%             'MarkerEdgeColor','k','MarkerFaceColor','k');
%         
%            else
%              scatter(data2.(sites{ss}).time,data2.(sites{ss}).TPER,1,...
%             'MarkerEdgeColor',colors(ii,:));
%          end
%             hold on;box on;
%             
%             set(gca,'xlim',[datearray(1) datearray(end)],'XTick',...
%                 datearray,'XTickLabel',datestr(datearray,'mmm/yyyy'));
%             set(gca,'ylim',[0 20]);
%             title(['(c) ',sites{ss},' - wave period']);
%             ylabel('seconds');
%         end
%     end
%     
%     hl=legend(legends);
%     set(hl,'Position',[0.3 0.02 0.4 0.02],'NumColumns',length(legends));
%     
%     print(gcf,[outdir,'comparison_',sites{ss},'.png'],'-dpng');
%     clear legends inc;
% end

