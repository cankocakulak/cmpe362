%% CMPE362 Assignment 3: Final Report Plots
% This script generates the final plots for your report, including:
% 1. A combined frequency response plot for FIR and optimal IIR filters
% 2. Pole-zero plots for each IIR filter
%
% Author: [Your Name]
% Date: [Current Date]

clear all; close all; clc;

% Optimal filter orders determined from analysis
n_butterworth = 13;
n_chebyshev = 14;
n_elliptic = 12;

% Note about actual filter order implementation
fprintf('Note on filter orders:\n');
fprintf('When using butter(), cheby1(), and ellip() with ''stop'' option, the resulting filter is of order 2n.\n');
fprintf('The following filter orders are what we provide to the functions, but the actual implemented filters are order 2n:\n');
fprintf('Butterworth: n = %d (actual order = %d)\n', n_butterworth, 2*n_butterworth);
fprintf('Chebyshev:   n = %d (actual order = %d)\n', n_chebyshev, 2*n_chebyshev);
fprintf('Elliptic:    n = %d (actual order = %d)\n', n_elliptic, 2*n_elliptic);

% Filter parameters - UPDATED based on spectrogram analysis
f1 = 4000; % Lower edge of noise band (Hz)
f2 = 5000; % Upper edge of noise band (Hz)
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz
Rp = 0.1; % Passband ripple (dB)
Rs = 40;  % Stopband attenuation (dB)

% Load the sample audio to get sample rate
[~, fs] = audioread(fullfile('..', 'sample.wav'));

% Normalized cutoff frequencies
Wn = [lower_cutoff upper_cutoff] / (fs/2);

% Filter design
% FIR filter
order_fir = 256;
b_fir = fir_bandstop_design(order_fir, f1, f2, fs);
a_fir = 1; % FIR filter has no feedback terms

% IIR filters
[b_butter, a_butter] = iir_filter_algorithms('butterworth', n_butterworth, Wn);
[b_cheby, a_cheby] = iir_filter_algorithms('cheby1', n_chebyshev, Wn, Rp);
[b_ellip, a_ellip] = iir_filter_algorithms('ellip', n_elliptic, Wn, Rp, Rs);

% ------------------------------------------------------------------------
% 1. Combined Frequency Response Plot (Using full frequency range)
% ------------------------------------------------------------------------

% Using the full frequency range plot approach from iir_filter_analysis.m
full_freq = 0:1:fs/2;
H_fir_full = freqz(b_fir, 1, full_freq, fs);
H_butter_full = freqz(b_butter, a_butter, full_freq, fs);
H_cheby_full = freqz(b_cheby, a_cheby, full_freq, fs);
H_ellip_full = freqz(b_ellip, a_ellip, full_freq, fs);

figure('Position', [100, 100, 800, 500]);
plot(full_freq, 20*log10(abs(H_fir_full)), 'b-', 'LineWidth', 1.5); hold on;
plot(full_freq, 20*log10(abs(H_butter_full)), 'r-', 'LineWidth', 1.5);
plot(full_freq, 20*log10(abs(H_cheby_full)), 'g-', 'LineWidth', 1.5);
plot(full_freq, 20*log10(abs(H_ellip_full)), 'm-', 'LineWidth', 1.5);

% Format the plot
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude of Frequency Response - Full Range');
legend('FIR (n=256)', ...
       ['Butterworth (n=' num2str(n_butterworth) ')'], ...
       ['Chebyshev (n=' num2str(n_chebyshev) ')'], ...
       ['Elliptic (n=' num2str(n_elliptic) ')'], 'Location', 'southeast');
grid on;
ylim([-100 5]);
xlim([2000 8000]);

% Save the full range plot
saveas(gcf, fullfile('..', 'results', 'final_frequency_response_full_unstable.png'));
saveas(gcf, fullfile('..', 'results', 'final_frequency_response_full_unstable.fig'));

% ------------------------------------------------------------------------
% 3. Detailed Stopband View
% ------------------------------------------------------------------------
figure('Position', [100, 100, 800, 500]);
plot(full_freq, 20*log10(abs(H_fir_full)), 'b-', 'LineWidth', 1.5); hold on;
plot(full_freq, 20*log10(abs(H_butter_full)), 'r-', 'LineWidth', 1.5);
plot(full_freq, 20*log10(abs(H_cheby_full)), 'g-', 'LineWidth', 1.5);
plot(full_freq, 20*log10(abs(H_ellip_full)), 'm-', 'LineWidth', 1.5);

% Add vertical lines to mark the noise band
xline(f1, 'k--', 'Label', 'Noise Band Start', 'LineWidth', 1.2);
xline(f2, 'k--', 'Label', 'Noise Band End', 'LineWidth', 1.2);

