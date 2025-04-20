function sma = compute_sma(signal, window_size)
% compute_sma: Simple Moving Average using movmean
% Inputs:
%   signal - input time series (e.g., VWAP)
%   window_size - number of samples to average over
% Output:
%   sma - filtered signal

    sma = movmean(signal, window_size);
end
