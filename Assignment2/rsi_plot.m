clc; clear; close all;

data_folder = 'data/';
filenames = {'HDFCBANK.csv', 'ICICIBANK.csv', 'INDUSINDBK.csv', 'KOTAKBANK.csv'};

period = 14;  % RSI period

% Create plots directory if it doesn't exist
if ~exist('plots', 'dir')
    mkdir('plots');
end

for i = 1:length(filenames)
    filepath = fullfile(data_folder, filenames{i});
    
    opts = detectImportOptions(filepath, 'VariableNamingRule', 'preserve');
    opts = setvartype(opts, 'Date', 'datetime');
    T = readtable(filepath, opts);

    dates = T.Date;
    vwap = T.VWAP;
    validIdx = ~isnan(vwap);
    dates = dates(validIdx);
    vwap = vwap(validIdx);

    % Last 1000 days
    n = length(vwap);
    vwap_1000 = vwap(max(1,n-999):end);
    dates_1000 = dates(max(1,n-999):end);

    % Compute RSI
    rsi = compute_rsi(vwap_1000, period);

    % Plot VWAP and RSI
    figure('Position', [100, 100, 1000, 800]);

    subplot(2,1,1);
    plot(dates_1000, vwap_1000, 'b');
    title(['VWAP - ', filenames{i}], 'Interpreter', 'none');
    ylabel('VWAP');
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
    xtickangle(45);

    subplot(2,1,2);
    plot(dates_1000, rsi, 'm'); hold on;
    yline(70, '--r', 'Overbought');
    yline(30, '--g', 'Oversold');
    title('RSI (14-day)');
    xlabel('Date');
    ylabel('RSI');
    ylim([0 100]);
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
    xtickangle(45);
    
    % Save plot
    stock_name = erase(filenames{i}, '.csv');
    saveas(gcf, fullfile('plots', [stock_name '_rsi.png']));
    close;
end
