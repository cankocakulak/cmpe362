%% CMPE362 Assignment 3: Final Report Plots
% This script generates the final plots for your report, including:
% 1. A combined frequency response plot for FIR and optimal IIR filters
% 2. Pole-zero plots for each IIR filter
%
% Author: [Your Name]
% Date: [Current Date]

clear all; close all; clc;

% Optimal filter orders determined from analysis
n_butterworth = 10;
n_chebyshev = 11;
n_elliptic = 8;

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
b_fir = fir1(order_fir, Wn, 'stop');
a_fir = 1; % FIR filter has no feedback terms

% IIR filters
[b_butter, a_butter] = butter(n_butterworth, Wn, 'stop');
[b_cheby, a_cheby] = cheby1(n_chebyshev, Rp, Wn, 'stop');
[b_ellip, a_ellip] = ellip(n_elliptic, Rp, Rs, Wn, 'stop');

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

% Save the full range plot
saveas(gcf, fullfile('..', 'results', 'final_frequency_response_full.png'));
saveas(gcf, fullfile('..', 'results', 'final_frequency_response_full.fig'));

% ------------------------------------------------------------------------
% 2. Zoomed Frequency Response Plot (Using the zoom approach from iir_filter_analysis.m)
% ------------------------------------------------------------------------

% Use a higher resolution and focused band
f_plot_zoom = linspace(2000, 7000, 2000);  % Focus on the 4-5 kHz noise band region
w_plot_zoom = 2*pi*f_plot_zoom/fs;

H_fir_zoom = freqz(b_fir, 1, w_plot_zoom, fs);
H_butter_zoom = freqz(b_butter, a_butter, w_plot_zoom, fs);
H_cheby_zoom = freqz(b_cheby, a_cheby, w_plot_zoom, fs);
H_ellip_zoom = freqz(b_ellip, a_ellip, w_plot_zoom, fs);

figure('Position', [100, 100, 800, 500]);
plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b-', 'LineWidth', 1.5); hold on;
plot(f_plot_zoom, 20*log10(abs(H_butter_zoom)), 'r-', 'LineWidth', 1.5);
plot(f_plot_zoom, 20*log10(abs(H_cheby_zoom)), 'g-', 'LineWidth', 1.5);
plot(f_plot_zoom, 20*log10(abs(H_ellip_zoom)), 'm-', 'LineWidth', 1.5);

% Add vertical lines to mark the stopband region and noise band
hold on;
xline(lower_cutoff, 'r--', 'LineWidth', 1.2, 'Lower Cutoff');
xline(upper_cutoff, 'r--', 'LineWidth', 1.2, 'Upper Cutoff');
xline(f1, 'k--', 'LineWidth', 1.2, 'Noise Band Start');
xline(f2, 'k--', 'LineWidth', 1.2, 'Noise Band End');
hold off;

% Format the plot
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude of Frequency Response (log scale)');
legend('FIR (n=256)', ...
       ['Butterworth (n=' num2str(n_butterworth) ')'], ...
       ['Chebyshev (n=' num2str(n_chebyshev) ')'], ...
       ['Elliptic (n=' num2str(n_elliptic) ')'], 'Location', 'southeast');
grid on;
xlim([2000 7000]);
ylim([-80 5]);

% Save the zoomed plot
saveas(gcf, fullfile('..', 'results', 'final_frequency_response.png'));
saveas(gcf, fullfile('..', 'results', 'final_frequency_response.fig'));

% ------------------------------------------------------------------------
% 3. Detailed Stopband View
% ------------------------------------------------------------------------
figure('Position', [100, 100, 800, 500]);
plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b-', 'LineWidth', 1.5); hold on;
plot(f_plot_zoom, 20*log10(abs(H_butter_zoom)), 'r-', 'LineWidth', 1.5);
plot(f_plot_zoom, 20*log10(abs(H_cheby_zoom)), 'g-', 'LineWidth', 1.5);
plot(f_plot_zoom, 20*log10(abs(H_ellip_zoom)), 'm-', 'LineWidth', 1.5);

