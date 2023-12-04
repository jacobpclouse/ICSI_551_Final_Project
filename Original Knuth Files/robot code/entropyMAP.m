% entropyMAP
% entropyMAP generates an entropy map from the entropy estimates.  This map
% is decorated with posterior samples, the past data values, and the
% current estimate
%
% Usage:    [nextX, nextY] = entropyMAP(entropy, posts, nextX, nextY, DATA, Xtest, Ytest, Field, PARAMS)
%
% Where:
%           entropy is a map of entropy values
%           posts   is a structure containing the posterior samples
%           nextX, nextY are the coordinates of the next measurement
%           Data    is a structure containing the data values
%           Field   is a matrix describing the robot's reach
%           PARAMS  is a structure of problem parameters
%
%           nextX, nextY are the coordinates of the next measurement point
%
% Created by:   Kevin Knuth
%               22 Oct 2008 

function [nextX, nextY] = entropyMAP(entropy, posts, nextX, nextY, DATA, Xtest, Ytest, Field, PARAMS)

    N = length(DATA.D);
    
    Xmax = PARAMS.Xmax;
    Xmin = PARAMS.Xmin;
    Ymin = PARAMS.Ymin;
    Ymax = PARAMS.Ymax;

    entMAX = max(max(entropy));
    entMIN = min(min(entropy));
    myMAP = 64*(entropy - entMIN)/(entMAX-entMIN);
    
    % OLD CODE that finds the first point with maximum entropy
    % weight it by the playing field
%     [maxval, index] = max(reshape(myMAP.*Field,1,numel(myMAP)));
%     nextX = Xtest(index);
%     nextY = Ytest(index);
    
    % NEW CODE that randomizes the selected point from a set of maximum
    % entropy locations
    index1 = find(myMAP==max(max(myMAP)));
    value = (length(index1));
    entindex = ceil(rand*value);
    index = index1(entindex);
	nextX = Xtest(index);
    nextY = Ytest(index);
    
%     figure('Name','The Robot''s Thoughts','Position',scrsz);
%     hold on;
%     axis xy;
%     axis equal;
%     axis([Xmin Xmax Ymin Ymax]);
    
    image(Xmin:Xmax, Ymin:Ymax, myMAP)
    colormap(copper)


    % Overlay sample posterior objects
    S = length(posts);
    for s = 1:S
        dispMODEL(posts(s).MODEL, PARAMS, 'b');
    end
    
    % With model selection, the mean is meaningless
    % plot mean circle in red
%     MEANCIRC = MODELS.CIRC;
%     MEANCIRC.XO = xo;
%     MEANCIRC.YO = yo;
%     MEANCIRC.R = ro;
%     dispMODEL(MEANCIRC, PARAMS, 'r');

    
    % plot old measurements
    for i = 1:N
        if DATA.D(i) < (PARAMS.Dark+PARAMS.Light)/2
            plot(DATA.X(i), DATA.Y(i),'s','MarkerEdgeColor','w',...
                'MarkerFaceColor','k',...
                'MarkerSize',5);
        else
            plot(DATA.X(i), DATA.Y(i),'s','MarkerEdgeColor','k',...
                'MarkerFaceColor','w',...
                'MarkerSize',5);
        end
    end
    
    
    % plot next measurement
    plot(nextX, nextY,'s','MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',5);
            
    
    
    % SAVE PLOT OF CIRCLES
%     plotnum = plotnum + 1;

    % SAVE PLOT OF entropy
    % dirname = 'C:\kevin\papers\me07\knuth+erner-me07\pics\';
    % plotname = [dirname 'entropy-' num2str(plotnum) '.tif'];
    % print(gcf, plotname, '-dtiff');

return
