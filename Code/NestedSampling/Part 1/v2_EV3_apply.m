% v2_EV3_apply
% MOSTlY WAS UNTOUCHED

function [Obj, Samples, Try, MODELS, PARAMS] = v2_EV3_apply

    PARAMS.sNOBJS = 100;    % Number of Objects
    PARAMS.sNPOSTS = 50;   % Number of Posterior Samples
    PARAMS.sITERS = 50000;  % Maxmimum number of Iterations
    
    
    % Define problem parameters
    % Reach of the Robot
    PARAMS.Dmin = 20;
    PARAMS.Dmax = 60;
    PARAMS.Amin = 20;
    PARAMS.Amax = 160;
    PARAMS.Drange = PARAMS.Dmax - PARAMS.Dmin;
    PARAMS.Arange = PARAMS.Amax - PARAMS.Amin;
    PARAMS.Zmin = 2;
    PARAMS.Zmax = 4;
    PARAMS.Zrange = PARAMS.Zmax - PARAMS.Zmin;
    
    % Properties of the Light Sensor
    PARAMS.Lmin = 0;
    PARAMS.Lmax = 100;
    PARAMS.Dark = 20;
    PARAMS.Light = 40;
    PARAMS.Sigma = 5;
    
    % Model Types
    PARAMS.CIRC = 1;
    PARAMS.POLY = 2;
    
    % Size of Polygons
    PARAMS.Rmin = 3;
    PARAMS.Rmax = 65;
    PARAMS.Rrange = PARAMS.Rmax - PARAMS.Rmin;
    
    % RECTANGULAR BOUNDARY of playing field
    PARAMS.Xmax = 65;
    PARAMS.Xmin = -65;
    PARAMS.Ymin = 0;
    PARAMS.Ymax = 65;
    
    
    % Define the fieldnames
    % This is all you will have to change if you want to change the structure
    fieldnames = {'MODEL', 'logL', 'logWt'};
    
    % CIRCLE is an array describing a Circle
    % XO     = CIRC(1)
    % YO     = CIRC(2)
    % R      = CIRC(3)
    
    % POLY is an array describing a POLYGON
    % XO     = POLY(1)
    % YO     = POLY(2)
    % R      = POLY(3)   % distance from origin to vertex
    % A      = POLY(4)   % angle goes from 0 to pi/N
    % N      = POLY(5)   % number of sides
    % XV     = POLY(6)   % vertices x-coord
    % XY     = POLY(7)   % vertices y-coord
    
    
    % Circle Parameters
    CIRC.type = PARAMS.CIRC;
    CIRC.names = {'XO', 'YO', 'R'};
    CIRC.max = [130, 130, 65];
    CIRC.min = [-130, -65, 3];
    CIRC.range = CIRC.max - CIRC.min;
    CIRC.u = NaN;
    CIRC.v = NaN;
    CIRC.w = NaN;
    CIRC.steps = [0.1, 0.1, 0.1];
    
    % Polygon Parameters
    POLY.type = PARAMS.POLY;
    POLY.names = {'XO', 'YO', 'R', 'A', 'N', 'XV', 'YV'};
    POLY.max = [NaN, NaN, NaN, NaN, 6, NaN, NaN];
    POLY.min = [NaN, NaN, NaN, NaN, 3, NaN, NaN];
    POLY.range = POLY.max - POLY.min;
    POLY.u = NaN;
    POLY.v = NaN;
    POLY.w = NaN;
    POLY.a = NaN;
    POLY.steps = [0.1, 0.1, 0.1, 0.1];
    
    % set up angles to define vertices
    theta = cell(1,POLY.max(5));
    theta{1} = [NaN];
    theta{2} = [NaN];
    for sides = 3:POLY.max(5)
        theta{sides} = (0:sides)/sides*2*pi;
    end
    
    % Set up MODELS
    MODELS.names = {'CIRC', 'POLY'};
    MODELS.CIRC = CIRC;
    MODELS.POLY = POLY;
    MODELS.POLYSIDESMAX = POLY.max(5);
    MODELS.POLYSIDESMIN = POLY.min(5);
    MODELS.THETA = theta;
    
    
    
    % set up the Objects and Samples
    f = size(fieldnames,2);
    
    cObj = cell([PARAMS.sNOBJS, f]);
    Obj = cell2struct(cObj, fieldnames, 2);
    
    cSamples = cell([PARAMS.sITERS, f]);
    Samples = cell2struct(cSamples, fieldnames, 2);
    
    cTry = cell([1, f]);
    Try = cell2struct(cTry, fieldnames, 2);
    
    return
    