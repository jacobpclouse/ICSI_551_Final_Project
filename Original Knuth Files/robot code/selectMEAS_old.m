% selectMEAS determines which measurement should be performed next.
% It queries each of a set of models, and chooses the experiment that gives
% the greatest entropy of the predicted results.
%
% Created by Kevin Knuth
% 23 Nov 2007

function Entropy = selectMEAS(DIMS, Xtest, Ytest, posts, Field, MODELS, PARAMS)

Nx = DIMS(1);
Ny = DIMS(2);

% Amin = PARAMS.Amin;
% %Amax = PARAMS.Amax;
% Dmin = PARAMS.Dmin;
% %Dmax = PARAMS.Dmax;
% Rmin = PARAMS.Rmin;
% %Rmax = PARAMS.Rmax;
% ARange = PARAMS.ARange;
% DRange = PARAMS.DRange;
% RRange = PARAMS.RRange;
% theta = MODELS.THETA;


S = length(posts);

% compute R^2 here instead of in the bigger loop
postsR2 = zeros(S);
for s = 1:S
    MODEL = posts(s).MODEL;
    postsR2(s) = MODEL.R^2;
end

Entropy = zeros(Ny,Nx);
%numPreds = 1;
for tryX = 1:Nx
    for tryY = 1:Ny
        
        XCoord = Xtest(tryY,tryX);
        YCoord = Ytest(tryY,tryX);
        
        if Field(tryY, tryX)
            pred = zeros(1,s);
            for s = 1:S
                MODEL = posts(s).MODEL;
                %             if MODEL.type == PARAMS.CIRC
                % we have a circle
                if ((MODEL.XO-XCoord)^2 + (MODEL.YO-YCoord)^2) <= MODEL.R^2
                    %pred(s,:) = randn(1,numPreds)*PARAMS.Sigma + ones(1,numPreds)*PARAMS.Light;
                    pred(s) = PARAMS.Light;
                else
                    pred(s) = PARAMS.Dark;
                    %pred(s,:) = randn(1,numPreds)*PARAMS.Sigma + ones(1,numPreds)*PARAMS.Dark;
                end
                %             elseif MODEL.type == PARAMS.POLY
                %                 % we have a polygon
                %                     if inpolygon(Xtest(tryY,tryX),Ytest(tryY,tryX),MODEL.XV,MODEL.YV)
                %                         pred(s) = PARAMS.Light;
                %                     else
                %                         pred(s) = PARAMS.Dark;
                %                     end
                %             end
            end

            p = hist(pred,[1:100]); % estimate probabilities of intensity predictions
            p = p/sum(p);   % normalize probabilities
            pp = p(p>0);    % use logical indexing to find p's greater than zero
            Entropy(tryY, tryX) = sum(-pp.*log(pp));
        else
            Entropy(tryY, tryX) = NaN;
        end

    end
end

minENTROPY = min(reshape(Entropy,1,Nx*Ny));
Entropy(find(isnan(Entropy))) = minENTROPY;
return