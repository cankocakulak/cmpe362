%% CMPE362 Assignment 3: Apply Filters and Generate Spectrograms
% This script applies the designed FIR and IIR filters to the noisy audio signal,
% generates spectrograms for comparison, and saves the filtered audio files.
%
% Four filters are applied:
% 1. FIR filter (n=256)
% 2. Butterworth IIR filter (n=10)
% 3. Chebyshev Type I IIR filter (n=11)
% 4. Elliptic IIR filter (n=8)

clear all; close all; clc;

% Optimal filter orders determined from analysis
n_butterworth = 10;
n_chebyshev = 11;
n_elliptic = 8;

% Filter parameters - UPDATED based on spectrogram inspection
f1 = 4000; % Lower edge of noise band (Hz)
f2 = 5000; % Upper edge of noise band (Hz)
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz
Rp = 0.1; % Passband ripple (dB)
Rs = 40;  % Stopband attenuation (dB)

% Load the noisy audio
[x, fs] = audioread(fullfile('..', 'sample.wav'));
fprintf('Audio file sampling rate: %.1f Hz\n', fs);
fprintf('Audio file duration: %.2f seconds\n', length(x)/fs);

% Normalized cutoff frequencies
Wn = [lower_cutoff upper_cutoff] / (fs/2);

% Create output directory if it doesn't exist
filtered_dir = fullfile('..', 'filtered_audios');
if ~exist(filtered_dir, 'dir')
    mkdir(filtered_dir);
    fprintf('Created directory for filtered audio files: %s\n', filtered_dir);
end

% Create directory for spectrograms
spectrograms_dir = fullfile('..', 'results', 'spectrograms');
if ~exist(spectrograms_dir, 'dir')
    mkdir(spectrograms_dir);
    fprintf('Created directory for spectrograms: %s\n', spectrograms_dir);
end

% 1. Design FIR filter
fprintf('Designing FIR filter (n=%d)...\n', 256);
order_fir = 256;
b_fir = fir_bandstop_design(order_fir, f1, f2, fs);
a_fir = 1; % FIR filter has no feedback terms

% 2. Design IIR filters
fprintf('Designing Butterworth filter (n=%d, actual order=%d)...\n', n_butterworth, 2*n_butterworth);
[b_butter, a_butter] = butter(n_butterworth, Wn, 'stop');

fprintf('Designing Chebyshev Type I filter (n=%d, actual order=%d)...\n', n_chebyshev, 2*n_chebyshev);
[b_cheby, a_cheby] = cheby1(n_chebyshev, Rp, Wn, 'stop');

fprintf('Designing Elliptic filter (n=%d, actual order=%d)...\n', n_elliptic, 2*n_elliptic);
[b_ellip, a_ellip] = ellip(n_elliptic, Rp, Rs, Wn, 'stop');

% 3. Apply the filters to the noisy signal
fprintf('Applying filters to the noisy signal...\n');
y_fir = filter(b_fir, a_fir, x);
y_butter = filter(b_butter, a_butter, x);
y_cheby = filter(b_cheby, a_cheby, x);
y_ellip = filter(b_ellip, a_ellip, x);

% 4. Save the filtered audio files
fprintf('Saving filtered audio files...\n');
audiowrite(fullfile(filtered_dir, 'filtered_fir.wav'), y_fir, fs);
audiowrite(fullfile(filtered_dir, 'filtered_butterworth.wav'), y_butter, fs);
audiowrite(fullfile(filtered_dir, 'filtered_chebyshev.wav'), y_cheby, fs);
audiowrite(fullfile(filtered_dir, 'filtered_elliptic.wav'), y_ellip, fs);

% 5. Generate and plot spectrograms
fprintf('Generating spectrograms...\n');

% Spectrogram parameters - adjusted to better visualize the noise band
window_size = 1024;        % Window size for spectrogram
overlap = round(0.75 * window_size); % 75% overlap for better visualization
nfft = 2048;               % Number of FFT points
freq_range = [0 7000];     % Focus on the area around the revised noise band

% Function to plot and save spectrogram
function plot_spectrogram(audio, fs, title_text, filename, window_size, overlap, nfft, freq_range, f1, f2)
    figure('Position', [100, 100, 800, 500]);
    
    % Calculate the spectrogram
    [s, f, t] = spectrogram(audio, hamming(window_size), overlap, nfft, fs, 'yaxis');
    
    % Convert to dB scale
    s_db = 10*log10(abs(s) + eps);
    
    % Plot the spectrogram
    imagesc(t, f, s_db);
    axis xy;
    colormap(jet);
    colorbar;
    
    % Highlight the noise frequency band
    hold on;
    yline(f1, 'w--', 'LineWidth', 1.5);
    yline(f2, 'w--', 'LineWidth', 1.5);
    hold off;
    
    % Set title and labels
    title(title_text);
    xlabel('Time (seconds)');
    ylabel('Frequency (Hz)');
    ylim(freq_range);
    
    % Save the figure
    saveas(gcf, filename);
    saveas(gcf, [filename(1:end-4) '.fig']);
