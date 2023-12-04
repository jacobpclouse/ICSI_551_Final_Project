% acquireDATA
% acquireDATA commands the robot to measure the light intensity at the 
% coordinates (nextX, nextY)
%
% Usage:    data = acquireDATA(nextX, nextY, lego, PARAMS, STATE)
%
% Where:
%           nextX, nextY are the coordinates of the measurment location
%           lego    is a structure enabling access to the robot
%           PARAMS  is a structure holding the robot parameters
%
% Created by:   Kevin Knuth
%               22 Oct 2008 

function [data STATE] = acquireDATA(nextX, nextY, lego, PARAMS, STATE)

START = STATE.start;
currentROTC = STATE.rotc;
moveFILE = STATE.movefile;
homeFILE = STATE.homefile;

% adjust the height of the arm based on the reach
dist = sqrt(nextX^2 + nextY^2);
nextZ = PARAMS.Zrange*((dist-PARAMS.Dmin)/PARAMS.Drange)+PARAMS.Zmin;

% convert to motor rotations
[rotA, rotB, rotC] = cart2rot(nextX,nextY,nextZ);
deltaROTC = rotC - currentROTC;
disp(['X = ' num2str(nextX) '  Y = ' num2str(nextY) '  Z = ' num2str(nextZ)]);
disp([num2str(deltaROTC) '  ' num2str(rotB) '  ' num2str(rotA)])
currentROTC = rotC;
dirC = deltaROTC>0;  % dirC = 1 if to CCW (from above) or 0 if CW

% encode into message to robot
ending = char([13 10]);
message = double([num2str(dirC) ending num2str(abs(deltaROTC)) ending num2str(rotB) ending num2str(rotA) ending ]);


% wait until ready if we are in progress
if ~START
    waiting = 1;
    while waiting
        pause(1);   % wait 1 second
        if lego.doesFileExist('ready.txt')
            waiting = 0;
        end
        disp('robot not ready')
    end
end

% send message
success = 0;
while success == 0
    lego.deleteFile('pos.txt');
    disp('Deleted pos.txt');
    lego.deleteFile('meas.txt');
    disp('Deleted meas.txt');
    lego.deleteFile('ready.txt');
    disp('Deleted ready.txt');
    result = lego.writeFile('pos.txt', message);
    if result < 0
        disp('Problem sending message')
    else
        success = 1;
    end
end

% initiate robot
lego.startProgram(moveFILE);
disp('Robot Commanded to Move');

% wait for response
waiting = 1;
while waiting
    pause(1);   % wait 1 second
    if lego.doesFileExist('meas.txt')
        waiting = 0;
    end
    disp('waiting')
end
disp('Results ready...')
success = 0;
while success == 0
    pause(1);   % wait 1 second
    result = lego.readFile('meas.txt');
    string = char(result(1:end-2)');
    if length(string) == 0
        disp('Try reading result again')
    else
        success = 1;
        disp('got it!')
    end
end
data = eval(string);
disp(['Intensity = ' num2str(data)]);


STATE.rotc = currentROTC;

return
