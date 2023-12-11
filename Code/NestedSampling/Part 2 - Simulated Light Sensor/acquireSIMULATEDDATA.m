% acquireSIMULATEDDATA
% Simulate data from the light sensor
%
% Usage:    data = acquireSIMULATEDDATA(nextX, nextY, PARAMS)
%
% Where:
%           nextX, nextY are the coordinates of the measurement location
%           PARAMS  is a structure holding the simulation parameters
% Created by:   Kevin Knuth
%               22 Oct 2008 
% Edited by:    Jacob Clouse
%               11 Dec 2023

function data = acquireSIMULATEDDATA(nextX, nextY, PARAMS)
%hardcode in values for circle center and radius
circleCenter = [0, 0];  % center of circ
circleRadius = 5;   % radius circ

% check to see if on circle edge or inside
distanceToCenter = sqrt((nextX - circleCenter(1))^2 + (nextY - circleCenter(2))^2);

% test
if distanceToCenter < circleRadius
    % for inside circle
    data = 250 + 5 * rand;
else
    % edge of circule
    data = 255/2 + 5 * randn;
end

% crop result to be inside 
data = max(0, min(255, data));

disp(['acquireSIMULATEDDATA return -> ' num2str(data)]);