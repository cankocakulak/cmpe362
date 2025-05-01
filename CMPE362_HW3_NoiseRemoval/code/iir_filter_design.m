%% IIR Bandstop Filter Design and Comparison
% CMPE362: Introduction to Signal Processing
% Assignment 3: Noise Removal using FIR and IIR Filters
%
% This script designs and compares IIR bandstop filters (Butterworth, Chebyshev Type I,
% and Elliptic) to remove the identified noise frequency band. It automates the process
% of evaluating different filter orders, saving frequency responses, pole-zero plots,
% filtered audio, and spectrograms in a structured way for easy comparison.
%
% Author: [Your Name]
% Date: [Current Date]

clear all; close all; clc;

% --- User-editable parameters ---
f1 = 7700; % Lower edge of noise band (Hz)
f2 = 8300; % Upper edge of noise band (Hz)
order_fir = 256; % FIR filter order (fixed)
n_vals = 2:35;   % IIR filter orders to try
Rp = 0.1;        % Passband ripple for Chebyshev/Elliptic (dB)
Rs = 40;         % Stopband attenuation for Elliptic (dB)

% Load audio and sampling rate
[x, fs] = audioread(fullfile('..', 'sample.wav'));

% Define stopband edges
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz
Wn = [lower_cutoff upper_cutoff] / (fs/2);

% Frequency range for plotting (zoomed on stopband)
f_plot = 6000:1:10000;
w_plot = 2*pi*f_plot/fs;

% --- Load FIR filter coefficients ---
fir_coeffs_path = fullfile('..','results','freq_responses','fir_coeffs.mat');
if exist(fir_coeffs_path, 'file')
    load(fir_coeffs_path, 'b');
    b_fir = b;
else
    error('FIR coefficients not found. Run fir_filter_design.m first.');
end

% Get FIR frequency response
[H_fir, ~] = freqz(b_fir, 1, w_plot, fs);

% --- Prepare output folders ---
base_dir = fullfile('..','results','comparison');
if ~exist(base_dir, 'dir'), mkdir(base_dir); end
cmp_full_dir = fullfile(base_dir, 'response_full'); if ~exist(cmp_full_dir, 'dir'), mkdir(cmp_full_dir); end
cmp_zoom_dir = fullfile(base_dir, 'response_zoom'); if ~exist(cmp_zoom_dir, 'dir'), mkdir(cmp_zoom_dir); end
cmp_pz_dir = fullfile(base_dir, 'pz'); if ~exist(cmp_pz_dir, 'dir'), mkdir(cmp_pz_dir); end
butter_dir = fullfile(base_dir, 'butterworth'); if ~exist(butter_dir, 'dir'), mkdir(butter_dir); end
cheby_dir = fullfile(base_dir, 'cheby1'); if ~exist(cheby_dir, 'dir'), mkdir(cheby_dir); end
ellip_dir = fullfile(base_dir, 'ellip'); if ~exist(ellip_dir, 'dir'), mkdir(ellip_dir); end

