function [final_net_worth, log_lines, daily_values] = run_trading_strategy(vwap, dates, stock_name)
% Simulates trading using SMA, EMA, and RSI
% Tracks net worth, cash, shares per day

    initial_cash = 10000;
    cash = initial_cash;
    shares = 0;

    N = length(vwap);
    sma = movmean(vwap, 20);
    alpha = 2 / (20 + 1);
    ema = zeros(size(vwap));
    ema(1) = vwap(1);
    for k = 2:N
        ema(k) = alpha * vwap(k) + (1 - alpha) * ema(k-1);
    end
    rsi = compute_rsi(vwap, 14);

    log_lines = {};
    daily_values = zeros(N, 4);  % Day | Net Worth | Cash | Shares

    for t = 2:N
        % Buy rule
        if (ema(t) > sma(t)) && (ema(t-1) <= sma(t-1)) && rsi(t) < 70
            invest = 0.2 * cash;
            num_shares = invest / vwap(t);
            shares = shares + num_shares;
            cash = cash - invest;
            log_lines{end+1} = sprintf('Day %d: BUY %.2f currency of %s', t, invest, stock_name);
        end

        % Sell rule
        if shares > 0 && (((ema(t) < sma(t)) && (ema(t-1) >= sma(t-1))) || rsi(t) > 70)
            revenue = shares * vwap(t);
            cash = cash + revenue;
            log_lines{end+1} = sprintf('Day %d: SELL %.2f currency of %s', t, revenue, stock_name);
            shares = 0;
        end

        % Track daily status
        net_worth = cash + shares * vwap(t);
        daily_values(t, :) = [t, net_worth, cash, shares];
    end

    final_net_worth = daily_values(end, 2);  % Last day's net worth
end
