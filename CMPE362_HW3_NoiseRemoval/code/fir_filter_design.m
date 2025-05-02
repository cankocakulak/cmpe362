% Clear workspace and close all figures
clear all;
close all;
clc;

% --- User-editable parameters (update f1 and f2 as needed) ---
% Updated frequency range to target the 4-5 kHz noise band visible in the spectrogram
f1 = 4000; % Lower edge of noise band (Hz)
f2 = 5000; % Upper edge of noise band (Hz)

% Load sampling rate from audio file
audio_path = fullfile('..', 'sample.wav');
[~, fs] = audioread(audio_path);
fprintf('Audio sampling rate: %d Hz\n', fs);

% Define stopband edges according to the assignment requirements
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz
fprintf('Filter cutoff frequencies: [%d, %d] Hz\n', lower_cutoff, upper_cutoff);

% Normalize cutoff frequencies for fir1
Wn = [lower_cutoff upper_cutoff] / (fs/2);
fprintf('Normalized cutoff frequencies: [%.4f, %.4f]\n', Wn(1), Wn(2));

% Design 256th-order FIR bandstop filter
order = 256;
b = fir1(order, Wn, 'stop');

% Create results directory if it doesn't exist
results_dir = fullfile('..', 'results', 'freq_responses');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Plot frequency response (full range)
figure('Position', [100, 100, 800, 500]);
[h, w] = freqz(b, 1, 1024, fs);
plot(w, 20*log10(abs(h)), 'b', 'LineWidth', 1.5);
grid on;
title('256th-Order FIR Bandstop Filter Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 fs/2]);
ylim([-80 5]);

% Add lines marking the noise band and filter cutoffs
hold on;
xline(lower_cutoff, 'r--', 'LineWidth', 1.5);
xline(upper_cutoff, 'r--', 'LineWidth', 1.5);
xline(f1, 'g--', 'LineWidth', 1.5);
xline(f2, 'g--', 'LineWidth', 1.5);
legend('Filter Response', 'Lower Cutoff', 'Upper Cutoff', 'Lower Noise Band', 'Upper Noise Band');
hold off;

% Save the frequency response plot
saveas(gcf, fullfile(results_dir, 'frequency_response_fir.png'));
saveas(gcf, fullfile(results_dir, 'frequency_response_fir.fig'));

% Plot zoomed view around the stopband
figure('Position', [100, 100, 800, 400]);
plot(w, 20*log10(abs(h)), 'b', 'LineWidth', 1.5);
grid on;
title('Zoomed View of FIR Filter Response in Stopband Region');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([2000 7000]);  % Zoom on the region around the noise band
ylim([-80 5]);

% Add the vertical lines again in the zoomed view
hold on;
xline(lower_cutoff, 'r--', 'LineWidth', 1.5);
xline(upper_cutoff, 'r--', 'LineWidth', 1.5);
xline(f1, 'g--', 'LineWidth', 1.5);
xline(f2, 'g--', 'LineWidth', 1.5);
legend('Filter Response', 'Lower Cutoff', 'Upper Cutoff', 'Lower Noise Band', 'Upper Noise Band');
hold off;

% Save the zoomed view
saveas(gcf, fullfile(results_dir, 'frequency_response_fir_zoomed.png'));
saveas(gcf, fullfile(results_dir, 'frequency_response_fir_zoomed.fig'));

% Apply the filter to sample.wav and save the filtered audio
[x, fs] = audioread(audio_path);
y_filtered = filter(b, 1, x);

% Create output directory for filtered audio
filtered_dir = fullfile('..', 'filtered_audios');
if ~exist(filtered_dir, 'dir')
    mkdir(filtered_dir);
end

% Save the filtered audio
audiowrite(fullfile(filtered_dir, 'fir_filtered.wav'), y_filtered, fs);
fprintf('Filtered audio saved to: %s\n', fullfile(filtered_dir, 'fir_filtered.wav'));

% Generate spectrograms for comparison
% Set up spectrogram parameters
window_size = 1024;
overlap = round(0.75 * window_size);
nfft = 2048;

% Create directory for spectrograms if it doesn't exist
spectrograms_dir = fullfile('..', 'results', 'spectrograms');
if ~exist(spectrograms_dir, 'dir')
    mkdir(spectrograms_dir);
end

% Create a comparison figure
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
ylim([0 7000]);  % Match with IIR filter visualization

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
title('FIR Filtered Audio (Order = 256)');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
ylim([0 7000]);  % Match with IIR filter visualization

% Add horizontal lines to mark the noise band and filter cutoffs
hold on;
yline(f1, 'g--', 'LineWidth', 1.5);
yline(f2, 'g--', 'LineWidth', 1.5);
yline(lower_cutoff, 'r--', 'LineWidth', 1.5);
yline(upper_cutoff, 'r--', 'LineWidth', 1.5);
hold off;

% Add legend explanation
annotation('textbox', [0.15, 0.01, 0.7, 0.05], ...
    'String', {'Green dashed lines: Identified noise band (4000-5000 Hz)', ...
               'Red dashed lines: Filter cutoff frequencies (3500-5500 Hz)'}, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center');

% Save the comparison figure
saveas(gcf, fullfile(spectrograms_dir, 'original_vs_fir_filtered.png'));
saveas(gcf, fullfile(spectrograms_dir, 'original_vs_fir_filtered.fig'));

% Create a focused view of silent regions (1.5-2.5 seconds)
figure('Position', [100, 100, 800, 600]);

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

% Add annotation about noise removal
annotation('textbox', [0.2, 0.01, 0.6, 0.05], ...
    'String', {'Green dashed lines show noise band at 4000-5000 Hz', ...
               'Notice how the noise is removed in the silent region after filtering'}, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center');

% Save the silent region figure
saveas(gcf, fullfile(spectrograms_dir, 'fir_silent_region_comparison.png'));
saveas(gcf, fullfile(spectrograms_dir, 'fir_silent_region_comparison.fig'));

% Save filter coefficients for later use
save(fullfile(results_dir, 'fir_coeffs.mat'), 'b', 'order', 'Wn', 'f1', 'f2', 'fs');

fprintf('\nFIR filter design and audio filtering complete!\n');
fprintf('The 256th-order FIR bandstop filter targets noise in the %d-%d Hz range.\n', f1, f2); 