% read_and_plot_vwap.m
% Reads VWAP from all stock files and plots them

clc; clear; close all;

% Folder and filenames
data_folder = 'data/';
filenames = {'HDFCBANK.csv', 'ICICIBANK.csv', 'INDUSINDBK.csv', 'KOTAKBANK.csv'};

% Loop over each file
for i = 1:length(filenames)
    filepath = fullfile(data_folder, filenames{i});

    % Use import options for proper data types
    opts = detectImportOptions(filepath, 'VariableNamingRule', 'preserve');
    opts = setvartype(opts, 'Date', 'datetime');

    % Read table
    T = readtable(filepath, opts);

    % Extract Date and VWAP columns
    dates = T.Date;
    vwap = T.VWAP;

    % Clean NaNs
    validIdx = ~isnan(vwap);
    dates = dates(validIdx);
    vwap = vwap(validIdx);

    % Plot
    figure;
    plot(dates, vwap, 'b');
    xlabel('Date');
    ylabel('VWAP');
    title(['Raw VWAP - ', filenames{i}], 'Interpreter', 'none');
    grid on;
end
