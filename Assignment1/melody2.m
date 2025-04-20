fs = 8000; % Sampling frequency
num_notes = 9; % Number of random notes

melody = []; % Initialize the melody

for i = 1:num_notes
    freq = 200 + (1000 - 200) * rand(); % Random frequency between 200 Hz - 1000 Hz
    duration = 0.2 + (0.5 - 0.2) * rand(); % Random duration between 0.2s - 0.5s
    amplitude = 0.2 + (1 - 0.2) * rand(); % Random amplitude between 0.2 - 1

    t = 0:1/fs:duration; % Time vector
    note_sound = amplitude * sin(2 * pi * freq * t); % Generate sine wave
    
    melody = [melody, note_sound]; % Append to melody
end

% Play the generated sound
sound(melody, fs);

% Save as WAV file
audiowrite('melody2.wav', melody, fs);
