clear; close all;

%% Define folders
inputFolder = '.\bc_files';
outputFolder = '.\bc_files_extended';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% Define target monthly date range
startDate = datetime(1980,1,1);
endDate = datetime(2024,4,1);
targetDates = (startDate : calmonths(1) : endDate)';

%% Get list of input files
fileList = dir(fullfile(inputFolder, '*.csv'));

for k = 1:length(fileList)
    % Load original file
    filename = fullfile(inputFolder, fileList(k).name);
    data = readtable(filename);

    % Convert Date column
    data.Date = datetime(data.Date, 'InputFormat', 'dd/mm/yyyy HH:MM:SS');
    data.Date = dateshift(data.Date, 'start', 'month');  % ensure start-of-month

    % Extract data from 2021 to 2022
    mask_ref = (data.Date >= datetime(2021,1,1)) & (data.Date <= datetime(2022,12,1));
    ref_data = data(mask_ref, :);

    if height(ref_data) ~= 24
        error('Expected exactly 24 months of reference data (2021–2022). Check file: %s', filename);
    end

    % Create repeated data to cover full range
    nTarget = length(targetDates);
    nRepeats = ceil(nTarget / height(ref_data));

    repeated_data = repmat(ref_data, nRepeats, 1);
    repeated_data = repeated_data(1:nTarget, :);
    repeated_data.Date = targetDates;  % assign new dates

    % Replace with original data where dates match exactly
    for i = 1:height(data)
        idx = find(repeated_data.Date == data.Date(i));
        if ~isempty(idx)
            repeated_data(idx, :) = data(i, :);  % overwrite with true value
        end
    end

    % Extract zone number from filename
    [~, baseName, ~] = fileparts(fileList(k).name);
    tokens = regexp(baseName, 'SGD_(\d+)', 'tokens');
    if ~isempty(tokens)
        zoneNumber = tokens{1}{1};
    else
        zoneNumber = num2str(k);
    end

    % Construct new filename
    newFileName = sprintf('SGD_zone%s_%s_%s.csv', ...
        zoneNumber, ...
        datestr(startDate, 'yyyymmdd'), ...
        datestr(endDate, 'yyyymmdd'));

     % Forzar formato correcto de fecha como string
     repeated_data.Date.Format = 'dd/MM/yyyy HH:mm:ss';

     % Guardar archivo con formato requerido
     outFile = fullfile(outputFolder, newFileName);
     writetable(repeated_data, outFile);
    fprintf('✅ Guardado: %s\n', newFileName);
end



