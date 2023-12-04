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

% Connect to LEGO NXT via USB
myNXT = legonxt('USB');

% Check if the connection is successful
if isvalid(myNXT)
    disp('Robot connected successfully!');
    
    % Display information about the connected NXT brick
    disp(myNXT);
    
    % Close the connection when done
    close(myNXT);
    disp('Connection closed.');
else
    disp('Failed to connect to the robot. Check your setup and try again.');
end


