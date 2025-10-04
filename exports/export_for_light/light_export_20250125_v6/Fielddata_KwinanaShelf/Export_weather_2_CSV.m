% export to CSV files
clear; close all;
load extracted_2023_weather_v6.mat;

loadnames={'PSFC','SWDOWN','GLW','T2','U10','V10','RAINV','REL_HUM'};
short_names={'pressure','SW_radiation','LW_ratidation','Air_temperature','WINDU','WINDV','Rain',...
    'Relative_humidity'};
units ={'Pa','W/m2','W/m2','degrees','m/s','m/s','m/day',...
    'percentage'};

header='Date';
header2 ='Unit';
for i=1:length(loadnames)
    header=[header,',',short_names{i}];
    header2=[header2,',',units{i}];
end

%%

    fileID = fopen('weather_data.csv','w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=CSweather.Time;
 
    for j=1:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j)+8/24,'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames)
            fprintf(fileID,',%6.4f',CSweather.(short_names{v})(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
