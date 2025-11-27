clear; close all;

%% Load groundwater data
nitro_data = readtable('.\comp_datasets\GW_processdata.csv');  % Uncomment and adjust if reading from file

% Define the variable names
var_names = {'MH_zone','Date','Flow','SAL','TEMP','WQ_NCS_SS1','WQ_OXY_OXY',...
    'WQ_NIT_AMM','WQ_NIT_NIT','WQ_PHS_FRP','WQ_PHS_FRP_ADS','WQ_OGM_DOC',...
    'WQ_OGM_POC','WQ_OGM_DON','WQ_OGM_PON','WQ_OGM_DOP','ones','zeros'};

% Define corresponding variable types (all numeric except 'Date')
var_types = [{'datetime'}, repmat({'double'}, 1, length(var_names)-1)];

% Create the empty table
new_table = table('Size', [height(nitro_data), length(var_names)], ...
                    'VariableTypes', var_types, ...
                    'VariableNames', var_names);

%% Load and Process Other Data

%%% Load supporting porewater workbook
file = '.\raw_datasets\WWMSP3.3_Porewater\Copy of WWMSP3.3_CombinedSampleDetails_BeachOffshorePorewater_PRELIMINARY_072024.xlsx';

% Read worksheets
insitu = readtable(file, 'Sheet', 'InSituParameters');
MAFRL = readtable(file, 'Sheet', 'MAFRL_samples');
CCWA  = readtable(file, 'Sheet', 'CCWA_samples');

% Process in-situ measurements
insitu.Year = year(insitu.Date);
insitu_filter = groupsummary(insitu, {'SiteID', 'Year'}, 'mean', {'pH', 'EC', 'temp'});
%insitu_filter = rmmissing(insitu_filter(:, [1, 3:end]));  % Removes rows with NaN and the second column

% Process MAFRL and CCWA samples
MAFRL.Year = year(MAFRL.Date);
CCWA.Year  = year(CCWA.Date);

vars = {'P_totsol', 'DOC', 'P_SR'};
MAFRL_filter = groupsummary(MAFRL, {'SiteID', 'Year'}, 'mean', vars);
CCWA_filter  = groupsummary(CCWA, {'SiteID', 'Year'}, 'mean', vars);

% Merge and clean records
join_MC = [MAFRL_filter; CCWA_filter];

% Join with in-situ summary
MC = outerjoin(join_MC, insitu_filter,'Keys', {'SiteID', 'Year'},'MergeKeys', true);

MC(:, {'GroupCount_join_MC', 'GroupCount_insitu_filter'}) = [];

% Determine DOP
MC.DOP=MC.mean_P_totsol-MC.mean_P_SR;
MC.DOP(MC.DOP < 0) = 0;
cols ={'mean_P_totsol','mean_DOC','mean_P_SR','mean_pH','mean_EC','mean_temp','DOP'};
MC = MC(~any(ismissing(MC(:, cols)), 2), :);

%% Filter with MH zones

filter=readtable('.\comp_datasets\samples_guide.csv');

MC_filtered = innerjoin(MC, filter, 'Keys', 'SiteID');

%% Creating a constants table

variables = {'mean_P_totsol','mean_DOC','mean_P_SR','mean_EC', 'mean_temp','DOP'};
constants  = groupsummary(MC_filtered, {'MH_zone'}, 'mean', variables);


% Define the mappings from missing zones to the source zones
zone_map = [3 12; 5 4; 6 7; 8 9; 13 14];

for i = 1:size(zone_map, 1)
    source_zone = zone_map(i, 2);
    target_zone = zone_map(i, 1);
    
    % Extract the source row
    source_row = constants(constants.MH_zone == source_zone, :);
    
    % Change MH_zone to the target zone
    source_row.MH_zone = target_zone;
    
    % Append to constants
    constants = [constants; source_row];
end

% Optional: sort the table by MH_zone
constants = sortrows(constants, 'MH_zone');

constants(constants.MH_zone == 0, :) = [];

%% Adding data to new table

% Convert the column of strings to datetime objects
dt = datetime(nitro_data.date, 'InputFormat', 'dd-MMM-yyyy');
% Change the format directly and assign it to the new table column
new_table.Date = datetime(dt, 'Format', 'dd/MM/yyyy');

%% Other data
new_table.Flow=nitro_data.total_flux_m3_month / 2629744; %Flow
new_table.MH_zone=nitro_data.MH_zone_no;%MH zone
%adding fluxes
new_table.total_DON_tonne=nitro_data.total_DON_tonne;
new_table.total_NH4_tonne=nitro_data.total_NH4_tonne;
new_table.total_NOx_tonne=nitro_data.total_NOx_tonne;
%% adding constants to the new table
for i = 1:height(constants)
    zone = constants.MH_zone(i);

    % Logical index of matching rows in new_table
    idx = new_table.MH_zone == zone;

    % Assign values directly
    new_table.WQ_OGM_DOP(idx)     = constants.mean_DOP(i);          % DOP
    new_table.WQ_OGM_DOC(idx)     = constants.mean_mean_DOC(i);     % DOC
    new_table.WQ_PHS_FRP(idx)     = constants.mean_mean_P_totsol(i);% Total P
    new_table.SAL(idx)            = constants.mean_mean_EC(i)*35/53;      % EC to SAL 
    new_table.TEMP(idx)           = constants.mean_mean_temp(i);    % Temperature
end



%% Grouping variables

%  Define variables for aggregation
allVars = new_table.Properties.VariableNames;

% Separate variables
vars_flow = {'Flow','total_DON_tonne','total_NH4_tonne','total_NOx_tonne'};
groupingVars = {'MH_zone', 'Date'};
vars_others = setdiff(allVars, [groupingVars, vars_flow]);

