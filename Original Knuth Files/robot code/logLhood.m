% logLhood
% logLhood computes the log likelihood of the data pair (x,y)
% This function is a matlab implementation of the Lighthouse Problem
% presented in Sivia and Skilling 2006, pp. 192-194.
%
% Usage:
%           logL = logLhood(x, y);
%           
% Where:
%           x is the hypothesized Easterly position of the lighthouse
%           y is the hypothesized Northerly position of the lighthouse
%           logL is the log Likelihood
%
% GNU General Public License software: Copyright Sivia and Skilling 2006
% Originally written in C
% Modified: 
%           Kevin Knuth
%           11 May 2006 
%           Converted to Matlab
% 
%           Kevin Knuth
%           17 Apr 2013
%           changed the convolution line to use the PSF associated with the
%           recorded location DATA.PSF{k} rather than a generic
%           PARAMS.PSFNC

function logL = logLhood(MODEL, PARAMS, DATA)

N = length(DATA.D);

SUMofSQUARES = 0;

% loop through the N data points
for k = 1:N
    % select a patch visible to the sensor at the measurement location
    % corresponding to this data value.
    % In the future, pack this with the DATA
    intFIELD = intensity(MODEL, PARAMS, DATA.DATAX{k}, DATA.DATAY{k});
    convolution = sum(sum(intFIELD .* DATA.PSF{k}));
    PREDICTION = (PARAMS.Light-PARAMS.Dark)*convolution + PARAMS.Dark;
    SUMofSQUARES = SUMofSQUARES + (DATA.D(k)-PREDICTION)^2;
end

%%OLD%%logL = -(N*((0.9189385)+log(PARAMS.Sigma)) + SUMofSQUARES/(2*PARAMS.Sigma*PARAMS.Sigma));
%logL = -N/2*SUMofSQUARES;   % Student-t
logL = -SUMofSQUARES;   % Student-t without the decorations that are not needed with Nested Sampling

return

