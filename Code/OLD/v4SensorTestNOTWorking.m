% Bayesian Data Analysis - Final Project
% Fall 2023
% Student: Jacob Clouse
% Instructor:    Dr. Kevin H. Knuth
% Date : 5 Dec 2023

% ----------------------------------------------

% ENTER FUNCTION NAME HERE
% Lego Mindstorm - sensor demo
%
% Usage:
%           function [ output_args ] = Untitled2( input_args )
%           
% Where:
%           input_args  = LIST AND DESCRIBE THEM
%           output_args = LIST AND DESCRIBE THEM
%
% ENTER ANY ADDITIONAL NOTES
%   Need to have the name of the lego brick that you are running
% 
% Created By: 
%           ENTER YOUR NAME
%           ENTER THE DATE
%
% ENTER MODIFICATION INFORMATION HERE

clear all; % make sure to remove any pre existing variables before instantiation
disp('Starting Demo 4: Sensor Test');

% Connect to the EV3 brick
myev3 = legoev3('USB'); % Use 'USB' as the connection type

% make starting beep
myev3.playTone(340,.25,15)
pause(.3)
myev3.playTone(440,.25,15)
pause(.3)
myev3.playTone(540,.25,15)
pause(.3)
writeLCD(myev3,'Demo 4: Sensor Test') % display text on the ev3 display

% ---------------------------------------------------------------------

% Get the list of connected sensors
connectedSensorsList = myev3.ConnectedSensors;

% Display the connected sensors
disp('EV3 Connected Sensors:');
disp(connectedSensorsList);
% this should show that there is a sensor labeled as 'color' connected to the ev3
% but the only one with a name is 'NXT_LIGHT', the others appear to be empty


% Color Sensor documentation: https://www.mathworks.com/help/supportpkg/legomindstormsev3io/ref/readcolor.html
% More Color Sensor documentation: https://www.mathworks.com/help/supportpkg/legomindstormsev3io/ref/colorsensor.html

% create color sensor
mycolorsensor = colorSensor(myev3);

% read / store data from color sensor
color = readColor(mycolorsensor);

% Display the color value
disp('Current Color Value:');
disp(Color);


% I tried to change:
%	mycolorsensor = colorSensor(myev3); to mycolorsensor = colorSensor(myev3,2);  %because the light sensor is on port 2, no dice


% I tried removing mycolorsensor = colorSensor(myev3); altogether and simply changed:
%	color = readColor(mycolorsensor); to color = readColor(NXT_LIGHT); % but this did not work either



% ---------------------------------------------------------------------
% make ending beep
myev3.playTone(540,.25,15)
pause(.3)
myev3.playTone(440,.25,15)
pause(.3)
myev3.playTone(340,.25,15)
pause(.3)

clearLCD(myev3) % clear text from display

% Disconnect EV3
%disconnect(myev3);
clear;