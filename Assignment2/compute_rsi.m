function rsi = compute_rsi(signal, period)
% compute_rsi: Computes the Relative Strength Index (RSI)
% Inputs:
%   signal - input time series (e.g., VWAP)
%   period - window size (commonly 14)
% Output:
%   rsi - RSI values (NaNs where not computable)

    deltas = diff(signal);
    gain = max(deltas, 0);
    loss = -min(deltas, 0);

    % Pad the first value with NaN for alignment
    gain = [NaN; gain];
    loss = [NaN; loss];

    avg_gain = movmean(gain, period, 'omitnan');
    avg_loss = movmean(loss, period, 'omitnan');

    rs = avg_gain ./ avg_loss;
    rsi = 100 - (100 ./ (1 + rs));
end
