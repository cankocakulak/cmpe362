function [final_net_worth, log_lines, daily_values] = run_trading_strategy(vwap, dates, stock_name)
% Simulates trading using SMA, EMA, and RSI
% Tracks net worth, cash, shares per day

    % Initialize trading account
    initial_cash = 10000;
    cash = initial_cash;
    shares = 0;

    N = length(vwap);
    
    % Technical Indicators Setup
    % 1. Multiple timeframe SMA analysis for trend confirmation
    sma_short = compute_sma(vwap, 10);  % Fast-moving average for quick signals
    sma = compute_sma(vwap, 20);        % Primary trend indicator
    sma_long = compute_sma(vwap, 50);   % Slow-moving average for major trend confirmation
    
    % 2. EMA for trend detection (more weight to recent prices)
    ema = compute_ema(vwap, 20);        % More responsive to recent price changes
    
    % 3. RSI for overbought/oversold conditions
    rsi = compute_rsi(vwap, 14);        % Standard 14-day period for RSI
    
    % 4. Price momentum (5-day rate of change)
    % Measures the speed of price movement
    momentum = (vwap - circshift(vwap, 5)) ./ circshift(vwap, 5);
    
    % Arrays for tracking trading history
    log_lines = {};                     % Store trade logs
    daily_values = zeros(N, 4);         % Track daily: Day | Net Worth | Cash | Shares

    for t = 2:N
        % Calculate trend characteristics
        trend_strength = (ema(t) - sma(t)) / sma(t);  % Measure trend strength as % difference
        short_term_trend = sma_short(t) > sma(t);     % Short-term trend is up
        long_term_trend = sma(t) > sma_long(t);       % Long-term trend is up
        
        % BUY STRATEGY
        % Multiple confirmation approach requiring:
        % 1. EMA crosses above SMA (trend reversal signal)
        % 2. RSI below 70 (not overbought)
        % 3. Short and long-term trends aligned
        % 4. Positive momentum
        if (ema(t) > sma(t)) && (ema(t-1) <= sma(t-1)) && ... % EMA crossover
           rsi(t) < 70 && ...                                   % Not overbought
           short_term_trend && long_term_trend && ...          % Trend alignment
           momentum(t) > 0                                     % Positive momentum
            
            % Dynamic position sizing based on trend strength
            % Stronger trends -> larger positions (max 30% of cash)
            % Weaker trends -> smaller positions (min 10% of cash)
            risk_factor = min(0.3, max(0.1, abs(trend_strength)));
            invest = risk_factor * cash;
            
            % Execute buy order
            num_shares = invest / vwap(t);
            shares = shares + num_shares;
            cash = cash - invest;
            log_lines{end+1} = sprintf('Day %d: BUY %.2f currency of %s', ...
                t, invest, stock_name);
        end
        
        % SELL STRATEGY
        if shares > 0  % Only check sell conditions if we hold shares
            % Two types of sell signals:
            % 1. Trend reversal (EMA crosses below SMA)
            % 2. Overbought condition with momentum reversal
            trend_reversal = (ema(t) < sma(t)) && (ema(t-1) >= sma(t-1));
            overbought = rsi(t) > 70;
            momentum_reversal = momentum(t) < 0;
            
            if trend_reversal || (overbought && momentum_reversal)
                % Exit entire position
                revenue = shares * vwap(t);
                cash = cash + revenue;
                log_lines{end+1} = sprintf('Day %d: SELL %.2f currency of %s', ...
                    t, revenue, stock_name);
                shares = 0;
            end
        end
        
        % Daily portfolio tracking
        net_worth = cash + shares * vwap(t);
        daily_values(t, :) = [t, net_worth, cash, shares];
    end

    final_net_worth = daily_values(end, 2);  % Final portfolio value
end
