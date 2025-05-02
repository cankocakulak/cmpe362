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
b_fir = fir_bandstop_design(order_fir, f1, f2, fs);

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
    saveas(gcf, fullfile(butter_dir, sprintf('response_full_n%d.png', n)));
    hold off;
    
    figure('Visible','off');
    plot(0:1:fs/2, 20*log10(abs(H_fir_full)), 'b', 'LineWidth', 1.2); hold on;
    plot(0:1:fs/2, 20*log10(abs(H_cheby_full)), 'g', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Chebyshev vs FIR (Full), n = %d', n)); legend('FIR','Chebyshev'); grid on;
    saveas(gcf, fullfile(cheby_dir, sprintf('response_full_n%d.png', n)));
    hold off;
    
    figure('Visible','off');
    plot(0:1:fs/2, 20*log10(abs(H_fir_full)), 'b', 'LineWidth', 1.2); hold on;
    plot(0:1:fs/2, 20*log10(abs(H_ellip_full)), 'm', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    title(sprintf('Elliptic vs FIR (Full), n = %d', n)); legend('FIR','Elliptic'); grid on;
    saveas(gcf, fullfile(ellip_dir, sprintf('response_full_n%d.png', n)));
    hold off;
    
    % --- Combined Pole-Zero Plot for IIRs (Comparison) ---
    figure('Visible','off','Position', [100, 100, 900, 300]);
    subplot(1,3,1); zplane(b_butter, a_butter); title('Butterworth'); axis([-1 1 -1 1]*1.1);
    subplot(1,3,2); zplane(b_cheby, a_cheby); title('Chebyshev'); axis([-1 1 -1 1]*1.1);
    subplot(1,3,3); zplane(b_ellip, a_ellip); title('Elliptic'); axis([-1 1 -1 1]*1.1);
    sgtitle(sprintf('Zero Pole Plots for IIR Filters, n = %d', n));
    saveas(gcf, fullfile(cmp_pz_dir, sprintf('n%d.png', n)));
    
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
