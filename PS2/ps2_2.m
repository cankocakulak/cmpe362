% Fourier Analysis Example: Square Wave

fs = 80000;  % Sampling frequency
freq = 440;
tt = 0:1/fs:2; % Extended time range
sq_wave_fft = square(2*pi*freq*tt); % Generate a perfect square wave

Y = fft(sq_wave_fft); % Compute FFT
f = (0:length(Y)-1) * (fs/length(Y)); % Frequency vector
Y_mag = abs(Y) / length(Y); % Normalize magnitude

figure;
stem(f, Y_mag, 'r', 'LineWidth', 1.5);
xlim([0 1000]); % Show up to 1 kHz
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('FFT Spectrum of Square Wave');
grid on;
