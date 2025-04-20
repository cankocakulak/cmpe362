% Inverse FFT Example

% Sampling parameters
fs = 80000;  % Sampling frequency
tt = 0:1/fs:2;  % Time vector
freq = 440;

% Generate a perfect square wave
sq_wave = square(2*pi*freq*tt);

% Compute FFT
Y = fft(sq_wave);
% Y(7) = 2*Y(7);
% Y(200) = 4 * length(Y);

Y_mag = abs(Y) / length(Y); % Normalize magnitude
f = (0:length(Y)-1) * (fs/length(Y)); % Frequency vector


% Reconstruct the signal using IFFT
reconstructed_wave = ifft(Y, 'symmetric'); % Ensure real output

% Plot original and reconstructed wave
figure;
subplot(3,1,1);
plot(tt, sq_wave, 'b', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Amplitude');
xlim([0 0.02]);
title('Original Square Wave');
grid on;

subplot(3,1,2);
stem(f, Y_mag, 'r', 'LineWidth', 1.5);
xlim([0 1000]); % Show up to 1 kHz
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('FFT Spectrum of Square Wave');
grid on;

subplot(3,1,3);
plot(tt, reconstructed_wave, 'g', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Amplitude');
xlim([0 0.02]);
title('Reconstructed Wave from IFFT');
grid on;

% Compare original and reconstructed wave
figure;
plot(tt, sq_wave, 'b', 'LineWidth', 1.5);
hold on;
plot(tt, reconstructed_wave, 'g--', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Amplitude');
title('Comparison: Original vs. Reconstructed Wave');
legend('Original', 'Reconstructed');
grid on;
