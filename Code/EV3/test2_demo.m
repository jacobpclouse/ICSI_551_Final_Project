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

clear all; % make sure to remove any pre existing variables before instantiation
disp('Starting Demo 2: Motor Test');

% Connect to the EV3 brick
myev3 = legoev3('USB'); % Use 'USB' as the connection type
% myev3 = legoev3('Bluetooth', 'EV3'); % using bluetooth to connect -- could not get to connect

% make starting beep
playTone(myev3, 500, 0.5);
writeLCD(myev3,'Demo 2: Motor Test') % display text on the ev3 display


% Move the motor connected to port 'A' for 2 seconds
%motorA = motor(myev3, 'A');
%start(motorA, 20);
%pause(2);
%stop(motorA);

% make ending beep
playTone(myev3, 600, .5);
%clearLCD(myev3) % clear text from display

% Disconnect EV3
%disconnect(myev3);