end

% Plot the filtered signal spectrograms
plot_spectrogram(y_fir, fs, 'Spectrogram: FIR Filtered (n=256)', ...
    fullfile(spectrograms_dir, 'fir_spectrogram.png'), ...
    window_size, overlap, nfft, freq_range, f1, f2);

plot_spectrogram(y_butter, fs, sprintf('Spectrogram: Butterworth Filtered (n=%d)', n_butterworth), ...
    fullfile(spectrograms_dir, 'butterworth_spectrogram.png'), ...
    window_size, overlap, nfft, freq_range, f1, f2);

plot_spectrogram(y_cheby, fs, sprintf('Spectrogram: Chebyshev Filtered (n=%d)', n_chebyshev), ...
    fullfile(spectrograms_dir, 'chebyshev_spectrogram.png'), ...
    window_size, overlap, nfft, freq_range, f1, f2);

plot_spectrogram(y_ellip, fs, sprintf('Spectrogram: Elliptic Filtered (n=%d)', n_elliptic), ...
    fullfile(spectrograms_dir, 'elliptic_spectrogram.png'), ...
    window_size, overlap, nfft, freq_range, f1, f2);

% 6. Create a combined figure with all spectrograms for easy comparison
fprintf('Creating combined spectrogram figure for comparison...\n');

figure('Position', [100, 100, 1200, 900]);

% Original signal
subplot(3, 2, 1);
[s, f, t] = spectrogram(x, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t, f, 10*log10(abs(s) + eps));
axis xy; colormap(jet); colorbar;
hold on;
yline(f1, 'w--', 'LineWidth', 1.5);
yline(f2, 'w--', 'LineWidth', 1.5);
hold off;
title('Original Noisy Signal');
xlabel('Time (seconds)'); ylabel('Frequency (Hz)');
ylim(freq_range);

% FIR filter
subplot(3, 2, 3);
[s, f, t] = spectrogram(y_fir, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t, f, 10*log10(abs(s) + eps));
axis xy; colormap(jet); colorbar;
hold on;
yline(f1, 'w--', 'LineWidth', 1.5);
yline(f2, 'w--', 'LineWidth', 1.5);
hold off;
title('FIR Filtered (n=256)');
xlabel('Time (seconds)'); ylabel('Frequency (Hz)');
ylim(freq_range);

% Butterworth
subplot(3, 2, 4);
[s, f, t] = spectrogram(y_butter, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t, f, 10*log10(abs(s) + eps));
axis xy; colormap(jet); colorbar;
hold on;
yline(f1, 'w--', 'LineWidth', 1.5);
yline(f2, 'w--', 'LineWidth', 1.5);
hold off;
title(sprintf('Butterworth Filtered (n=%d)', n_butterworth));
xlabel('Time (seconds)'); ylabel('Frequency (Hz)');
ylim(freq_range);

% Chebyshev
subplot(3, 2, 5);
[s, f, t] = spectrogram(y_cheby, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t, f, 10*log10(abs(s) + eps));
axis xy; colormap(jet); colorbar;
hold on;
yline(f1, 'w--', 'LineWidth', 1.5);
yline(f2, 'w--', 'LineWidth', 1.5);
hold off;
title(sprintf('Chebyshev Filtered (n=%d)', n_chebyshev));
xlabel('Time (seconds)'); ylabel('Frequency (Hz)');
ylim(freq_range);

% Elliptic
subplot(3, 2, 6);
[s, f, t] = spectrogram(y_ellip, hamming(window_size), overlap, nfft, fs, 'yaxis');
imagesc(t, f, 10*log10(abs(s) + eps));
axis xy; colormap(jet); colorbar;
hold on;
yline(f1, 'w--', 'LineWidth', 1.5);
yline(f2, 'w--', 'LineWidth', 1.5);
hold off;
title(sprintf('Elliptic Filtered (n=%d)', n_elliptic));
xlabel('Time (seconds)'); ylabel('Frequency (Hz)');
ylim(freq_range);

% Add a title to the figure
sgtitle(sprintf('Comparison of Different Filters for Noise Removal (%d-%d Hz)', f1, f2));

% Save the combined spectrogram
saveas(gcf, fullfile(spectrograms_dir, 'combined_spectrograms.png'));
saveas(gcf, fullfile(spectrograms_dir, 'combined_spectrograms.fig'));

% 7. Create a focused view on silent regions (1.5-2.5 seconds)
figure('Position', [100, 100, 1200, 900]);

