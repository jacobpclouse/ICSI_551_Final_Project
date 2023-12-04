% Bayesian Data Analysis - Final Project
% Fall 2023
% Student: Jacob Clouse
% Instructor:    Dr. Kevin H. Knuth
% Date : 19 Nov 2023

% ----------------------------------------------

% ENTER FUNCTION NAME HERE
% Lego Mindstorm - beep demo
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
%           Jacob Clouse - (BASED OFF OF THIS SOURCE: https://youtu.be/rp3ChAZi1Aw)
%           19 Nov 2023
%
% ENTER MODIFICATION INFORMATION HERE

disp('Starting Demo 1: Beep Test');

% Connect to the EV3 brick - usb
myLegoEV3 = legoev3('USB');  % Use 'USB' as the connection type


% make 3 beeps
myLegoEV3.playTone(440,.25,15)
pause(.3)
myLegoEV3.playTone(440,.25,15)
pause(.3)
myLegoEV3.playTone(440,.25,15)
pause(.3)

% assigning data sensor and motors
sonic = sonicsensor(myLegoEV3);
touch = touchsensor(myLegoEV3);
infared = irsensor(myLegoEV3);
gyro = gyrosensor(myLegoEV3);

leftMotor = motor(myLegoEV3, 'B');
rightMotor = motor(myLegoEV3, 'C');

% Disconnect EV3 
disconnect(myLegoEV3);
