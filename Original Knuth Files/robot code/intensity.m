% intensity returns the value of a 2-dimensional black and white albedo
% field.  This field is rectangular in shape with one-half white and the
% other half black.
%
% Usage:
%           I = intensity(MODEL, PARAMS, Xs, Ys)
%
% Where:
%           x is a (1,N) vector of x-coordinates
%           y is a (1,N) vector of y-coordinates
%           bx is the boundary location between white and black
%
%
% Created by A.J. Mesiti and Kevin H. Knuth
% Date: 25 Sept 2008
% Modified by Knuth on 17 Oct 2008 - add comments and integrate with rest
% of code
% Modified 17 Apr 2013 - norm changed to unity


function Is = intensity(MODEL, PARAMS, Xs, Ys)

Is = zeros(size(Xs));

% compute normalization factor
% since the array resolution is artificially high and later will be
% downsampled.
sx = Xs(1,2)-Xs(1,1);
sy = Ys(2,1)-Ys(1,1);
norm = 1;


% limit the space to search
indices = find((Xs >= MODEL.XO-MODEL.R)&(Xs <= MODEL.XO+MODEL.R)&(Ys >= MODEL.YO-MODEL.R)&(Ys <= MODEL.YO+MODEL.R));
Xi = Xs(indices);
Yi = Ys(indices);

% Are these points inside the model?
if MODEL.type == PARAMS.CIRC
    for k = 1:length(indices)
        if ((MODEL.XO-Xi(k))^2 + (MODEL.YO-Yi(k))^2) <= MODEL.R^2
            Is(indices(k)) = 1;
        end
    end
    
elseif MODEL.type == PARAMS.POLY
    % we have a polygon
    Is(indices) =  1 * inpolygon(Xi,Yi,MODEL.XV,MODEL.YV);
end

