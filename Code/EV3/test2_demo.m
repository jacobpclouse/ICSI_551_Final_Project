% Bayesian Data Analysis - Final Project
% Fall 2023
% Student: Jacob Clouse
% Instructor:    Dr. Kevin H. Knuth
% Date : 19 Nov 2023

% ----------------------------------------------

% ENTER FUNCTION NAME HERE
% Lego Mindstorm - motor demo
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

disp('Starting Demo 2: Motor Test');


% Connect to the EV3 brick - 'BTHUB0'
myLegoEV3 = legoev3('USB'); % Use 'USB' as the connection type
% myLegoEV3 = legoev3('Bluetooth', 'EV3'); % using bluetooth to connect, replace EV3 with the name of your brick
% displayText(myLegoEV3, 'EV3', 'FontSize', 20);

% Move the motor connected to port 'A' for 2 seconds
motorA = motor(myLegoEV3, 'A');
start(motorA, 20);
pause(2);
stop(motorA);

% make beep
playTone(myLegoEV3, 500, 0.5);

% Disconnect EV3
disconnect(myLegoEV3);