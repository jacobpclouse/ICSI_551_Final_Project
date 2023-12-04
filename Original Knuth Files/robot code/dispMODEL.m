% dispMODEL
% dispMODEL
% This function displays the model in the current figure
%
% Usage:
%           dispMODEL(MODEL, PARAMS, pattern);
%           
% Where:
%           MODEL is the MODEL structure
%
% Created: 
%           Kevin Knuth
%           20 Nov 2007

function dispMODEL(MODEL, PARAMS, pattern)

modelTYPE = [MODEL.type];
circTYPE = [PARAMS.CIRC];

if modelTYPE == circTYPE

    % a circle is just a polygon with many sides
    theta = (0:32)/32*2*pi;
    % plot the polygon
    vx = MODEL.XO - MODEL.R*cos(theta);
    vy = MODEL.YO - MODEL.R*sin(theta);

elseif MODEL.type == PARAMS.POLY

    theta = (0:MODEL.N)/MODEL.N*2*pi;
    % plot the polygon
    vx = MODEL.XO - MODEL.R*cos(theta+MODEL.A);
    vy = MODEL.YO - MODEL.R*sin(theta+MODEL.A);

end



plot(vx, vy, pattern)

return