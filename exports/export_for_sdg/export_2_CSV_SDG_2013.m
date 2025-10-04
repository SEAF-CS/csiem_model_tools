% export to CSV files

load extracted_for_Dan_2015.mat;

loadnames={'SAL','WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT','WQ_PHS_FRP','WQ_DIAG_OGM_POC_SWI','WQ_DIAG_PHY_PHY_SWI_C'};
short_names={'SAL','OXY','AMM','NIT','FRP','POCSWI','PHYSWI'};
long_names={'salinity','oxygen',...
    'ammonium','nitrate','phosphate','POC settling','PHY setting'};
units ={'PSU','mmol/m3','mmol/m3','mmol/m3','mmol/m3','mmol/m2/d','mmol/m2/d'};

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
    tmp=data.SAL.bottom;
    %data.EXTCV=mean(tmp,1);
    
    fileID = fopen(['site_export_data_',sitenames{t},'_2015.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data.SAL.date;
    
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