% --- Loop over n values for IIR filters ---
summary_table = {};
% Track best n and attenuation for each filter
best_butter = struct('n', NaN, 'att', -Inf);
best_cheby = struct('n', NaN, 'att', -Inf);
best_ellip = struct('n', NaN, 'att', -Inf);
% Store all n and attenuation for plotting
n_list = n_vals;
att_butter_list = zeros(size(n_list));
att_cheby_list = zeros(size(n_list));
att_ellip_list = zeros(size(n_list));
for idx = 1:length(n_vals)
    n = n_vals(idx);
    fprintf('\nEvaluating filters for n = %d\n', n);
    % Individual filter subfolders
    n_butter_dir = fullfile(butter_dir, sprintf('n%d', n)); if ~exist(n_butter_dir, 'dir'), mkdir(n_butter_dir); end
    n_cheby_dir = fullfile(cheby_dir, sprintf('n%d', n)); if ~exist(n_cheby_dir, 'dir'), mkdir(n_cheby_dir); end
    n_ellip_dir = fullfile(ellip_dir, sprintf('n%d', n)); if ~exist(n_ellip_dir, 'dir'), mkdir(n_ellip_dir); end
    % Butterworth
    [b_butter, a_butter] = butter(n, Wn, 'stop');
    H_butter_full = freqz(b_butter, a_butter, 0:1:fs/2, fs);
    % Chebyshev
    [b_cheby, a_cheby] = cheby1(n, Rp, Wn, 'stop');
    H_cheby_full = freqz(b_cheby, a_cheby, 0:1:fs/2, fs);
    % Elliptic
    [b_ellip, a_ellip] = ellip(n, Rp, Rs, Wn, 'stop');
    H_ellip_full = freqz(b_ellip, a_ellip, 0:1:fs/2, fs);
    % FIR (full range)
    H_fir_full = freqz(b_fir, 1, 0:1:fs/2, fs);
    % --- Full-Range Frequency Response Plot (Comparison) ---
    figure('Visible','off');
    plot(0:1:fs/2, 20*log10(abs(H_fir_full)), 'b', 'LineWidth', 1.2); hold on;
    plot(0:1:fs/2, 20*log10(abs(H_butter_full)), 'r', 'LineWidth', 1.2);
    plot(0:1:fs/2, 20*log10(abs(H_cheby_full)), 'g', 'LineWidth', 1.2);
    plot(0:1:fs/2, 20*log10(abs(H_ellip_full)), 'm', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Frequency Response (Full), n = %d', n));
    legend('FIR','Butterworth','Chebyshev','Elliptic'); grid on;
    saveas(gcf, fullfile(cmp_full_dir, sprintf('n%d.png', n)));
    hold off;
    % --- Full-Range Frequency Response Plot (Individual) ---
    figure('Visible','off');
    plot(0:1:fs/2, 20*log10(abs(H_fir_full)), 'b', 'LineWidth', 1.2); hold on;
    plot(0:1:fs/2, 20*log10(abs(H_butter_full)), 'r', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Butterworth vs FIR (Full), n = %d', n)); legend('FIR','Butterworth'); grid on;
    saveas(gcf, fullfile(n_butter_dir, 'response_full.png'));
    hold off;
    figure('Visible','off');
    plot(0:1:fs/2, 20*log10(abs(H_fir_full)), 'b', 'LineWidth', 1.2); hold on;
    plot(0:1:fs/2, 20*log10(abs(H_cheby_full)), 'g', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Chebyshev vs FIR (Full), n = %d', n)); legend('FIR','Chebyshev'); grid on;
    saveas(gcf, fullfile(n_cheby_dir, 'response_full.png'));
    hold off;
    figure('Visible','off');
    plot(0:1:fs/2, 20*log10(abs(H_fir_full)), 'b', 'LineWidth', 1.2); hold on;
    plot(0:1:fs/2, 20*log10(abs(H_ellip_full)), 'm', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Elliptic vs FIR (Full), n = %d', n)); legend('FIR','Elliptic'); grid on;
    saveas(gcf, fullfile(n_ellip_dir, 'response_full.png'));
    hold off;
    % --- Zoomed Frequency Response Plot (Comparison) ---
    f_plot_zoom = 7000:1:9000;
    w_plot_zoom = 2*pi*f_plot_zoom/fs;
    H_fir_zoom = freqz(b_fir, 1, w_plot_zoom, fs);
    H_butter_zoom = freqz(b_butter, a_butter, w_plot_zoom, fs);
    H_cheby_zoom = freqz(b_cheby, a_cheby, w_plot_zoom, fs);
    H_ellip_zoom = freqz(b_ellip, a_ellip, w_plot_zoom, fs);
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_butter_zoom)), 'r', 'LineWidth', 1.2);
    plot(f_plot_zoom, 20*log10(abs(H_cheby_zoom)), 'g', 'LineWidth', 1.2);
    plot(f_plot_zoom, 20*log10(abs(H_ellip_zoom)), 'm', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Frequency Response (Zoomed), n = %d', n));
    legend('FIR','Butterworth','Chebyshev','Elliptic'); grid on;
    xlim([7000 9000]);
    saveas(gcf, fullfile(cmp_zoom_dir, sprintf('n%d.png', n)));
    hold off;
    % --- Zoomed Frequency Response Plot (Individual) ---
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_butter_zoom)), 'r', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Butterworth vs FIR (Zoomed), n = %d', n)); legend('FIR','Butterworth'); grid on;
    xlim([7000 9000]);
    saveas(gcf, fullfile(n_butter_dir, 'response_zoom.png'));
    hold off;
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_cheby_zoom)), 'g', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Chebyshev vs FIR (Zoomed), n = %d', n)); legend('FIR','Chebyshev'); grid on;
    xlim([7000 9000]);
    saveas(gcf, fullfile(n_cheby_dir, 'response_zoom.png'));
    hold off;
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_ellip_zoom)), 'm', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Elliptic vs FIR (Zoomed), n = %d', n)); legend('FIR','Elliptic'); grid on;
    xlim([7000 9000]);
    saveas(gcf, fullfile(n_ellip_dir, 'response_zoom.png'));
    hold off;
    % --- Combined Pole-Zero Plot for IIRs (Comparison) ---
    figure('Visible','off','Position', [100, 100, 900, 300]);
    subplot(1,3,1); zplane(b_butter, a_butter); title('Butterworth'); axis([-1 1 -1 1]*1.1);
    subplot(1,3,2); zplane(b_cheby, a_cheby); title('Chebyshev'); axis([-1 1 -1 1]*1.1);
    subplot(1,3,3); zplane(b_ellip, a_ellip); title('Elliptic'); axis([-1 1 -1 1]*1.1);
    sgtitle(sprintf('Zero Pole Plots for IIR Filters, n = %d', n));
    saveas(gcf, fullfile(cmp_pz_dir, sprintf('n%d.png', n)));
    % --- Individual Pole-Zero Plots ---
    figure('Visible','off'); zplane(b_butter, a_butter); title('Butterworth'); axis([-1 1 -1 1]*1.1);
    saveas(gcf, fullfile(n_butter_dir, 'pz.png'));
    figure('Visible','off'); zplane(b_cheby, a_cheby); title('Chebyshev'); axis([-1 1 -1 1]*1.1);
    saveas(gcf, fullfile(n_cheby_dir, 'pz.png'));
    figure('Visible','off'); zplane(b_ellip, a_ellip); title('Elliptic'); axis([-1 1 -1 1]*1.1);
    saveas(gcf, fullfile(n_ellip_dir, 'pz.png'));
    
    % --- Summary Table and Best n Tracking ---
    % Create a more focused frequency vector for accurate attenuation measurement
    f_stop = lower_cutoff:(upper_cutoff-lower_cutoff)/100:upper_cutoff;
    w_stop = 2*pi*f_stop/fs;
    
    % Get frequency responses at the stopband frequencies
    H_butter_stop = freqz(b_butter, a_butter, w_stop, fs);
    H_cheby_stop = freqz(b_cheby, a_cheby, w_stop, fs);
    H_ellip_stop = freqz(b_ellip, a_ellip, w_stop, fs);
    
    % Calculate minimum stopband attenuation
    min_att_butter = min(20*log10(abs(H_butter_stop)));
    min_att_cheby = min(20*log10(abs(H_cheby_stop)));
    min_att_ellip = min(20*log10(abs(H_ellip_stop)));
    
    summary_table = [summary_table; {'Butterworth', n, min_att_butter}];
    summary_table = [summary_table; {'Chebyshev', n, min_att_cheby}];
    summary_table = [summary_table; {'Elliptic', n, min_att_ellip}];
    att_butter_list(idx) = min_att_butter;
    att_cheby_list(idx) = min_att_cheby;
    att_ellip_list(idx) = min_att_ellip;
    
    % Track best n (lowest n with attenuation <= -40 dB)
    if min_att_butter <= -40 && (isnan(best_butter.n) || n < best_butter.n)
        best_butter.n = n; best_butter.att = min_att_butter;
    end
    if min_att_cheby <= -40 && (isnan(best_cheby.n) || n < best_cheby.n)
        best_cheby.n = n; best_cheby.att = min_att_cheby;
    end
    if min_att_ellip <= -40 && (isnan(best_ellip.n) || n < best_ellip.n)
        best_ellip.n = n; best_ellip.att = min_att_ellip;
    end
