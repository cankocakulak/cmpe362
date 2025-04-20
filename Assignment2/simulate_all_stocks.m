clc; clear; close all;

data_folder = 'data/';
filenames = {'HDFCBANK.csv', 'ICICIBANK.csv', 'INDUSINDBK.csv', 'KOTAKBANK.csv'};
final_worths = zeros(1, length(filenames));

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

    % Take last 600 days
    n = length(vwap);
    vwap_600 = vwap(max(1,n-599):end);
    dates_600 = dates(max(1,n-599):end);

    % Run strategy
    stock_name = erase(filenames{i}, '.csv');
    [worth, log_lines, daily_values] = run_trading_strategy(vwap_600, dates_600, stock_name);

    % Save trade log
    if ~exist('logs', 'dir'); mkdir('logs'); end
    log_filename = fullfile('logs', [stock_name '_log.txt']);
    fid = fopen(log_filename, 'w');
    for j = 1:length(log_lines)
        fprintf(fid, '%s\n', log_lines{j});
    end
    fclose(fid);

    % Save money tracking CSV
    money_filename = fullfile('logs', ['money_' stock_name '.csv']);
    money_data = array2table(daily_values, ...
        'VariableNames', {'Day', 'NetWorth', 'Cash', 'Shares'});
    money_data.Date = dates_600;
    money_data = movevars(money_data, 'Date', 'Before', 'Day');
    writetable(money_data, money_filename);

    % Store result
    final_worths(i) = worth;
    fprintf('%s final net worth: %.2f\n', stock_name, worth);
end
