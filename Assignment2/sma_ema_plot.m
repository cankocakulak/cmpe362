clc; clear; close all;

% File setup
data_folder = 'data/';
filenames = {'HDFCBANK.csv', 'ICICIBANK.csv', 'INDUSINDBK.csv', 'KOTAKBANK.csv'};

% Parameters
sma_window = 20;
alpha = 0.1;

% Create plots directory if it doesn't exist
if ~exist('plots', 'dir')
    mkdir('plots');
end

for i = 1:length(filenames)
    filepath = fullfile(data_folder, filenames{i});
    
    % Import
    opts = detectImportOptions(filepath, 'VariableNamingRule', 'preserve');
    opts = setvartype(opts, 'Date', 'datetime');
    T = readtable(filepath, opts);

    % Extract + clean
    dates = T.Date;
    vwap = T.VWAP;
    validIdx = ~isnan(vwap);
    dates = dates(validIdx);
    vwap = vwap(validIdx);

    % Last 1000 days
    n = length(vwap);
    vwap_1000 = vwap(max(1,n-999):end);
    dates_1000 = dates(max(1,n-999):end);

    % Compute SMA & EMA
    sma = compute_sma(vwap_1000, sma_window);
    ema = compute_ema(vwap_1000, alpha);

    % Plot
    figure('Position', [100, 100, 1000, 600]);
    plot(dates_1000, vwap_1000, 'b'); hold on;
    plot(dates_1000, sma, 'r');
    plot(dates_1000, ema, 'g');
    legend('Original', 'SMA', 'EMA');
    title(['VWAP + SMA + EMA - ', filenames{i}], 'Interpreter', 'none');
    xlabel('Date'); ylabel('VWAP');
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
    xtickangle(45);
    
    % Save plot
    stock_name = erase(filenames{i}, '.csv');
    saveas(gcf, fullfile('plots', [stock_name '_sma_ema.png']));
    close;
end
