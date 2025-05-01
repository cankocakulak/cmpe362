%% IIR Bandstop Filter Design
% CMPE362: Introduction to Signal Processing
% Assignment 3: Noise Removal using FIR and IIR Filters
%
% This script designs IIR bandstop filters (Butterworth, Chebyshev Type I,
% and Elliptic) to remove the identified noise frequency band.
%
% TODO:
% 1. Use the identified frequency band (f1-f2) from spectrogram analysis
% 2. Design Butterworth bandstop filter
% 3. Design Chebyshev Type I bandstop filter
% 4. Design Elliptic bandstop filter (R=0.1)
% 5. Plot and analyze frequency responses
% 6. Generate pole-zero plots
% 7. Save all plots
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
order = 6; % Butterworth filter order

% Load sampling rate from audio file
audio_path = fullfile('..', 'sample.wav');
[~, fs] = audioread(audio_path);

% Define stopband edges
lower_cutoff = f1 - 500; % Hz
upper_cutoff = f2 + 500; % Hz

% Normalize cutoff frequencies
Wn = [lower_cutoff upper_cutoff] / (fs/2);

% Design Butterworth bandstop filter
[b, a] = butter(order, Wn, 'stop');

% Create results directories if they don't exist
freq_dir = fullfile('..', 'results', 'freq_responses');
pz_dir = fullfile('..', 'results', 'pole_zero_plots');
if ~exist(freq_dir, 'dir'), mkdir(freq_dir); end
if ~exist(pz_dir, 'dir'), mkdir(pz_dir); end

% Plot and save frequency response
figure;
freqz(b, a, 2048, fs);
title('Butterworth Bandstop Filter Frequency Response');
saveas(gcf, fullfile(freq_dir, 'frequency_response_butter.png'));

% Plot and save pole-zero diagram
figure;
zplane(b, a);
title('Butterworth Bandstop Filter Pole-Zero Plot');
saveas(gcf, fullfile(pz_dir, 'butter_pz.png'));

% --- Chebyshev Type I Bandstop Filter ---
cheby_order = 6; % You can adjust this if needed
Rp = 0.1;        % Passband ripple in dB

% Design Chebyshev Type I bandstop filter
[bc, ac] = cheby1(cheby_order, Rp, Wn, 'stop');

% Plot and save frequency response
figure;
freqz(bc, ac, 2048, fs);
title('Chebyshev Type I Bandstop Filter Frequency Response');
saveas(gcf, fullfile(freq_dir, 'frequency_response_cheby1.png'));

% Plot and save pole-zero diagram
figure;
zplane(bc, ac);
title('Chebyshev Type I Bandstop Filter Pole-Zero Plot');
saveas(gcf, fullfile(pz_dir, 'cheby1_pz.png'));

% --- Elliptic Bandstop Filter ---
ellip_order = 6; % You can adjust this if needed
Rp = 0.1;        % Passband ripple in dB
Rs = 40;         % Stopband attenuation in dB (typical value)

% Design Elliptic bandstop filter
[be, ae] = ellip(ellip_order, Rp, Rs, Wn, 'stop');

% Plot and save frequency response
figure;
freqz(be, ae, 2048, fs);
title('Elliptic Bandstop Filter Frequency Response');
saveas(gcf, fullfile(freq_dir, 'frequency_response_ellip.png'));

% Plot and save pole-zero diagram
figure;
zplane(be, ae);
title('Elliptic Bandstop Filter Pole-Zero Plot');
saveas(gcf, fullfile(pz_dir, 'ellip_pz.png'));

% TODO: Add your code here 