end

% --- Print and save summary table ---
summary_txt = fullfile(base_dir, 'summary_table.txt');
fid = fopen(summary_txt, 'w');
fprintf(fid, 'FilterType\tn\tMinStopbandAttenuation(dB)\n');
for i = 1:size(summary_table,1)
    fprintf(fid, '%s\t%d\t%.2f\n', summary_table{i,1}, summary_table{i,2}, summary_table{i,3});
end
fclose(fid);

% --- Plot attenuation vs n for each filter ---
figure;
plot(n_list, att_butter_list, 'r-o', 'LineWidth', 1.2); hold on;
plot(n_list, att_cheby_list, 'g-o', 'LineWidth', 1.2);
plot(n_list, att_ellip_list, 'm-o', 'LineWidth', 1.2);
ylabel('Min Stopband Attenuation (dB)'); xlabel('Filter Order n');
title('Stopband Attenuation vs Filter Order');
legend('Butterworth','Chebyshev','Elliptic'); grid on;
saveas(gcf, fullfile(base_dir, 'attenuation_vs_n.png'));

% --- Print best n for each filter ---
fprintf('\nBest n for Butterworth: n = %d (attenuation = %.2f dB)\n', best_butter.n, best_butter.att);
fprintf('Best n for Chebyshev:  n = %d (attenuation = %.2f dB)\n', best_cheby.n, best_cheby.att);
fprintf('Best n for Elliptic:   n = %d (attenuation = %.2f dB)\n', best_ellip.n, best_ellip.att); 