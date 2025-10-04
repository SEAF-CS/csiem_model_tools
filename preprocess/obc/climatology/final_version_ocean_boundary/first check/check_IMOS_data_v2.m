clear; close all;

vars={'SAL','TEMP','WQ_PHS_FRP','WQ_NIT_AMM','WQ_NIT_NIT','WQ_OXY_OXY','WQ_DIAG_TOT_TSS','WQ_DIAG_PHY_TCHLA'};
readdata=1;

if readdata
    for v=1:length(vars)
        v2i=vars{v};
        matfile=['..\IMOS_data_',v2i,'.mat'];
        disp(matfile);
        data=load(matfile);

        sites=fieldnames(data.data);
        
        if v==2
            sites={'IMOS_amnmprofile_NRSROT_PROFILE_Profile_13'};
        end

        datasum.(v2i).Date=[];
        datasum.(v2i).Data=[];

        for s=1:length(sites)
            disp(sites{s});
            tmpdata2=data.data.(sites{s}).(v2i);

            tmpd=tmpdata2.Depth;
            if v<=3
              inds=find(tmpd>-30);
            else
              inds=find(tmpd>-10);
            end

            tmpdepth=tmpdata2.Depth(inds);
            tmpdate=tmpdata2.Date(inds);
            tmpdata=tmpdata2.Data(inds);

            if v==1
                tmpdata(tmpdata<30)=NaN;
            end

            if v==6
                tmpdata(tmpdata<180)=NaN;
            end

                datasum.(v2i).Date=[datasum.(v2i).Date; floor(tmpdate)];
                datasum.(v2i).Data=[datasum.(v2i).Data; tmpdata];

        end


        udate=unique(datasum.(v2i).Date);
        udate=udate(~isnan(udate));
        inc=1;

        for u=1:length(udate)
            ind0=find(datasum.(v2i).Date==udate(u));
            udata=mean(datasum.(v2i).Data(ind0));

            if ~isnan(udata)
                dataout.(v2i).Date(inc)=udate(u);
                dataout.(v2i).Data(inc)=udata;
                inc=inc+1;
            end
        end

    end

    save('processed_IMOS_udates_v2.mat','dataout','datasum','-mat','-v7.3');

else
    load processed_IMOS_udates_v2.mat;
end

%%

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2008:2:2024,1,1);
titles={'Salinity','Temperature','FRP','AMM','NIT','DO','TSS','TCHLA'};
units={'PSU','degree C','\muM','\muM','\muM','\muM','mg/L','\mug/L'};

for v=1:length(vars)
    subplot(4,2,v);

   % plot(dataout.(vars{v}).Date,dataout.(vars{v}).Data,'k');
    scatter(dataout.(vars{v}).Date,dataout.(vars{v}).Data,6,'k','filled');

    set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
    % set(gca,'ylim',[34 37]);
    box on;
    ylabel(units{v})

    title(titles{v});
    % hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
    % set(hl,'Location','eastoutside');

end

img_name ='check_IMOS_udate_v2.png';

saveas(gcf,img_name);


%%

hfig3 = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 30.32 20]);
datearray=datenum(2008:2:2024,1,1);

for v=1:length(vars)

    date0=dataout.(vars{v}).Date;
    data0=dataout.(vars{v}).Data;

    dvec=datevec(date0);
    boxdata=[];
    gdata=[];

    subplot(4,2,v);

    for mm=1:12
        ind0=find(dvec(:,2)==mm);
        data01=data0(ind0);
        boxchart(mm*ones(size(data01)), data01);
        hold on;
%         boxdata=[boxdata, data01];
%         g01=repmat({num2str(mm)},length(data01),1);
%         gdata=[gdata; g01];
    end

        
    

%   boxplot(boxdata,gdata,'PlotStyle','compact');
% 
     set(gca,'xlim',[0 13],'XTick',1:12);
%     % set(gca,'ylim',[34 37]);
     box on;
     ylabel(units{v})
% 
     title(titles{v});
%     set(gca,'Fontsize',6);
%     % hl=legend; %('IMOS2','IMOS5','IMOS11','IMOS61','CMEM');
%     % set(hl,'Location','eastoutside');
if v>=7
    xlabel('months');
end

end

img_name ='check_IMOS_boxchat_v2.png';

saveas(gcf,img_name);