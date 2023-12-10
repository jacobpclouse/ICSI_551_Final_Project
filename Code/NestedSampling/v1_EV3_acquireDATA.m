% v1_EV3_acquireDATA commands the robot to measure the light intensity at the
% coordinates (nextX, nextY) using LEGO Mindstorms EV3 with MATLAB.
%
% Usage:    [data, STATE] = v1_EV3_acquireDATA(nextX, nextY, ev3, PARAMS, STATE)
%
% Where:
%           nextX, nextY are the coordinates of the measurement location
%           ev3     is the LEGO Mindstorms EV3 object
%           PARAMS  is a structure holding the robot parameters
%           STATE   is a structure holding the current state of the system
%
% Created by:   Kevin Knuth
%               22 Oct 2008
%
% Edited by:    Jacob Clouse
%               10 Dec 2023

function [data, STATE] = v1_EV3_acquireDATA(nextX, nextY, ev3, PARAMS, STATE)

% start up, clear and show that things are starting
clear all; % make sure to remove any pre existing variables before instantiation
disp('Starting v1_EV3_acquireDATA...'); % console display, not ev3 display

% connect to the EV3 brick
myev3 = legoev3('USB'); % Use 'USB' as the connection type

% make starting beep
myev3.playTone(340,.25,15)
pause(.3)
myev3.playTone(440,.25,15)
pause(.3)
myev3.playTone(540,.25,15)
pause(.3)

writeLCD(myev3,'v1_EV3_acquireDATA') % display text on the ev3 display

% ---------------------------------------------------------------------

% Display the connected sensors
disp('EV3 Connected Sensors:');
disp(connectedSensorsList);
% this should show that there is a sensor labeled as 'color' connected to the ev3
% but the only one with a name is 'NXT_LIGHT', the others appear to be empty


% Color Sensor documentation: https://www.mathworks.com/help/supportpkg/legomindstormsev3io/ref/readcolor.html
% More Color Sensor documentation: https://www.mathworks.com/help/supportpkg/legomindstormsev3io/ref/colorsensor.html


% grab attributes from state
START = STATE.start;
currentROTC = STATE.rotc;
moveFILE = STATE.movefile;
%homeFILE = STATE.homefile;

% until the while loop, i tried to make minimal changes to the logic and use of functions

% adjust the height of the arm based on the reach
dist = sqrt(nextX^2 + nextY^2);
nextZ = PARAMS.Zrange * ((dist - PARAMS.Dmin) / PARAMS.Drange) + PARAMS.Zmin;

% convert to motor rotations -- keeping original functions
[rotA, rotB, rotC] = cart2rot(nextX, nextY, nextZ);
deltaROTC = rotC - currentROTC;
disp(['X = ' num2str(nextX) '  Y = ' num2str(nextY) '  Z = ' num2str(nextZ)]);
disp([num2str(deltaROTC) '  ' num2str(rotB) '  ' num2str(rotA)])
currentROTC = rotC;
dirC = deltaROTC > 0;  % dirC = 1 if to CCW (from above) or 0 if CW

% encode into message to robot
ending = char([13 10]);
message = double([num2str(dirC) ending num2str(abs(deltaROTC)) ending num2str(rotB) ending num2str(rotA) ending]);

% # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
% wait until ready if we are in progress -- add in new EV3 commands
% # =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
if ~START
    waiting = 1;
    while waiting
        pause(1);  % wait 1 second
        if exist(ev3, 'ready.txt', 'file') % see if the file exits
            disp('Robot is ready!') % console
            writeLCD(myev3,'Robot is ready!') % ev3 display
            waiting = 0; % exit waiting
        end
        disp('WAITING: robot not ready...') % console
        writeLCD(myev3,'WAITING: robot not ready...') % ev3 display
    end
end

% send message, keep trying with while loop
success = 0;
while success == 0
    delete(ev3, 'pos.txt');
    disp('Deleted pos.txt');
    delete(ev3, 'meas.txt');
    disp('Deleted meas.txt');
    delete(ev3, 'ready.txt');
    disp('Deleted ready.txt');
    result = writematrix(ev3, message, 'pos.txt');
    if result < 0
        disp('ERROR: Problem sending message!')
    else
        success = 1;
    end
end

% initiate robot
startProgram(ev3, moveFILE);
disp('Robot Commanded to Move');
writeLCD(myev3,'Robot Commanded to Move')

% wait for response
waiting = 1;
while waiting
    pause(1);  % wait 1 second
    if exist(ev3, 'meas.txt', 'file')
        disp('Command Response Recieved!') % console 
        writeLCD(myev3,'Command Response Recieved!') % ev3 display
        waiting = 0;
    end
    disp('WAITING: command response...') % console 
    writeLCD(myev3,'WAITING: command response...') % ev3 display
end

% show results
disp('Results ready...')
success = 0;
while success == 0
    pause(1);  % wait 1 second
    result = readmatrix(ev3, 'meas.txt');
    string = char(result(1:end-2)');
    if length(string) == 0
        disp('ERROR: Try reading result again, result is empty')
    else
        success = 1;
        disp('Results Obtained! :D')
    end
end
data = eval(string);
numToStringData = num2str(data)
%disp(['Intensity = ' num2str(data)]); % might need to bring back
disp(['Intensity = ' numToStringData]);
writeLCD(myev3,['Intensity = ' numToStringData]) % ev3 display to show results

STATE.rotc = currentROTC;

return
