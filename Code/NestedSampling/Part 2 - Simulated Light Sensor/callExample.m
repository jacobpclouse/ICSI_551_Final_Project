% callExample.m
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
nextX = 3; % x coord
nextY = 4; % y coord

% param. for simulation
PARAMS.Zrange = 10;
PARAMS.Dmin = 1;
PARAMS.Drange = 20;
PARAMS.Zmin = 5;

% acquireSIMULATEDDATA function
data = acquireSIMULATEDDATA(nextX, nextY, PARAMS);
% print out
disp(['Sim. data out for X: ' num2str(nextX) ', Y: ' num2str(nextY) ';']);
disp(['Sim. Intensity: ' num2str(data)]);
