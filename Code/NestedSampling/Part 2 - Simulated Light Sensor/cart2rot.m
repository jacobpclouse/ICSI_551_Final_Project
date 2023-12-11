% cart2rot
% CART2ROT takes Cartesian coordinates for the end effector of the robotic
% arm and computes the number of rotations to move to that position from
% the robot's HOME.
%
% Usage:    [angleA, angleB, angleC] = cart2rot(XYZ, CAL)
%
% Where:
%           X, Y, Z Coordinates of sensor  
%           rotA    Number of rotations of motor A
%           rotB    Number of rotations of motor B
%           rotC    Number of rotations of motor C
%
% Created by:   Kevin Knuth
%               7 Sept 2007 

function [rotA, rotB, rotC] = cart2rot(X,Y,Z)

% extract robot params
% H = 27;
% a = 40;
% b = 32;
H = 30.5;   % Height of elbow gear from base
a = 34;     % length of arm from wrist to sensor joint
b = 32;     % length of arm from elbow to wrist 
L = 5.5;      % vertical length of light sensor

angA0 = 40;
angB0 = 138;
angC0 = -3;

% adjust Z to account for fact that light sensor extends for 6 units
Z = Z+L;

% distance below elbow gear center
h = H-Z;


% distance
r = sqrt(X*X + Y*Y);
d = sqrt(r*r + h*h);

angC = (invtan(X,Y)*180/pi)-angC0;

alpha = acos((a^2 + b^2 - d^2)/(2*a*b));
angA = alpha*180/pi - angA0;

betaPP = asin(r/d);
betaP = asin(a*sin(alpha)/d);
beta = betaP + betaPP;
angB = angB0 - beta*180/pi;


rotC = round((angC/3)*360);
rotB = round((angB/3)*360);
rotA = round((angA/9)*360);

return
