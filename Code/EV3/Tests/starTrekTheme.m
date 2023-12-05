% Star Trek Theme on LEGO EV3 with MATLAB

clear all; % make sure to remove any pre existing variables before instantiation

myEV3 = legoev3('USB'); % connect usb
notes = [659.26, 680.26, 700.26, 523.25, 659.26, 784.00, 587.33, 680.26];% notes for theme
durations = [0.4, 0.2, 0.1, 0.4, 0.2, 0.1, 0.2, 0.8]; % duration

% loop through and play
for i = 1:length(notes)
    frequency = notes(i);
    duration = durations(i);
    
    myEV3.playTone(frequency, duration * 1.1); % play, extend duration
    pause(duration); % pause
end

clear myEV3; % disconnect / clear
