function b = fir_bandstop_design(order, f1, f2, fs)
% b = fir_bandstop_design(order, f1, f2, fs)
% Designs a bandstop FIR filter of given order for the band (f1, f2) Hz
% Uses (f1-500, f2+500) as cutoff frequencies and normalizes internally

% Compute stopband edges
lower_cutoff = f1 - 500;
upper_cutoff = f2 + 500;

% Normalize cutoff frequencies
Wn = [lower_cutoff upper_cutoff] / (fs/2);

% Design the filter
b = fir1(order, Wn, 'stop');
end 