% Step 3: Sum for 'Flow'
T_sumFlow = varfun(@sum, new_table, ...
    'InputVariables', vars_flow, ...
    'GroupingVariables', groupingVars);

% Step 4: Mean for all other numeric variables 
T_meanOthers = varfun(@mean, new_table, ...
    'InputVariables', vars_others, ...
    'GroupingVariables', groupingVars);

% Step 5: Join the results
T_grouped = join(T_sumFlow, T_meanOthers, ...
    'Keys', groupingVars);

% === Rename variables: strip 'sum_' and 'mean_' prefixes ===
T_grouped.Properties.VariableNames = ...
    regexprep(T_grouped.Properties.VariableNames, '^(sum_|mean_)', '');
% Remove helper columns generated by the joins
T_grouped.GroupCount_T_sumFlow = [];
T_grouped.GroupCount_T_meanOthers = [];

% Ensure AED boundary condition columns exist
T_grouped.ones = ones(height(T_grouped), 1);
if ~ismember('zeros', T_grouped.Properties.VariableNames)
    T_grouped.zeros = zeros(height(T_grouped), 1);
end
%% Step 5: Compute flow-weighted concentrations

T_grouped.total_flux_L_month = T_grouped.Flow * 2629744*1000;  % Convert from m3/s to m3/month
idx_zero_flux = (T_grouped.total_flux_L_month == 0) | isnan(T_grouped.total_flux_L_month);

T_grouped.DON_mgL = zeros(height(T_grouped),1);
T_grouped.NH4_mgL = zeros(height(T_grouped),1);
T_grouped.NOx_mgL = zeros(height(T_grouped),1);

valid_idx = ~idx_zero_flux;

T_grouped.DON_mgL(valid_idx) = (T_grouped.total_DON_tonne(valid_idx) * 1e9) ./ T_grouped.total_flux_L_month(valid_idx);
T_grouped.NH4_mgL(valid_idx) = (T_grouped.total_NH4_tonne(valid_idx) * 1e9) ./ T_grouped.total_flux_L_month(valid_idx);
T_grouped.NOx_mgL(valid_idx) = (T_grouped.total_NOx_tonne(valid_idx) * 1e9) ./ T_grouped.total_flux_L_month(valid_idx);

conversion_factor = 1000 / 14;  % mg/L -> mmol/m^3
T_grouped.WQ_OGM_DON = T_grouped.DON_mgL * conversion_factor;
T_grouped.WQ_NIT_AMM = T_grouped.NH4_mgL * conversion_factor;
T_grouped.WQ_NIT_NIT = T_grouped.NOx_mgL * conversion_factor;

% Compute nitrogen speciation fractions for output
total_n_mmol = T_grouped.WQ_OGM_DON + T_grouped.WQ_NIT_AMM + T_grouped.WQ_NIT_NIT;
valid_n = (total_n_mmol > 0) & ~isnan(total_n_mmol);

T_grouped.pDON = zeros(height(T_grouped), 1);
T_grouped.pNH3 = zeros(height(T_grouped), 1);
T_grouped.pNOx = zeros(height(T_grouped), 1);

T_grouped.pDON(valid_n) = T_grouped.WQ_OGM_DON(valid_n) ./ total_n_mmol(valid_n);
T_grouped.pNH3(valid_n) = T_grouped.WQ_NIT_AMM(valid_n) ./ total_n_mmol(valid_n);
T_grouped.pNOx(valid_n) = T_grouped.WQ_NIT_NIT(valid_n) ./ total_n_mmol(valid_n);


%% Adding OXY_OXY
min_O2 = 196; % mmol/m3
max_O2 = 220; % mmol/m3

% Initialize the column if it does not exist
if ~ismember('WQ_OXY_OXY', T_grouped.Properties.VariableNames)
    T_grouped.WQ_OXY_OXY = nan(height(new_table),1);
end

% Indices with missing values (NaN) to replace with random samples
idx_missing = isnan(T_grouped.WQ_OXY_OXY)|(T_grouped.WQ_OXY_OXY == 0);

% Assign random oxygen values within the allowed range
T_grouped.WQ_OXY_OXY(idx_missing) = (max_O2 - min_O2) .* rand(sum(idx_missing),1) + min_O2;

 %% Save the combined data to a CSV file

T_grouped = removevars(T_grouped, {'DON_mgL','NH4_mgL','NOx_mgL','total_DON_tonne','total_NH4_tonne','total_NOx_tonne','total_flux_L_month'});

% Reorder columns explicitly before renaming to avoid drift
vars_for_output = {'MH_zone','Date','Flow','SAL','TEMP','WQ_NCS_SS1', ...
    'WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT','WQ_PHS_FRP','WQ_PHS_FRP_ADS', ...
    'WQ_OGM_DOC','WQ_OGM_POC','WQ_OGM_DON','WQ_OGM_PON','WQ_OGM_DOP', ...
    'pNH3','pNOx','pDON','ones','zeros'};
T_grouped = T_grouped(:, vars_for_output);

% Rename groundwater chemistry variables with an explicit mapping
T_grouped = renamevars(T_grouped, ...
    {'WQ_NCS_SS1','WQ_OXY_OXY','WQ_NIT_AMM','WQ_NIT_NIT', ...
     'WQ_PHS_FRP','WQ_PHS_FRP_ADS','WQ_OGM_DOC','WQ_OGM_POC', ...
     'WQ_OGM_DON','WQ_OGM_PON','WQ_OGM_DOP'}, ...
    {'SS1','OXY','AMM','NIT','FRP','FRP_ADS','DOC','POC','DON','PON','DOP'});
 writetable(T_grouped, '.\comp_datasets\BC_GW_masterfile.csv');


