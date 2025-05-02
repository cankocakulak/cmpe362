clear all; close all; clc;

% Get the current script's directory and ensure filter algorithms are in the path
current_dir = fileparts(mfilename('fullpath'));
addpath(current_dir);  % Add the current directory to the path

% --- User-editable parameters ---
f1 = 4000; % Lower edge of noise band (Hz)
f2 = 5000; % Upper edge of noise band (Hz)
order_fir = 256; % FIR filter order (fixed)
n_vals = 2:20;   % IIR filter orders to try
Rp = 0.1;        % Passband ripple for Chebyshev/Elliptic (dB) - must be 0.1 as per assignment
Rs = 40;         % Stopband attenuation for Elliptic (dB)

% Load audio and sampling rate
[x, fs] = audioread(fullfile('..', 'sample.wav'));
fprintf('Audio file sampling rate: %.1f Hz\n', fs);

% Define stopband edges - same as used for FIR filter
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz
Wn = [lower_cutoff upper_cutoff] / (fs/2);
fprintf('Normalized cutoff frequencies: [%.4f %.4f]\n', Wn(1), Wn(2));

% Frequency range for plotting (zoomed on stopband)
f_plot = 2000:1:7000;
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
    
    % Call MATLAB's filter design functions directly
    [b_butter, a_butter] = iir_filter_algorithms('butterworth', n, Wn);
    [b_cheby, a_cheby] = iir_filter_algorithms('cheby1', n, Wn, Rp);
    [b_ellip, a_ellip] = iir_filter_algorithms('ellip', n, Wn, Rp, Rs);
    
    % Full-range frequency responses
    H_butter_full = freqz(b_butter, a_butter, 0:1:fs/2, fs);
    H_cheby_full = freqz(b_cheby, a_cheby, 0:1:fs/2, fs);
    H_ellip_full = freqz(b_ellip, a_ellip, 0:1:fs/2, fs);
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
    % Use a higher resolution and narrower band for better stopband visualization
    f_plot_zoom = linspace(lower_cutoff-600, upper_cutoff+600, 1000);
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
    ylim([-80, 5]); % Set y-axis limits to better show attenuation
    xlim([lower_cutoff-600 upper_cutoff+600]);
    % Add vertical lines to mark the stopband
    line([lower_cutoff lower_cutoff], ylim, 'Color', 'k', 'LineStyle', '--');
    line([upper_cutoff upper_cutoff], ylim, 'Color', 'k', 'LineStyle', '--');
    saveas(gcf, fullfile(cmp_zoom_dir, sprintf('n%d.png', n)));
    hold off;
    
    % --- Zoomed Frequency Response Plot (Individual) ---
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_butter_zoom)), 'r', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Butterworth vs FIR (Zoomed), n = %d', n)); legend('FIR','Butterworth'); grid on;
    xlim([lower_cutoff-600 upper_cutoff+600]);
    saveas(gcf, fullfile(n_butter_dir, 'response_zoom.png'));
    hold off;
    
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_cheby_zoom)), 'g', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Chebyshev vs FIR (Zoomed), n = %d', n)); legend('FIR','Chebyshev'); grid on;
    xlim([lower_cutoff-600 upper_cutoff+600]);
    saveas(gcf, fullfile(n_cheby_dir, 'response_zoom.png'));
    hold off;
    
    figure('Visible','off');
    plot(f_plot_zoom, 20*log10(abs(H_fir_zoom)), 'b', 'LineWidth', 1.2); hold on;
    plot(f_plot_zoom, 20*log10(abs(H_ellip_zoom)), 'm', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Elliptic vs FIR (Zoomed), n = %d', n)); legend('FIR','Elliptic'); grid on;
    xlim([lower_cutoff-600 upper_cutoff+600]);
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
    % Use a higher resolution sampling in the stopband
    f_stop = linspace(f1, f2, 1000);
    w_stop = 2*pi*f_stop/fs;
    
    % Get frequency responses at the stopband frequencies
    H_butter_stop = freqz(b_butter, a_butter, w_stop, fs);
    H_cheby_stop = freqz(b_cheby, a_cheby, w_stop, fs);
    H_ellip_stop = freqz(b_ellip, a_ellip, w_stop, fs);
    
    % Calculate minimum stopband attenuation - this should be a negative value!
    % The more negative, the better the attenuation
    [min_att_butter, min_idx_butter] = min(20*log10(abs(H_butter_stop)));
    [min_att_cheby, min_idx_cheby] = min(20*log10(abs(H_cheby_stop)));
    [min_att_ellip, min_idx_ellip] = min(20*log10(abs(H_ellip_stop)));
    
    % Print current attenuation values for debugging
    fprintf('Order %d - Attenuation: Butter = %.2f dB at %.1f Hz, Cheby = %.2f dB at %.1f Hz, Ellip = %.2f dB at %.1f Hz\n', ...
        n, min_att_butter, f_stop(min_idx_butter), min_att_cheby, f_stop(min_idx_cheby), min_att_ellip, f_stop(min_idx_ellip));
    
    summary_table = [summary_table; {'Butterworth', n, min_att_butter}];
    summary_table = [summary_table; {'Chebyshev', n, min_att_cheby}];
    summary_table = [summary_table; {'Elliptic', n, min_att_ellip}];
    att_butter_list(idx) = min_att_butter;
    att_cheby_list(idx) = min_att_cheby;
    att_ellip_list(idx) = min_att_ellip;
    
    % Track best n (lowest n with good attenuation)
    % Track the filter with the deepest attenuation (most negative value)
    if isnan(best_butter.n) || min_att_butter < best_butter.att
        best_butter.n = n; best_butter.att = min_att_butter;
    end
    if isnan(best_cheby.n) || min_att_cheby < best_cheby.att
        best_cheby.n = n; best_cheby.att = min_att_cheby;
    end
    if isnan(best_ellip.n) || min_att_ellip < best_ellip.att
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
ylim([-80, 0]); % Set a reasonable y-axis limit to see differences
saveas(gcf, fullfile(base_dir, 'attenuation_vs_n.png'));

% Create a special visualization for higher orders
high_orders = [10, 15, 20];
for i = 1:length(high_orders)
    n_high = high_orders(i);
    idx = find(n_vals == n_high);
    if isempty(idx)
        continue;
    end
    
    % Design filters for this specific high order
    [b_butter_high, a_butter_high] = iir_filter_algorithms('butterworth', n_high, Wn);
    [b_cheby_high, a_cheby_high] = iir_filter_algorithms('cheby1', n_high, Wn, Rp);
    [b_ellip_high, a_ellip_high] = iir_filter_algorithms('ellip', n_high, Wn, Rp, Rs);
    
    % Create a detailed frequency vector
    f_detail = linspace(lower_cutoff-800, upper_cutoff+800, 2000);
    w_detail = 2*pi*f_detail/fs;
    
    % Get responses
    H_fir_detail = freqz(b_fir, 1, w_detail, fs);
    H_butter_detail = freqz(b_butter_high, a_butter_high, w_detail, fs);
    H_cheby_detail = freqz(b_cheby_high, a_cheby_high, w_detail, fs);
    H_ellip_detail = freqz(b_ellip_high, a_ellip_high, w_detail, fs);
    
    % Create a detailed comparison plot
    figure('Position', [100, 100, 800, 600]);
    plot(f_detail, 20*log10(abs(H_fir_detail)), 'b', 'LineWidth', 1.5); hold on;
    plot(f_detail, 20*log10(abs(H_butter_detail)), 'r', 'LineWidth', 1.5);
    plot(f_detail, 20*log10(abs(H_cheby_detail)), 'g', 'LineWidth', 1.5);
    plot(f_detail, 20*log10(abs(H_ellip_detail)), 'm', 'LineWidth', 1.5);
    
    % Add vertical lines for stopband edges
    line([lower_cutoff lower_cutoff], ylim, 'Color', 'k', 'LineStyle', '--');
    line([upper_cutoff upper_cutoff], ylim, 'Color', 'k', 'LineStyle', '--');
    
    % Annotate the depth points
    [min_butter_val, min_butter_idx] = min(20*log10(abs(H_butter_detail)));
    [min_cheby_val, min_cheby_idx] = min(20*log10(abs(H_cheby_detail)));
    [min_ellip_val, min_ellip_idx] = min(20*log10(abs(H_ellip_detail)));
    
    plot(f_detail(min_butter_idx), min_butter_val, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    text(f_detail(min_butter_idx)+50, min_butter_val, sprintf('%.1f dB', min_butter_val), 'Color', 'r');
    
    plot(f_detail(min_cheby_idx), min_cheby_val, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    text(f_detail(min_cheby_idx)+50, min_cheby_val, sprintf('%.1f dB', min_cheby_val), 'Color', 'g');
    
    plot(f_detail(min_ellip_idx), min_ellip_val, 'mo', 'MarkerSize', 8, 'MarkerFaceColor', 'm');
    text(f_detail(min_ellip_idx)+50, min_ellip_val, sprintf('%.1f dB', min_ellip_val), 'Color', 'm');
    
    % Format the plot
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Detailed Frequency Response, n = %d', n_high));
    legend('FIR (n=256)','Butterworth','Chebyshev','Elliptic', 'Location', 'southeast');
    grid on;
    ylim([-60, 5]);
    
    % Save the figure
    saveas(gcf, fullfile(base_dir, sprintf('detailed_n%d.png', n_high)));
end

% --- Print best n for each filter ---
fprintf('\nBest n for Butterworth: n = %d (attenuation = %.2f dB)\n', best_butter.n, best_butter.att);
fprintf('Best n for Chebyshev:  n = %d (attenuation = %.2f dB)\n', best_cheby.n, best_cheby.att);
fprintf('Best n for Elliptic:   n = %d (attenuation = %.2f dB)\n', best_ellip.n, best_ellip.att); 