% Find minimum attenuation in the stopband for each filter
in_band = (full_freq >= f1 & full_freq <= f2);
[min_fir_val, min_fir_idx] = min(20*log10(abs(H_fir_full(in_band))));
[min_butter_val, min_butter_idx] = min(20*log10(abs(H_butter_full(in_band))));
[min_cheby_val, min_cheby_idx] = min(20*log10(abs(H_cheby_full(in_band))));
[min_ellip_val, min_ellip_idx] = min(20*log10(abs(H_ellip_full(in_band))));

indices_in_range = find(in_band);
min_fir_idx = indices_in_range(min_fir_idx);
min_butter_idx = indices_in_range(min_butter_idx);
min_cheby_idx = indices_in_range(min_cheby_idx);
min_ellip_idx = indices_in_range(min_ellip_idx);

plot(full_freq(min_fir_idx), min_fir_val, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
text(full_freq(min_fir_idx)+50, min_fir_val, sprintf('%.1f dB', min_fir_val), 'Color', 'b');

plot(full_freq(min_butter_idx), min_butter_val, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(full_freq(min_butter_idx)+50, min_butter_val, sprintf('%.1f dB', min_butter_val), 'Color', 'r');

plot(full_freq(min_cheby_idx), min_cheby_val, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
text(full_freq(min_cheby_idx)+50, min_cheby_val, sprintf('%.1f dB', min_cheby_val), 'Color', 'g');

plot(full_freq(min_ellip_idx), min_ellip_val, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
text(full_freq(min_ellip_idx)+50, min_ellip_val, sprintf('%.1f dB', min_ellip_val), 'Color', 'm');

xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Stopband Detail View with Minimum Attenuation Points');
legend('FIR (n=256)', ...
       ['Butterworth (n=' num2str(n_butterworth) ')'], ...
       ['Chebyshev (n=' num2str(n_chebyshev) ')'], ...
       ['Elliptic (n=' num2str(n_elliptic) ')'], 'Location', 'southeast');
grid on;
xlim([f1-100 f2+100]);
ylim([-80 -20]);

saveas(gcf, fullfile('..', 'results', 'stopband_detail_view_unstable.png'));
saveas(gcf, fullfile('..', 'results', 'stopband_detail_view_unstable.fig'));

% ------------------------------------------------------------------------
% 4. Pole-Zero Plots
% ------------------------------------------------------------------------
figure('Position', [100, 100, 900, 300]);

% Butterworth pole-zero plot
subplot(1,3,1);
[z_butter, p_butter, ~] = tf2zpk(b_butter, a_butter);
zplane(z_butter, p_butter);
title(['Butterworth (n=' num2str(n_butterworth) ')']);
axis([-1.1 1.1 -1.1 1.1]);
grid on;

% Chebyshev pole-zero plot
subplot(1,3,2);
[z_cheby, p_cheby, ~] = tf2zpk(b_cheby, a_cheby);
zplane(z_cheby, p_cheby);
title(['Chebyshev (n=' num2str(n_chebyshev) ')']);
axis([-1.1 1.1 -1.1 1.1]);
grid on;

% Elliptic pole-zero plot
subplot(1,3,3);
[z_ellip, p_ellip, ~] = tf2zpk(b_ellip, a_ellip);
zplane(z_ellip, p_ellip);
title(['Elliptic (n=' num2str(n_elliptic) ')']);
axis([-1.1 1.1 -1.1 1.1]);
grid on;

sgtitle('Zero-Pole Plots for IIR Filters');

saveas(gcf, fullfile('..', 'results', 'pole_zero_plots_unstable.png'));
saveas(gcf, fullfile('..', 'results', 'pole_zero_plots_unstable.fig'));

% Export individual pole-zero plots for each IIR filter
figure;
zplane(z_butter, p_butter);
title(['Butterworth (n=' num2str(n_butterworth) ')']);
axis([-1.1 1.1 -1.1 1.1]);
grid on;
saveas(gcf, fullfile('..', 'results', sprintf('pz_butterworth_n%d_unstable.png', n_butterworth)));

figure;
zplane(z_cheby, p_cheby);
title(['Chebyshev (n=' num2str(n_chebyshev) ')']);
axis([-1.1 1.1 -1.1 1.1]);
grid on;
saveas(gcf, fullfile('..', 'results', sprintf('pz_chebyshev_n%d_unstable.png', n_chebyshev)));

figure;
zplane(z_ellip, p_ellip);
title(['Elliptic (n=' num2str(n_elliptic) ')']);
axis([-1.1 1.1 -1.1 1.1]);
grid on;
saveas(gcf, fullfile('..', 'results', sprintf('pz_elliptic_n%d_unstable.png', n_elliptic)));
