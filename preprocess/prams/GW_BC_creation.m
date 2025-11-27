clear; close all;

%% Read input file
file = '.\comp_datasets\BC_GW_masterfile.csv';
GW_master = readtable(file);

%% Ensure the Date column is datetime (adjust column name if needed)
GW_master.Date = datetime(GW_master.Date);

%% Create output folder
outputFolder = '.\bc_files';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% Convert MH_zone to string and get unique values
GW_master.MH_zone = string(GW_master.MH_zone);
zones = unique(GW_master.MH_zone);



%% Loop through each zone and create a separate file
for i = 1:length(zones)
    currentZone = zones(i);

    % Clean zone name for safe filenames
    safeZoneName = regexprep(currentZone, '[^a-zA-Z0-9_-]', '_');

    % Subset the table
    zoneData = GW_master(GW_master.MH_zone == currentZone, :);

    % Remove MH_zone column
    zoneData.MH_zone = [];

    % Remove diagnostic columns not required by bc_files outputs
    dropCols = intersect({'pNH3','pNOx','pDON'}, zoneData.Properties.VariableNames);
    if ~isempty(dropCols)
        zoneData(:, dropCols) = [];
    end

    % Get date range
    startDate = datestr(min(zoneData.Date), 'yyyymmdd');
    endDate = datestr(max(zoneData.Date), 'yyyymmdd');

    % Convert the Date column to the desired string format
    zoneData.Date = datestr(zoneData.Date, 'dd/mm/yyyy');

    % Create filename with zone and date range
    filename = fullfile(outputFolder, sprintf('SGD_%s_%s_%s.csv', ...
        safeZoneName, startDate, endDate));

    % Write to CSV
    writetable(zoneData, filename);
end



