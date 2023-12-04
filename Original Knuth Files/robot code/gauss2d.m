% gauss2d returns the value of a 2-dimensional symmetric Gaussian
% with standard deviation s.  It can accomodate an array of (x,y)
% coordinates.
%
% Usage:
%           g = gauss2d(x, x0, y, y0, sigma);
%
% Where:
%           x is a (1,N) vector of x-coordinates
%           y is a (1,N) vector of y-coordinates
%           x0 is a (1,N) vector of x-coordinates
%           y0 is a (1,N) vector of y-coordinates
%           sigma is the standard deviation in both the x and y coords.
%
%
% Created by A.J. Mesiti and Kevin H. Knuth
% Date: 25 Sept 2008
% Modified by Knuth on 17 Oct 2008 - add comments and integrate with rest
% of code


function g = gauss2d(x,x0,y,y0,sigma)
% models a 2d pdf

g = (1/(sqrt(2*pi)*sigma))^2 * exp((-1/(2*(sigma^2)))*((x-x0).^2 + (y-y0).^2));
