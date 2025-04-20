fs = 8000; % Sampling frequency

% Frequencies of the notes (Hz)
G = 392.00;
Eb = 311.13;
F = 349.23;
D = 293.66;

% The sequence of notes in Beethoven's 5th Symphony
notes = [G, G, G, Eb, 0, F, F, F, D]; % 0 represents a silence

melody = []; % Initialize the melody

for i = 1:length(notes)
    duration = 0.2 + (0.5 - 0.2) * rand(); % Random duration between 0.2s - 0.5s
    t = 0:1/fs:duration; % Time vector
    
    if notes(i) == 0 % If it's a silence, generate zeros
        note_sound = zeros(size(t));
    else
        note_sound = 0.5 * sin(2 * pi * notes(i) * t); % Sine wave with amplitude 0.5
    end
    
    melody = [melody, note_sound]; % Append to melody
end

% Play the generated sound
sound(melody, fs);

% Save as WAV file
audiowrite('melody1.wav', melody, fs);
