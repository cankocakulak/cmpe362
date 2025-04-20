% Fourier Synthesis Example: Square Wave

% Time vector
fs = 80000; % Sample Rate
freq = 440;  % Fundamental Frequency
tt = 0:1/fs:2;  % Time range

% Fourier Synthesis: Approximating Square Wave
N = 2;  % Number of Fourier terms
sq_wave = zeros(size(tt));

for k = 1:N
    n = 2*k - 1;  % Odd harmonics only
    sq_wave = sq_wave + (4/pi) * (1/n) * sin(n*2*pi*freq*tt);
end

true_sq_wave = square(2*pi*freq*tt);


figure;
plot(tt, sq_wave, 'b', 'LineWidth', 1.5);
hold on;
plot(tt, true_sq_wave, 'r--', 'LineWidth', 1.5); % Ideal square wave
xlabel('Time');
ylabel('Amplitude');
title(['Fourier Series Approximation of Square Wave (N = ' num2str(N) ')']);
legend('Approximation', 'Ideal Square Wave');
grid on;

axis([0 0.0200 -1.5 1.5]);
