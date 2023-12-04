% Explore
% Explore evolves the object within the likelihood constraint
%
% This function is a matlab implementation of the Lighthouse Problem
% presented in Sivia and Skilling 2006, pp. 192-194.
%
% Usage:
%           Obj = explore(Obj,Try,logLstar)
%
% Where:
%           Obj is the object being set using the Matlab structure array
%           Try is the attempt
%           logLstar is the likelihood constraint
%
% GNU General Public License software: Copyright Sivia and Skilling 2006
% Originally written in C
% Modified: Phil Erner
%           10 Dec.2006
% Modified: Kevin Knuth
%           4 Nov 2006, 5 Nov 2006


function [Try numACCEPTS, updated] = explore(Object, Try, logLstar, MODELS, PARAMS, INFENG, DATA)

% Identify the Bounding Box for the partial annulus that defines the arena
Amin = PARAMS.Amin;
%Amax = PARAMS.Amax;
Dmin = PARAMS.Dmin;
%Dmax = PARAMS.Dmax;
Rmin = PARAMS.Rmin;
%Rmax = PARAMS.Rmax;
Arange = PARAMS.Arange;
Drange = PARAMS.Drange;
Rrange = PARAMS.Rrange;
theta = MODELS.THETA;


M = INFENG.numSTEPS; % MCMC counter (pre-judged # steps)
numACCEPTS = 0; % count the number of accepts

MODEL = Object.MODEL;

% Set up step structure
steps = MODEL.steps;        % this sets each step size to 0.1
accepts = zeros(size(steps)); % # MCMC acceptances
rejects = zeros(size(steps)); % # MCMC rejections

sides = MODELS.POLYSIDESMIN:MODELS.POLYSIDESMAX;
p = sum(sides);
s(1) = 0;
for i = 1:length(sides)
    s(i+1) = sum(sides(1:i));
end

updated = 0;    % flag to denote whether sample was updated
for i = 1:M
    
    % Change model type?
    %if rand < 0   % change half of the time  
    if false    % DONT CHANGE MODEL TYPE!!!!!
        
        parameter = 0;  % we are changing the model... not the parameters
        
        % change to polygon or circle?
        if rand > 1.0/(MODELS.POLYSIDESMAX+1)

%              disp('Changing to POLY')
            
            % favor larger numbers of sides 
            % since we are coming from a circle
            POLY = MODELS.POLY;
            POLY.N  = find(s<rand*18, 1, 'last')-1+MODELS.POLYSIDESMIN;
        
            
            % inherit params from the circle
            POLY.u = MODEL.u;
            POLY.v = MODEL.v;
            POLY.w = MODEL.w;
            POLY.a = rand;
            POLY.XO = MODEL.XO;
            POLY.YO = MODEL.YO;
            POLY.R  = MODEL.R;
            POLY.A  = POLY.a*pi/POLY.N;
    
            % rotate the polygon a random amount
            POLY.XV = MODEL.XO - MODEL.R*cos(theta{POLY.N}+POLY.A);
            POLY.YV = MODEL.YO - MODEL.R*sin(theta{POLY.N}+POLY.A);
            
            % Assign the Trial Object
%             POLY
            tryMODEL = POLY;
            
            % Reassign step size structure
            steps = POLY.steps;
            
        else	% changing to circle
            
%              disp('Changing to CIRC')
            
            CIRC = MODELS.CIRC;
        
            % inherit params from the polygon
            CIRC.u = MODEL.u;
            CIRC.v = MODEL.v;
            CIRC.w = MODEL.w;
            CIRC.XO = MODEL.XO;
            CIRC.YO = MODEL.YO;
            CIRC.R  = MODEL.R;
            
            % Assign the Trial Object
%             CIRC
            tryMODEL = CIRC;
            
            % Reassign step size structure
            steps = CIRC.steps;
            
        end

        % set up new step accept/reject struture
        accepts = zeros(size(steps)); % # MCMC acceptances
        rejects = zeros(size(steps)); % # MCMC rejections
        
    else    % vary the model parameters
        
        if MODEL.type == PARAMS.CIRC
            
            CIRC = MODEL;
            
            parameter = floor((length(steps))*rand)+1;
%             disp(['CIRC changing' num2str(parameter)])
            
            if parameter < 3    % change center position
                if parameter == 1
                    CIRC.u = CIRC.u + steps(1) * (2*rand - 1);
                    CIRC.u = CIRC.u-floor(CIRC.u);       % wraparound
                else
                    CIRC.v = CIRC.v + steps(2) * (2*rand - 1);
                    CIRC.v = CIRC.v-floor(CIRC.v);
                end
                angle = Arange * CIRC.u + Amin; % map to angle
                dist  = Drange * CIRC.v + Dmin; % map to dist
                CIRC.XO = dist*cos(angle*0.017453); % map to x
                CIRC.YO = dist*sin(angle*0.017453); % map to y
            else
                CIRC.w = CIRC.w + steps(3) * (2*rand - 1);
                CIRC.w = CIRC.w-floor(CIRC.w);
                CIRC.R = Rrange * CIRC.w + Rmin; % map to radius;
            end

            % Assign the Trial Object
%             CIRC
            tryMODEL = CIRC;
            
        else % if POLY
            
%              disp('POLY changing')
            
            POLY = MODEL;
            
            parameter = floor((length(steps))*rand)+1;

            if parameter < 3    % change center position
                if parameter == 1
                    POLY.u = POLY.u + steps(1) * (2*rand - 1);
                    POLY.u = POLY.u-floor(POLY.u);       % wraparound
                else
                    POLY.v = POLY.v + steps(2) * (2*rand - 1);
                    POLY.v = POLY.v-floor(POLY.v);
                end
                angle = Arange * POLY.u + Amin; % map to angle
                dist  = Drange * POLY.v + Dmin; % map to dist
                POLY.XO = dist*cos(angle*0.017453); % map to x
                POLY.YO = dist*sin(angle*0.017453); % map to y
            else
                if parameter == 3   % change size
                    POLY.w = POLY.w + steps(3) * (2*rand - 1);
                    POLY.w = POLY.w-floor(POLY.w);
                    POLY.R = Rrange * POLY.w + Rmin; % map to radius;
                else    % rotate it
                    POLY.a = POLY.a + steps(4) * (2*rand - 1);
                    POLY.a = POLY.a-floor(POLY.a);
                    POLY.A = Arange * POLY.a + Amin;
                end
            end
            
            POLY.XV = POLY.XO - POLY.R*cos(theta{POLY.N}+POLY.A);
            POLY.YV = POLY.YO - POLY.R*sin(theta{POLY.N}+POLY.A);
            
            % Assign the Trial Object
%             POLY
            tryMODEL = POLY;
        end
    end

%     tryMODEL
    % compute the likelihood
    logL = logLhood(tryMODEL, PARAMS, DATA); % trial likelihood value


    % Accept if and only if within hard likelihood constraint
    if logL >= logLstar
        updated = 1;
        MODEL = tryMODEL;
        modLOGL = logL;
        numACCEPTS = numACCEPTS + 1;
        if parameter    % keep track of accepts for step size changes
            accepts(parameter) = accepts(parameter) + 1;
%                disp('ACCEPTED!')
        end
    else
        if parameter
            rejects(parameter) = rejects(parameter) + 1;
%                disp('REJECTED!')
        end
    end
    
    % Refine step-size to let acceptance ratio converge around 50%
    if parameter
        if accepts(parameter) > rejects(parameter)
            steps(parameter) = steps(parameter) * exp(1.0 / accepts(parameter));
        else
            if accepts(parameter) < rejects(parameter)
                steps(parameter) = steps(parameter) / exp(1.0 / rejects(parameter));
            end
        end
    end
end


% of not updated, return the original object
MODEL.steps = steps;    % update step size
if updated == 1
    Try.MODEL = MODEL;
    Try.logL = modLOGL;
%     disp(['logLstar = ' num2str(logLstar)]);
%     disp(['Result at : LogL = ' num2str(modLOGL)]); 
else
    MODEL.steps = steps;    % update step size
    Try = Object;
end

return