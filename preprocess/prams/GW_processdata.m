clear; close all;


%% Define folder path and list files
folder_path = '.\raw_datasets\Updated_CSIRO_results04042025';
addpath(folder_path);

% Select specific files
files = dir(fullfile(folder_path, 'westport__gw_and_totalN_totim*.xlsx'));

%% Define a lookup table for date conversion
date_lookup = {  
    7702, datetime(2021,1,31);
    7730, datetime(2021,2,28);
    7761, datetime(2021,3,31);
    7791, datetime(2021,4,30);
    7822, datetime(2021,5,31);
    7852, datetime(2021,6,30);
    7883, datetime(2021,7,31);
    7914, datetime(2021,8,31);
    7944, datetime(2021,9,30);
    7975, datetime(2021,10,31);
    8005, datetime(2021,11,30);
    8036, datetime(2021,12,31);
    8067, datetime(2022,1,31);
    8095, datetime(2022,2,28);
    8126, datetime(2022,3,31);
    8156, datetime(2022,4,30);
    8187, datetime(2022,5,31);
    8217, datetime(2022,6,30);
    8248, datetime(2022,7,31);
    8279, datetime(2022,8,31);
    8309, datetime(2022,9,30);
    8340, datetime(2022,10,31);
    8370, datetime(2022,11,30);
    8401, datetime(2022,12,31);
};

%% Initialize an empty table to store all extracted data
all_data = table();
join_data = table();

for i = 1:length(files)
    % Get the full path of the current file
    current_file = fullfile(folder_path, files(i).name);
    
    % Extract the numeric ID from the file name
    file_id = str2double(regexp(files(i).name, '\d+', 'match', 'once'));
    
    % Find the corresponding date from the lookup table
    match_idx = find([date_lookup{:, 1}] == file_id, 1);
    if isempty(match_idx)
        warning('No date match found for file: %s', files(i).name);
        continue;
    end
    date_match = date_lookup{match_idx, 2};
    
    % Read data from Sheet 2
    sheet2_data = readtable(current_file, 'Sheet', 2); 
    sheet2_data.Properties.VariableNames(1) = "Var1";
    sheet2_data.Properties.VariableNames(3) = "Var3";
    sheet2_data.Properties.VariableNames(5) = "Var5";
    sheet2_data.Properties.VariableNames(191) = "Var191";

    % Read data from Sheet 3 (only for Var6)
    sheet3_data = readtable(current_file, 'Sheet', 3);
    sheet3_data.Properties.VariableNames(4) = "Var4";

    % Extract variables from each sheet
    extracted_sheet2 = sheet2_data(:, {'Var1', 'Var3', 'Var5', 'Var191'});
    extracted_var4 = sheet3_data(3:end, {'Var4'});

    % Combine them horizontally (assuming they have the same number of rows and aligned correctly)
    data_extraction = [extracted_sheet2 extracted_var4];
    
    % Rename variables for clarity
    data_extraction = renamevars(data_extraction, ...
    {'Var1','Var3','Var5','Var4','Var191'}, ...
    {'zone','MH_zone_no','Location','flux_rate_m3_month','nit_load_tonne_month'});
    
    % Add the corresponding date
    data_extraction.date = repmat(date_match, height(data_extraction), 1); 
    % add all data to join
    if isempty(join_data)
    join_data = data_extraction;
    else
    join_data = [join_data; data_extraction];  % append new data
   end
end



%% Convert monthly nitrogen load to annual (tonne/year) by summing monthly values

% Convert the 'date' column to datetime format if not already
join_data.date = datetime(join_data.date);

% Extract year from date
join_data.year = year(join_data.date);


% Group data by year and location (e.g., offshore, coastline)

grouped_data = groupsummary(join_data, {'year', 'Location'}, 'sum', {'flux_rate_m3_month', 'nit_load_tonne_month'});

% Rename output columns for clarity
grouped_data.Properties.VariableNames{'sum_flux_rate_m3_month'} = 'total_flux_rate';
grouped_data.Properties.VariableNames{'sum_nit_load_tonne_month'} = 'total_nit_load';

% Convert flux from m³/month to m³/year
grouped_data.total_flux_rate = grouped_data.total_flux_rate/1000000;

% Display result
disp(grouped_data);

%% adding N speciation

N_spec = readtable('.\raw_datasets\N_speciation_for_ModelZones_Final.xlsx');
N_spec = renamevars(N_spec, 'Zone', 'zone');

% N species are mg/L


% Group data by year and location (e.g., offshore, coastline)

all_data = groupsummary(join_data, {'date', 'zone'}, 'sum', {'flux_rate_m3_month', 'nit_load_tonne_month'});


% Join flux data with N_spec table using 'zone'
join_with_spec = outerjoin(all_data, N_spec, 'Keys', 'zone', 'MergeKeys', true);


%% Clean data
clean_data = removevars(join_with_spec, {'MH_zone_no','GroupCount','PW_SiteID','DON','NH4','NOx','GW_TDN_est'});

% Modifing MH groups
MH_zones = N_spec (:, {'zone', 'MH_zone_no'});

% adding the total nitrogen speciecs
clean_data.DON_load_tonne = clean_data.sum_nit_load_tonne_month .* clean_data.pDON;
clean_data.NH4_load_tonne = clean_data.sum_nit_load_tonne_month .* clean_data.pNH3;
clean_data.NOx_load_tonne = clean_data.sum_nit_load_tonne_month .* clean_data.pNOx;


%% Final data

final_data = groupsummary(clean_data, {'zone', 'date'}, 'sum', {'sum_flux_rate_m3_month', 'DON_load_tonne', 'NH4_load_tonne', 'NOx_load_tonne'});

% Renombrar variables
final_data.Properties.VariableNames{'sum_sum_flux_rate_m3_month'} = 'total_flux_m3_month';
final_data.Properties.VariableNames{'sum_DON_load_tonne'} = 'total_DON_tonne';
final_data.Properties.VariableNames{'sum_NH4_load_tonne'} = 'total_NH4_tonne';
final_data.Properties.VariableNames{'sum_NOx_load_tonne'} = 'total_NOx_tonne';



final_data = outerjoin(final_data, MH_zones, 'Keys', 'zone', 'MergeKeys', true);

%% Save the combined data to a CSV file

outpath = './comp_datasets/GW_processdata.csv';

folder = fileparts(outpath);

if ~exist(folder, 'dir')
    mkdir(folder);
end

writetable(final_data, outpath);

disp('Data processing complete. Output saved as groundwateroutput.csv.');

