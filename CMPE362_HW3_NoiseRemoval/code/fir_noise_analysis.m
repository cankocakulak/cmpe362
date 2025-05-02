%% CMPE362 Assignment 3: Noise Analysis and FIR Filter Implementation
% This script analyzes the original audio to identify the noise frequency range
% and implements a 256th-order FIR bandstop filter to remove the noise.

clear all; close all; clc;

% Load the original audio
[x, fs] = audioread(fullfile('..', 'sample.wav'));
fprintf('Audio sampling rate: %d Hz\n', fs);
fprintf('Audio duration: %.2f seconds\n', length(x)/fs);

% Create output directories
results_dir = fullfile('..', 'results');
if ~exist(results_dir, 'dir'), mkdir(results_dir); end

spectrograms_dir = fullfile(results_dir, 'spectrograms');
if ~exist(spectrograms_dir, 'dir'), mkdir(spectrograms_dir); end

filtered_dir = fullfile('..', 'filtered_audios');
if ~exist(filtered_dir, 'dir'), mkdir(filtered_dir); end

%% Step 1: Generate and analyze the spectrogram to identify noise frequency
% Set up spectrogram parameters for detailed analysis
window_size = 1024;        % Window size
overlap = round(0.75 * window_size); % 75% overlap
nfft = 2048;               % Number of FFT points (for good frequency resolution)

% Generate the spectrogram
figure('Position', [100, 100, 900, 600]);
[s, f, t] = spectrogram(x, hamming(window_size), overlap, nfft, fs, 'yaxis');
s_db = 10*log10(abs(s) + eps); % Convert to dB scale

% Plot the full spectrogram with a suitable color range
imagesc(t, f, s_db);
axis xy; % Put low frequencies at the bottom
colormap(jet);
h = colorbar;
ylabel(h, 'Power/Frequency (dB/Hz)');
title('Spectrogram of Original Noisy Audio');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 fs/2]); % Display full frequency range

% Save the full spectrogram
saveas(gcf, fullfile(spectrograms_dir, 'full_spectrogram.png'));
saveas(gcf, fullfile(spectrograms_dir, 'full_spectrogram.fig'));

%% Step 2: Zoom in on the frequency region of interest
% Based on visual inspection, focus on the region where noise appears
% most prominent in silent parts of the audio (around 4-5 kHz)
figure('Position', [100, 100, 900, 600]);
imagesc(t, f, s_db);
axis xy;
colormap(jet);
colorbar;
title('Spectrogram with Focus on Noise Band');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 7000]); % Focus on lower frequencies where noise is visible

% Identifying the noise frequency range
% (focusing on silent regions around 1.5-2.5 seconds)
f1 = 4000;   % Lower bound of noise frequency (Hz)
f2 = 5000;   % Upper bound of noise frequency (Hz)

% Add horizontal lines to mark the identified noise band
hold on;
yline(f1, 'w--', 'LineWidth', 2);
yline(f2, 'w--', 'LineWidth', 2);
hold off;

% Add annotation explaining the frequency selection
text(0.5, 6000, sprintf('Noise band: %d-%d Hz', f1, f2), ...
    'Color', 'white', 'FontWeight', 'bold', 'FontSize', 12);

% Save the zoomed spectrogram with noise band identified
saveas(gcf, fullfile(spectrograms_dir, 'noise_band_identified.png'));
saveas(gcf, fullfile(spectrograms_dir, 'noise_band_identified.fig'));

fprintf('\nIdentified noise frequency band: %d-%d Hz\n', f1, f2);

%% Step 3: Design and apply 256th-order FIR bandstop filter
% Define the cutoff frequencies as per assignment requirements
lower_cutoff = f1 - 500;  % Hz
upper_cutoff = f2 + 500;  % Hz
fprintf('FIR filter cutoff frequencies: [%d, %d] Hz\n', lower_cutoff, upper_cutoff);

% Normalize the cutoff frequencies to the Nyquist frequency (fs/2)
Wn = [lower_cutoff upper_cutoff] / (fs/2);
fprintf('Normalized cutoff frequencies: [%.4f, %.4f]\n', Wn(1), Wn(2));

% Design the FIR bandstop filter
order_fir = 256;
b_fir = fir1(order_fir, Wn, 'stop');
a_fir = 1; % For FIR filters, a = 1

% Visualize the filter frequency response
[h_fir, f_resp] = freqz(b_fir, a_fir, 1024, fs);
figure('Position', [100, 100, 800, 500]);
plot(f_resp, 20*log10(abs(h_fir)), 'b', 'LineWidth', 1.5);
grid on;
title(sprintf('Frequency Response of %d-order FIR Bandstop Filter', order_fir));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 fs/2]);
ylim([-100 5]);

% Zoom in on the stopband region
hold on;
xline(lower_cutoff, 'r--', 'LineWidth', 1.5);
xline(upper_cutoff, 'r--', 'LineWidth', 1.5);
xline(f1, 'g--', 'LineWidth', 1.5);
xline(f2, 'g--', 'LineWidth', 1.5);
legend('Filter Response', 'Lower Cutoff', 'Upper Cutoff', 'Lower Noise Band', 'Upper Noise Band');
hold off;

% Save the filter response plot
saveas(gcf, fullfile(results_dir, 'fir_filter_response.png'));
saveas(gcf, fullfile(results_dir, 'fir_filter_response.fig'));

% Generate zoomed view of the stopband
figure('Position', [100, 100, 800, 400]);
plot(f_resp, 20*log10(abs(h_fir)), 'b', 'LineWidth', 1.5);
grid on;
title('Zoomed View of FIR Filter Response in Stopband Region');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([2000 7000]);  % Zoom on the region around the 4-5 kHz noise band
ylim([-100 5]);

