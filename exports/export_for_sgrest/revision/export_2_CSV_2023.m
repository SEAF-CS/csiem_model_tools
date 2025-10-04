% export to CSV files
clear; close all;

sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

loadnames={'SAL','TEMP','VT','TAUB','PAR','PARperc','EXTC','WVHT','WVDIR','WVPER'};
short_names={'SAL','TEMP','VT','TAUB','PAR','PARperc','EXTC','WVHT','WVDIR','WVPER'};
long_names={'salinity','temperature','current velocity','bottom stress', ...
    'PAR','PAR fraction','extinction coefficient','significant wave height','wave direction','wave period'};
units ={'PSU','degree C','m/s','N/m2','W/m2','%','/m','m','degrees','s'};

for t=1:length(sitenames)
    
    disp(sitenames{t});
    load(['extracted_2023_combined_step2_',sitenames{t},'_extc_scale.mat']);
    data2csv.LIGHTperc=data2csv.LIGHTperc*100;
    data2csv.PARperc=data2csv.PARperc*100;

header='Date,';
header2 ='Units:,';

for i=1:length(loadnames)
    header=[header,long_names{i},','];
    header2=[header2,units{i},','];
end

    fileID = fopen(['site_export_data_',sitenames{t},'.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data2csv.Date;
    t0=datenum(2023,1,1);

    ind1=find(abs(timesteps-t0)==min(abs(timesteps-t0)));
    
    for j=ind1:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames)
            fprintf(fileID,',%6.4f',data2csv.(loadnames{v})(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);
    
    
end