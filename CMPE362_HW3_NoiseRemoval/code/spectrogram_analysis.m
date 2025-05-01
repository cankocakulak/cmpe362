%% Spectrogram Analysis for Noise Removal
% CMPE362: Introduction to Signal Processing
% Assignment 3: Noise Removal using FIR and IIR Filters
%
% This script analyzes the spectrogram of the noisy audio file to identify
% the frequency band containing the cicada-like noise.
%
% TODO:
% 1. Load the sample.wav file
% 2. Compute and plot the spectrogram
% 3. Identify the noise frequency band (f1-f2)
% 4. Save the spectrogram plot to results/spectrograms/original_spectrogram.png
%
% Author: [Your Name]
% Date: [Current Date]

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

% Display instructions for identifying noise frequency band
fprintf('Analyze the spectrogram to identify the noise frequency band.\n');
fprintf('Look for:\n');
fprintf('1. Continuous horizontal lines in the spectrogram\n');
fprintf('2. Particularly in silent regions of the audio\n');
fprintf('3. The cicada-like noise should appear as a distinct frequency band\n\n');

% Note: The actual frequency band (f1, f2) will be determined by visual inspection
% of the spectrogram. These values will be used in subsequent filter design scripts. 