% Add vertical lines to mark the noise band
hold on;
xline(f1, 'k--', 'LineWidth', 1.2);
xline(f2, 'k--', 'LineWidth', 1.2);
hold off;

% Find minimum attenuation in the stopband for each filter
[min_fir_val, min_fir_idx] = min(20*log10(abs(H_fir_zoom(f_plot_zoom >= f1 & f_plot_zoom <= f2))));
[min_butter_val, min_butter_idx] = min(20*log10(abs(H_butter_zoom(f_plot_zoom >= f1 & f_plot_zoom <= f2))));
[min_cheby_val, min_cheby_idx] = min(20*log10(abs(H_cheby_zoom(f_plot_zoom >= f1 & f_plot_zoom <= f2))));
[min_ellip_val, min_ellip_idx] = min(20*log10(abs(H_ellip_zoom(f_plot_zoom >= f1 & f_plot_zoom <= f2))));

% Convert indices back to the full range indices
indices_in_range = find(f_plot_zoom >= f1 & f_plot_zoom <= f2);
min_fir_idx = indices_in_range(min_fir_idx);
min_butter_idx = indices_in_range(min_butter_idx);
min_cheby_idx = indices_in_range(min_cheby_idx);
min_ellip_idx = indices_in_range(min_ellip_idx);

% Mark the minimum points
plot(f_plot_zoom(min_fir_idx), min_fir_val, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
text(f_plot_zoom(min_fir_idx)+50, min_fir_val, sprintf('%.1f dB', min_fir_val), 'Color', 'b');

plot(f_plot_zoom(min_butter_idx), min_butter_val, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(f_plot_zoom(min_butter_idx)+50, min_butter_val, sprintf('%.1f dB', min_butter_val), 'Color', 'r');

plot(f_plot_zoom(min_cheby_idx), min_cheby_val, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
text(f_plot_zoom(min_cheby_idx)+50, min_cheby_val, sprintf('%.1f dB', min_cheby_val), 'Color', 'g');

plot(f_plot_zoom(min_ellip_idx), min_ellip_val, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
text(f_plot_zoom(min_ellip_idx)+50, min_ellip_val, sprintf('%.1f dB', min_ellip_val), 'Color', 'm');

% Format the plot
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Stopband Detail View with Minimum Attenuation Points');
legend('FIR (n=256)', ...
       ['Butterworth (n=' num2str(n_butterworth) ')'], ...
       ['Chebyshev (n=' num2str(n_chebyshev) ')'], ...
       ['Elliptic (n=' num2str(n_elliptic) ')'], 'Location', 'southeast');
grid on;
xlim([f1-100 f2+100]);  % Tight focus on the noise band
ylim([-80 -20]);  % Focus on the attenuation levels

% Save the detail view plot
saveas(gcf, fullfile('..', 'results', 'stopband_detail_view.png'));
saveas(gcf, fullfile('..', 'results', 'stopband_detail_view.fig'));

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

% Add a common title for the whole figure
sgtitle('Zero-Pole Plots for IIR Filters');

% Save the pole-zero plots
saveas(gcf, fullfile('..', 'results', 'pole_zero_plots.png'));
saveas(gcf, fullfile('..', 'results', 'pole_zero_plots.fig'));

fprintf('\nPlots have been generated and saved to the results directory.\n');
fprintf('For your report, please note:\n');
fprintf('The filter orders (n) we chose for each IIR filter are:\n');
fprintf('- Butterworth: n = %d (actual implemented order = %d)\n', n_butterworth, 2*n_butterworth);
fprintf('- Chebyshev:   n = %d (actual implemented order = %d)\n', n_chebyshev, 2*n_chebyshev);
fprintf('- Elliptic:    n = %d (actual implemented order = %d)\n', n_elliptic, 2*n_elliptic);
fprintf('\nThis is because bandstop filters in MATLAB implement a filter of order 2n when you specify order n.\n');
fprintf('This is mentioned in your assignment instructions.\n'); 