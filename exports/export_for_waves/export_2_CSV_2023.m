% export to CSV files
clear; close all;
load extracted_for_Jeff_AED_2023.mat;

loadnames={'WQ_DIAG_NCS_D_TAUB','V_x','V_y','SAL','TEMP','D'};
short_names={'TAUB','Vx','Vy','SAL','TEMP','D'};
long_names={'TAUB','Vx','Vy','SAL','TEMP','D'};
units ={'N/m2','m/s','m/s','PSU','degrees','D'};

loadnames2={'WQ_DIAG_NCS_D_TAUB','Vt','SAL','TEMP','D'};

header='Date,stress,current,salinity,Tempeature,Depth';
header2 ='Units:,N/m2,m/s,PSU,degrees,meters';

sitenames={'PB','SBA','SBB','PBA','PBB'};

for t=1:length(sitenames)
    
    disp(sitenames{t});
    
    data=output.(sitenames{t});
        
    tmp1=data.V_x.bottom;
    tmp2=data.V_y.bottom;
    V_t=sqrt(tmp1.^2+tmp2.^2);
    data.Vt.bottom=V_t;
    
    fileID = fopen(['Export_Tau_',sitenames{t},'_202211_202403.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data.SAL.date;
    
    for j=2:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames2)-1
            fprintf(fileID,',%6.4f',data.(loadnames2{v}).bottom(j));
        end
        fprintf(fileID,',%6.4f',data.D.Data(j));
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
    
    
end