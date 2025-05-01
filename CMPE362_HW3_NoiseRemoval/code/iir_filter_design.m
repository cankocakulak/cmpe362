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

% TODO: Add your code here 