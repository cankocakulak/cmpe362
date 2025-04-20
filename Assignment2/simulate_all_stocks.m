clc; clear; close all;

data_folder = 'data/';
filenames = {'HDFCBANK.csv', 'ICICIBANK.csv', 'INDUSINDBK.csv', 'KOTAKBANK.csv'};
final_worths = zeros(1, length(filenames));

% Create a figure for net worth comparison
figure('Name', 'Net Worth Comparison', 'Position', [100, 100, 1200, 600]);

% Store daily values for all stocks
all_daily_values = cell(1, length(filenames));
all_dates = cell(1, length(filenames));

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

    % Store daily values and dates for plotting
    all_daily_values{i} = daily_values;
    all_dates{i} = dates_600;

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
    
    % Plot net worth over time
    subplot(2, 2, i);
    plot(dates_600, daily_values(:, 2), 'LineWidth', 1.5);
    title([stock_name ' Net Worth Over Time']);
    xlabel('Date');
    ylabel('Net Worth');
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
    xtickangle(45);
end

% Create a combined plot
figure('Name', 'Combined Net Worth Comparison', 'Position', [100, 100, 800, 500]);
hold on;
colors = {'b', 'r', 'g', 'm'};  % Different colors for each stock
for i = 1:length(filenames)
    stock_name = erase(filenames{i}, '.csv');
    plot(all_dates{i}, all_daily_values{i}(:, 2), colors{i}, 'LineWidth', 1.5, 'DisplayName', stock_name);
end
hold off;
title('Net Worth Comparison Across All Stocks');
xlabel('Date');
ylabel('Net Worth');
grid on;
legend('Location', 'best');
datetick('x', 'mmm-yy', 'keepticks');
xtickangle(45);

% Create plots directory if it doesn't exist
if ~exist('plots', 'dir')
    mkdir('plots');
end

% After the first figure (with 4 subplots)
figure(1);  % Make sure we're working with the subplot figure
saveas(gcf, fullfile('plots', 'individual_stocks_comparison.png'));

% After the combined plot
figure(2);  % The combined plot figure
saveas(gcf, fullfile('plots', 'combined_net_worth_comparison.png'));

% We can also save individual plots for each stock
for i = 1:length(filenames)
    figure('Position', [100, 100, 800, 500]);
    stock_name = erase(filenames{i}, '.csv');
    plot(all_dates{i}, all_daily_values{i}(:, 2), colors{i}, 'LineWidth', 1.5);
    title([stock_name ' Net Worth Over Time']);
    xlabel('Date');
    ylabel('Net Worth');
    grid on;
    datetick('x', 'mmm-yy', 'keepticks');
    xtickangle(45);
    saveas(gcf, fullfile('plots', [stock_name '_net_worth.png']));
    close;  % Close this figure to free up memory
end
