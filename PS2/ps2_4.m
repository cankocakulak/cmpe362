% Fourier Synthesis Example: Sawtooth

% Number of sine waves in finite computation
n = 150;
% Amplitude
A = 0.5;
% Sample Rate (samples per second) 
sr = 20000;
% Signal length (in seconds)
s = 2;
% Frequency (in Hz)
f = 440;
% Time axis
tt = 0:1 / sr:s;

wave = 0;

for k = 1:n
    wave = wave - (2/pi)*cos(k * pi) * sin(2 * pi * f * k * tt)/k;
end


plot(tt, wave)
axis([0 0.0200 -1 1]);

spectrogram(sin(2*pi*440*tt), hamming(length(sin(2*pi*440*tt))/5), [], [], sr, "yaxis");
% spectrogram(wave, hamming(length(wave)/5), [], [], sr, "yaxis");
% sound(sin(2*pi*440*tt)*0.05, sr);
% sound(wave*0.05, sr);
% sound(square(2*pi*440*tt)*0.05, sr)