% Add the vertical lines again in the zoomed view
hold on;
xline(lower_cutoff, 'r--', 'LineWidth', 1.5);
xline(upper_cutoff, 'r--', 'LineWidth', 1.5);
xline(f1, 'g--', 'LineWidth', 1.5);
xline(f2, 'g--', 'LineWidth', 1.5);
legend('Filter Response', 'Lower Cutoff', 'Upper Cutoff', 'Lower Noise Band', 'Upper Noise Band');
hold off;

% Save the zoomed filter response
saveas(gcf, fullfile(results_dir, 'fir_filter_response_zoomed.png'));
saveas(gcf, fullfile(results_dir, 'fir_filter_response_zoomed.fig'));

%% Step 4: Apply the filter to the noisy audio
% Apply the FIR filter
y_filtered = filter(b_fir, a_fir, x);

% Save the filtered audio
audiowrite(fullfile(filtered_dir, 'fir_filtered.wav'), y_filtered, fs);
fprintf('Filtered audio saved to: %s\n', fullfile(filtered_dir, 'fir_filtered.wav'));

%% Step 5: Generate and compare spectrograms of original and filtered audio
figure('Position', [100, 100, 1000, 800]);

% Original audio spectrogram
subplot(2, 1, 1);
[s_orig, f_orig, t_orig] = spectrogram(x, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t_orig, f_orig, 10*log10(abs(s_orig) + eps));
axis xy;
colormap(jet);
colorbar;
title('Original Noisy Audio');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 7000]);  % Focus on the lower frequency range including the noise band

% Add horizontal lines to mark the noise band and filter cutoffs
hold on;
yline(f1, 'g--', 'LineWidth', 1.5);
yline(f2, 'g--', 'LineWidth', 1.5);
yline(lower_cutoff, 'r--', 'LineWidth', 1.5);
yline(upper_cutoff, 'r--', 'LineWidth', 1.5);
hold off;

% Filtered audio spectrogram
subplot(2, 1, 2);
[s_filt, f_filt, t_filt] = spectrogram(y_filtered, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t_filt, f_filt, 10*log10(abs(s_filt) + eps));
axis xy;
colormap(jet);
colorbar;
title(sprintf('FIR Filtered Audio (Order = %d)', order_fir));
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 7000]);  % Match the ylim of the original spectrogram

% Add horizontal lines to mark the noise band and filter cutoffs
hold on;
yline(f1, 'g--', 'LineWidth', 1.5);
yline(f2, 'g--', 'LineWidth', 1.5);
yline(lower_cutoff, 'r--', 'LineWidth', 1.5);
yline(upper_cutoff, 'r--', 'LineWidth', 1.5);
hold off;

% Add legend explanation to the figure
annotation('textbox', [0.15, 0.01, 0.7, 0.05], ...
    'String', {'Green dashed lines: Identified noise band (4000-5000 Hz)', ...
               'Red dashed lines: Filter cutoff frequencies (3500-5500 Hz)'}, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center');

% Save the comparison figure
saveas(gcf, fullfile(spectrograms_dir, 'original_vs_fir_filtered.png'));
saveas(gcf, fullfile(spectrograms_dir, 'original_vs_fir_filtered.fig'));

%% Step 6: Highlight the noise in silent regions for the report
% Create a figure focusing specifically on the silent regions (1.5-2.5 seconds)
figure('Position', [100, 100, 1000, 800]);

% Original audio spectrogram of silent region
subplot(2, 1, 1);
imagesc(t_orig, f_orig, 10*log10(abs(s_orig) + eps));
axis xy;
colormap(jet);
colorbar;
title('Original Noisy Audio (Silent Region)');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 7000]);
xlim([1.5 2.5]);  % Focus on silent region

% Add horizontal lines to mark the noise band
hold on;
yline(f1, 'g--', 'LineWidth', 1.5);
yline(f2, 'g--', 'LineWidth', 1.5);
hold off;

% Filtered audio spectrogram of silent region
subplot(2, 1, 2);
imagesc(t_filt, f_filt, 10*log10(abs(s_filt) + eps));
axis xy;
colormap(jet);
colorbar;
title('FIR Filtered Audio (Silent Region)');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 7000]);
xlim([1.5 2.5]);  % Focus on silent region

% Add horizontal lines to mark the noise band
hold on;
yline(f1, 'g--', 'LineWidth', 1.5);
yline(f2, 'g--', 'LineWidth', 1.5);
hold off;

% Add an annotation
annotation('textbox', [0.2, 0.01, 0.6, 0.05], ...
    'String', {'Green dashed lines show noise band at 4000-5000 Hz', ...
               'Notice how the noise is removed in the silent region after filtering'}, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center');

% Save this figure for the report
saveas(gcf, fullfile(spectrograms_dir, 'silent_region_comparison.png'));
saveas(gcf, fullfile(spectrograms_dir, 'silent_region_comparison.fig'));

fprintf('\nAnalysis and filtering complete!\n');
fprintf('Based on spectrogram analysis, noise is concentrated in the %d-%d Hz range.\n', f1, f2);
fprintf('A %d-order FIR bandstop filter with cutoffs at [%d, %d] Hz was applied.\n', ...
    order_fir, lower_cutoff, upper_cutoff);
fprintf('The filtered audio should have significantly reduced cicada-like noise.\n');
fprintf('Check the spectrograms to visually confirm noise reduction in the target band.\n'); 