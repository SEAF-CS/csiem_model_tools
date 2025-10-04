% export to CSV files

load extracted_for_Giulia_v2.mat;


loadnames={'WQ_DIAG_NCS_D_TAUB','SAL','TEMP','WQ_DIAG_TOT_LIGHT','WQ_DIAG_TOT_PAR','V_x','V_y','WQ_DIAG_TOT_EXTC','WVHT','WVPER','WVDIR'};
short_names={'TAUB','SAL','TEMP','LIGHT','PAR','Vx','Vy','EXTC','WVHT','WVPER','WVDIR'};
long_names={'bottom stress', 'salinity','temperature',...
    'light','Photosynthetically active radiation','Vx','Vy','EXTC','WVHT','WVPER','WVDIR'};
units ={'N/m2','PSU','degree C','W/m2','W/m2','m/s','m/s','/m','N/m2','N/m2'};

loadnames2={'EXTCV','WVHT','WVPER','WVDIR'};

header='Date,EXTC,wave height,wave period,wave direction';
header2 ='Units:,/m,m,seconds,degress';

sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

for t=1:length(sitenames)
    
    disp(sitenames{t});
    
    data=output.(sitenames{t});
    tmp=data.WQ_DIAG_TOT_EXTC.profile;
    data.EXTCV=mean(tmp,1);
    
    fileID = fopen(['site_export_data_',sitenames{t},'_v2.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data.WQ_DIAG_TOT_EXTC.date;
    
    for j=2:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames2)
            fprintf(fileID,',%6.4f',data.(loadnames2{v})(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
    
    
end