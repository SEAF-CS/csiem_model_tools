% export to CSV files

load extracted_for_Jeff_Depth.mat;

loadnames={'D'};
short_names={'depth'};
long_names={'depth'};
units ={'m'};

header='Date,Depth';
header2 ='Units:,m';

sitenames={'PB','SBA','SBB','PBA','PBB'};

for t=1:length(sitenames)
    
    disp(sitenames{t});
    
    data=output.(sitenames{t});
            
    fileID = fopen(['Export_Depth_',sitenames{t},'.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=output.PB.D.Date/24+datenum(1990,1,1);
    
    for j=2:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames)
            fprintf(fileID,',%6.4f',data.(loadnames{v}).Data(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
    
    
end