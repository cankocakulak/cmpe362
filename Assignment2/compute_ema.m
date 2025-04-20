function ema = compute_ema(signal, alpha)
% compute_ema: Exponential Moving Average using smoothing factor
% Inputs:
%   signal - input time series (e.g., VWAP)
%   alpha - smoothing factor (0 < alpha < 1)
% Output:
%   ema - filtered signal

    ema = zeros(size(signal));
    ema(1) = signal(1);  % Init with first value
    
    for k = 2:length(signal)
        ema(k) = alpha * signal(k) + (1 - alpha) * ema(k-1);
    end
end
