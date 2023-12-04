% Prior
% Prior sets an object according to the prior
% This function is a matlab implementation of the Lighthouse Problem
% presented in Sivia and Skilling 2006, pp. 192-194.
%
% Usage:
%           Obj = Prior(Obj);
%           
% Where:
%           Obj is the object being set
%               using the Matlab structure array defined by struct
%
% GNU General Public License software: Copyright Sivia and Skilling 2006
% Originally written in C
% Modified: 
%           Kevin Knuth
%           08 June 2006 
%           Converted to Matlab

function Object = Prior(Object, MODELS, PARAMS, DATA)

% Identify the Bounding Box for the partial annulus that defines the arena
Amin = PARAMS.Amin;
Amax = PARAMS.Amax;
Dmin = PARAMS.Dmin;
Dmax = PARAMS.Dmax;
Rmax = PARAMS.Rmax;
Rmin = PARAMS.Rmin;


% choose model type
nTYPES = length(MODELS.names);
TYPE = ceil(rand*nTYPES);

TYPE = 1;   % ALWAYS MAKE CIRCLES

if  TYPE == 1    % Circle
        
    CIRC = MODELS.CIRC;
        
    CIRC.u = rand;
    CIRC.v = rand;
    CIRC.w = rand;

    angle = (Amax-Amin) * CIRC.u + Amin; % map to angle
    dist  = (Dmax-Dmin) * CIRC.v + Dmin; % map to dist

    CIRC.XO = dist*cos(angle*0.017453); % map to x
    CIRC.YO = dist*sin(angle*0.017453); % map to y
    CIRC.R  = Rmax * CIRC.w + Rmin;

    Object.MODEL = CIRC;
    
elseif TYPE == 2    % Polygon
    
    POLY = MODELS.POLY;
        
    POLY.u = rand;
    POLY.v = rand;
    POLY.w = rand;
    POLY.a = rand;

    angle = (Amax-Amin) * POLY.u + Amin; % map to angle
    dist  = (Dmax-Dmin) * POLY.v + Dmin; % map to dist

    POLY.XO = dist*cos(angle*0.017453); % map to x
    POLY.YO = dist*sin(angle*0.017453); % map to y
    POLY.R  = Rmax * POLY.w + Rmin;
    POLY.N  = floor((POLY.range(5)+1)*rand)+POLY.min(5);
    POLY.A  = POLY.a*pi/POLY.N;
    
    theta = (0:POLY.N)/POLY.N*2*pi;
    POLY.XV = POLY.XO - POLY.R*cos(theta+POLY.A);
    POLY.YV = POLY.YO - POLY.R*sin(theta+POLY.A);

    Object.MODEL = POLY;
end


Object.logL = logLhood(Object.MODEL, PARAMS, DATA);


return