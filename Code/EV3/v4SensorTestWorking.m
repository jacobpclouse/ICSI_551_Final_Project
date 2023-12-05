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


% Move the motor connected to port 'B' for 2 seconds
motorSelected = motor(myev3, 'B');
start(motorSelected, 30);
pause(2);
stop(motorSelected);

% Reverse the motor same way
start(motorSelected, -30);
pause(2);
stop(motorSelected);



% *1. Plug a motor into port #C on the EV3 brick, and create a handle for it.*
mymotor = motor(myev3,'C')

% *2. Set the motor speed by assigning a value to the |Speed| property.*
mymotor.Speed = 30

% *3. Start the motor.*
start(mymotor)
pause(2);

% *4. Change the motor speed and reverse its direction.*
mymotor.Speed = -30
start(mymotor)
pause(2);

% *5. Stop the motor.*
stop(mymotor)


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