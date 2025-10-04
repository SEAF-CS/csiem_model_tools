% export to CSV files

load extracted_for_Dan_2023_OBC.mat;

% loadnames={'SAL','WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT','WQ_PHS_FRP','WQ_DIAG_OGM_POC_SWI','WQ_DIAG_PHY_PHY_SWI_C'};
% short_names={'SAL','OXY','AMM','NIT','FRP','POCSWI','PHYSWI'};
% long_names={'salinity','oxygen',...
%     'ammonium','nitrate','phosphate','POC settling','PHY setting'};
% units ={'PSU','mmol/m3','mmol/m3','mmol/m3','mmol/m3','mmol/m2/d','mmol/m2/d'};

loadnames={'SAL','WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT','WQ_PHS_FRP','WQ_DIAG_OGM_POC_SWI','WQ_DIAG_PHY_PHY_SWI_C',...
    'WQ_OGM_DOC','WQ_OGM_DON','WQ_OGM_DOP'};
short_names={'SAL','OXY','AMM','NIT','FRP','POCSWI','PHYSWI',...
    'DOC','DON','DOP'};
long_names={'salinity','oxygen',...
    'ammonium','nitrate','phosphate','POC settling','PHY setting',...
    'DOC','DON','DOP'};
units ={'PSU','mmol/m3','mmol/m3','mmol/m3','mmol/m3','mmol/m2/d','mmol/m2/d',...
    'mmol/m3','mmol/m3','mmol/m3'};

%loadnames2={'EXTCV','WVHT','WVPER','WVDIR'};

header='Date';
header2 ='Unit';
for i=1:length(loadnames)
    header=[header,',',long_names{i}];
    header2=[header2,',',units{i}];
end

%%

sitenames={'center','nearshore'};

for t=1:length(sitenames)
    
    disp(sitenames{t});
    
    data=output.(sitenames{t});
    %tmp=data.WQ_OGM_DOC.bottom;
    %data.EXTCV=mean(tmp,1);
    
    fileID = fopen(['site_export_data_',sitenames{t},'_2023_OBC.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data.WQ_OGM_DOC.date;
%     data.WQ_OGM_DOC.bottom(1:500)=data.WQ_OGM_DOC.bottom(501:1000);
%     data.WQ_OGM_DON.bottom(1:500)=data.WQ_OGM_DON.bottom(501:1000);
%     data.WQ_OGM_DOP.bottom(1:500)=data.WQ_OGM_DOP.bottom(501:1000);
%     
    for j=2:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames)
            fprintf(fileID,',%6.4f',data.(loadnames{v}).bottom(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
    
    
end