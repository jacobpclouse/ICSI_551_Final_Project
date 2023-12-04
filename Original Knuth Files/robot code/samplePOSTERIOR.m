% samplePOSTERIOR
% samplePOSTERIOR uses nested sampling to sample from the posterior
%
% Usage:    posts = samplePOSTERIOR(Obj, Samples, Try, DATA, MODELS, PARAMS)
%
% Where:
%           DATA     is a structure containing the data values
%           MODELS   is a matrix describing the robot's shape models
%           PARAMS   is a structure of problem parameters
%
% Created by:   Kevin Knuth
%               22 Oct 2008 

function posts = samplePOSTERIOR(Obj, Samples, Try, DATA, MODELS, PARAMS)

n = PARAMS.sNOBJS;      % Number of Objects
S = PARAMS.sNPOSTS;     % Number of Posterior Samples

% Set Inference Engine Parameters and Diagnostics
INFENG.numSTEPS = 10;
numACCEPTS = zeros(1,1000);
avgACCEPTS = zeros(1,1000);
expSTEPS = zeros(1,1000);

H = 0.0; % Information, initially 0
logZ =-realmax;% ln(Evidence Z, initially 0)

% Set prior objects
for i = 1:n
    Obj(i) = Prior(Obj(i), MODELS, PARAMS, DATA);
end

% Outermost interval of prior mass
logwidth = log(1.0 - exp(-1.0 / n));


% NESTED SAMPLING LOOP
nest = 0;
nestGO = true;

while nestGO
    %for nest = 1:MAX;
    nest = nest+1;

    % Worst object in collection, with Weight = width * Likelihood
    worst = 1;
    for i = 2:n;
        if Obj(i).logL < Obj(worst).logL
            worst = i;
        end
    end
    %    disp(worst)
    Obj(worst).logWt = logwidth + Obj(worst).logL;
    % Update Evidence Z and Information H
    if logZ > Obj(worst).logWt
        logZnew = logZ + log(1 + exp(Obj(worst).logWt-logZ));
    else
        logZnew = Obj(worst).logWt + log(1 + exp(logZ+(-Obj(worst).logWt)));
    end
    H = exp(Obj(worst).logWt - logZnew) * Obj(worst).logL + exp(logZ - logZnew) * (H + logZ) - logZnew;

    % Stopping condition
    if (logZnew - logZ) < 10^-4
        nestGO = false;
%    else
%        disp(logZnew-logZ)
    end
    if nest == PARAMS.sITERS
        nestGO = false;
    end
    
    
    % store logWt for plotting and diagnostics
    if PARAMS.diagnostics
        LOGWT(nest) = Obj(worst).logWt;
        LOGZDIFF(nest) = logZnew - logZ;
        
        if rem(nest,100) == 0
            disp(['Iteration = ' num2str(nest)]);
        end
    end
    
    
    % update logZ
    logZ = logZnew;


    % Posterior Samples (optional)
    Samples(nest) = Obj(worst);
    
    updated = 0;
    while (~updated)
        % Kill worst object in favour of copy of different survivor
        copy = ceil(n * rand()); % choose an object between 1 and n
        while ((copy == worst) && n>1) % if worst and not lone object chosen,
            copy = ceil(n * rand());   % choose another object
        end
        logLstar = Obj(worst).logL; % new likelihood constraint
        
        Obj(worst) = Obj(copy); % overwrite worst object
        % Evolve copied object within constraint
        [Obj(worst) numACCEPTS(nest), updated] = explore(Obj(worst), Try, logLstar, MODELS, PARAMS, INFENG, DATA);
        
        if (~updated)
            disp('sample not updated... try again');
        end
    end


    % Monitor Inference Engine Performance
    if nest > 10
        avgACCEPTS(nest) = sum(numACCEPTS(nest-9:nest))/10;

        % if there are too few accepts, then bump up the number of trials
        % if there are too many accepts, then cut the number of trials in half
        if avgACCEPTS(nest) < 5
            INFENG.numSTEPS = min([40, ceil(4/3* INFENG.numSTEPS)]);
            disp(['Increased INF ENG steps to: ' num2str(INFENG.numSTEPS)]);
        else
            if avgACCEPTS(nest) > 10
                INFENG.numSTEPS = max([10, ceil(INFENG.numSTEPS * 4/5)]);
                disp(['Decreased INF ENG steps to: ' num2str(INFENG.numSTEPS)]);
            end
        end
        
        expSTEPS(nest) = INFENG.numSTEPS;

    end


    
    % Shrink interval
    logwidth = logwidth - 1/n;
end % NESTED SAMPLING LOOP (might be ok to terminate early)

% Some Diagnostic Data here
if PARAMS.diagnostics
    disp(['Number of nested sampling iterations = ' num2str(nest)]);
    fig = gcf;
    
    % Plot log Weight for diagnostic purposes
    figure;
    plot(exp(LOGWT(100:end) - logZ),'b');
    title('LogWt as a function of Iteration');
    
    % Plot changes in logZ for diagnostic purposes
    figure;
    plot(log(LOGZDIFF(100:end)),'r');
    title('Delta Log Z as a function of Iteration');
    
    % Plot number of explore accepts for diagnostic purposes
    figure;
    plot(numACCEPTS(100:end),'r');
    title('Number of Explore Accepts as a function of Iteration');
        
    % Plot running average of explore accepts for diagnostic purposes
    figure;
    plot(avgACCEPTS(100:end),'r');
    title('Running Average of Explore Accepts as a function of Iteration');
    
    % Plot number of explore steps for diagnostic purposes
    figure;
    plot(expSTEPS(100:end),'r');
    title('Number of Explore Steps as a function of Iteration');
    
    figure(fig);
end




% Select S samples
posts = postSAMPLER(S, Samples, logZ);


        % diversify the samples with MCMC
        for s = 1:S
            for i = 1:100
                TryMODEL = posts(s).MODEL;

                % explore a bit
                TryMODEL.u = TryMODEL.u + 0.01*randn;
                while TryMODEL.u < 0 || TryMODEL.u > 1
                    TryMODEL.u = TryMODEL.u + 0.01*randn;
                end
                TryMODEL.v = TryMODEL.v + 0.01*randn;
                while TryMODEL.v < 0 || TryMODEL.v > 1
                    TryMODEL.v = TryMODEL.v + 0.01*randn;
                end
                TryMODEL.w = TryMODEL.w + 0.01*randn;
                while TryMODEL.w < 0 || TryMODEL.w > 1
                    TryMODEL.w = TryMODEL.w + 0.01*randn;
                end

                angle = (PARAMS.Arange * TryMODEL.u + PARAMS.Amin)*0.017453; % map to angle in radians
                dist  = PARAMS.Drange * TryMODEL.v + PARAMS.Dmin; % map to dist
                TryMODEL.XO = dist*cos(angle); % map to x
                TryMODEL.YO = dist*sin(angle); % map to y
                TryMODEL.R = PARAMS.Rrange * TryMODEL.w + PARAMS.Rmin; % map to radius;

                logL = logLhood(TryMODEL, PARAMS, DATA);
                accept = 0;
                if (log(rand) <= min([0, logL-posts(s).logL]))
                    accept = 1;
                    posts(s).MODEL = TryMODEL;
                end
            end
        end


return
