% export to CSV files

load extracted_for_Giulia.mat;


loadnames={'WQ_DIAG_NCS_D_TAUB','SAL','TEMP','WQ_DIAG_TOT_PAR','V_x','V_y'};
short_names={'TAUB','SAL','TEMP','PAR','Vx','Vy'};
long_names={'bottom stress', 'salinity','temperature',...
    'Photosynthetically active radiation','Vx','Vy'};
units ={'N/m2','PSU','degree C','W/m2','m/s','m/s'};

loadnames2={'Vt','WQ_DIAG_NCS_D_TAUB','SAL','TEMP','WQ_DIAG_TOT_PAR','PAR_frac'};

header='Date,Currnet Speed,Stress,salinity,Tempeature,PAR,PAR fraction';
header2 ='Units:,m/s,N/m2,PSU,degrees,W/m2,%';

sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

for t=1:length(sitenames)
    
    disp(sitenames{t});
    
    data=output.(sitenames{t});
    tmp=data.WQ_DIAG_TOT_PAR.bottom./data.WQ_DIAG_TOT_PAR.surface;
    tmp(tmp>1)=1;
    tmp(tmp<0)=0;
    
    data.PAR_frac.bottom=tmp;
    
    tmp1=data.V_x.bottom;
    tmp2=data.V_y.bottom;
    V_t=sqrt(tmp1.^2+tmp2.^2);
    data.Vt.bottom=V_t;
    
    fileID = fopen(['site_export_data_',sitenames{t},'.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data.SAL.date;
    
    for j=2:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames2)
            fprintf(fileID,',%6.4f',data.(loadnames2{v}).bottom(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
    
    
end