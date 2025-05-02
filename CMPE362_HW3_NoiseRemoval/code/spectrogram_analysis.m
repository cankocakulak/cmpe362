% Clear workspace and close all figures
clear all;
close all;
clc;

% Get the current script's directory
current_dir = fileparts(mfilename('fullpath'));
project_root = fullfile(current_dir, '..');

% Create results directory if it doesn't exist
results_dir = fullfile(project_root, 'results', 'spectrograms');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Load the audio file
[x, fs] = audioread(fullfile(project_root, 'sample.wav'));

% Parameters for spectrogram
window = hamming(1024);  % Window size
noverlap = 512;         % Number of overlapping samples
nfft = 1024;            % Number of FFT points

% Compute spectrogram
[S, F, T] = spectrogram(x, window, noverlap, nfft, fs);

% Convert to dB scale for better visualization
S_db = 10*log10(abs(S));

% Create figure
figure('Position', [100, 100, 800, 400]);

% Plot spectrogram
imagesc(T, F/1000, S_db);  % Convert frequency to kHz
axis xy;  % Put zero frequency at the bottom
colormap('jet');
colorbar;

% Add labels and title
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('Spectrogram of Noisy Audio Signal');

% Save the spectrogram
saveas(gcf, fullfile(results_dir, 'original_spectrogram.png'));
