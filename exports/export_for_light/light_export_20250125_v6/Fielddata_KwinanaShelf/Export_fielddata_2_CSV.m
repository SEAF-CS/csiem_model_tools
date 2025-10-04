% export to CSV files
clear; close all;
load('E:\CS_export\export_for_light\light_export_20250125\Fielddata_KwinanaShelf\light_spetrum_KwinanaShelf_uW.mat');

loadnames={'Data','Depth'};
units ={'uW/m2/nm','m'};

header='Date';
header2 ='Unit';
for i=1:length(loadnames)
    header=[header,',',loadnames{i}];
    header2=[header2,',',units{i}];
end

%%

for nn=1:length(wavelength)

    data=spectrum.(['WL_',num2str(wavelength(nn)),'_uW']);
    fileID = fopen(['data_spectra_',num2str(wavelength(nn)),'nm.csv'],'w');
    fprintf(fileID,'%s\n',header);
    fprintf(fileID,'%s\n',header2);
    
    timesteps=data.Date;
 
    for j=1:length(timesteps)
        fprintf(fileID,'%s',datestr(timesteps(j),'yyyy-mm-dd HH:MM:SS'));
        
        for v=1:length(loadnames)
            fprintf(fileID,',%6.4f',data.(loadnames{v})(j));
        end
    fprintf(fileID,'%s\n','');
    
    end
%fprintf(fileID,'%6s %12s\n','x','exp(x)');
%fprintf(fileID,'%6.2f %12.8f\n',);
fclose(fileID);

end
