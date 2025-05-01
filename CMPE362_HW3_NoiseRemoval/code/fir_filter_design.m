%% FIR Bandstop Filter Design
% CMPE362: Introduction to Signal Processing
% Assignment 3: Noise Removal using FIR and IIR Filters
%
% This script designs a 256th-order FIR bandstop filter using fir1()
% to remove the identified noise frequency band.
%
% TODO:
% 1. Use the identified frequency band (f1-f2) from spectrogram analysis
% 2. Design 256th-order FIR bandstop filter using fir1()
% 3. Plot and analyze the frequency response
% 4. Save the frequency response plot
%
% Author: [Your Name]
% Date: [Current Date]

% Clear workspace and close all figures
clear all;
close all;
clc;

% --- User-editable parameters (update f1 and f2 as needed) ---
f1 = 7700; % Lower edge of noise band (Hz)
f2 = 8300; % Upper edge of noise band (Hz)

% Load sampling rate from audio file
audio_path = fullfile('..', 'sample.wav');
[~, fs] = audioread(audio_path);

% Define stopband edges
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz

% Normalize cutoff frequencies for fir1
Wn = [lower_cutoff upper_cutoff] / (fs/2);

% Design 256th-order FIR bandstop filter
order = 256;
b = fir1(order, Wn, 'stop');

% Create results directory if it doesn't exist
results_dir = fullfile('..', 'results', 'freq_responses');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Plot and save frequency response
figure;
freqz(b, 1, 2048, fs);
title('256th-Order FIR Bandstop Filter Frequency Response');
saveas(gcf, fullfile(results_dir, 'frequency_response_fir.png'));

% Optionally, save filter coefficients for later use
save(fullfile(results_dir, 'fir_coeffs.mat'), 'b', 'order', 'Wn', 'f1', 'f2', 'fs'); 