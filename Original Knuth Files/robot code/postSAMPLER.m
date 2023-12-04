%postSAMPLER.m draws samples from the posterior distribution
%according to the relative weights (w_m = A_m/Z) of each object (Sivia and Skilling, 2006, pp.196). 
%This corresponds to sampling from a discrete probability mass function having these
%weights.
%
%Usage:
%
%       [posts,i] = posterior_sampler(M,Samples,logZ)
%
%where
%
%       Samples is the array of discarded samples that we draw from
%       M is the number of samples that we want to draw
%       logZ is the log normalization, which is log(sum(logWts)) (Wt_m = A_m)
%       posts are the sampled posteriors
%       i is the array showing how many times each object is replicated or
%       killed (i(m) = 0 where m = 1,2,...,N )
%       N = length of discarded Samples object in the nested sampling
%
%Kevin Knuth and Deniz Gencaga, November, 2007.


function [posts,i,N] = postSAMPLER(M,Samples,logZ)

N = length(Samples);% Length of discarded object array

u = (1/M) * rand(1); %Draw a random number from a uniform istribution in [0,1]

s = 0;               %Initial value of the cumulative mass function

i = zeros(1,N);     %i denotes the number of samples to be replicated from the m^th object

for m = 1:N;        %object index
    
        
    k = 0;          %Number of samples to be replicated from the current index m
    
    s = s + exp(Samples(m).logWt - logZ); % Add the current weight (w_m = A_m/Z) to the current cmf value s, obtain the new stair!
    
    while (s>u)
        
        k = k + 1;  %As long as the current cmf value is larger than the drawn uniform number, increase the number of samples 
        %to be replicated from the current index m by one.
        
        u = u + 1/M; %Draw a new random number from the [0,1] uniform distribution. If it still cannot jump to the next stair 
        % i.e. still s>u_new (indicating a high weight for sample index m)
        % do not exit the while loop and give credit to this high weighted
        % sample index m and replicate from this one more until s becomes
        % smaller than the newly drawn u values
        
    end
    
    i(m) = k; %Index showing how many times sample m will be replicated!
    
end


vector=find(i~=0);%Array containing indices of M drawn samples: We will take samples which will be replicated, thus (i~=0)
%i = 0 denotes killing a particular object at the index of the array


%=== Replicating samples ===

fnames = fieldnames(Samples);  %Opening a cell array to replicate samples according to their weights
f = length(fnames);
cposts = cell([M, f]);
posts = cell2struct(cposts, fnames, 2);
clear cposts;

m = 0;
for k = 1:length(vector);
    for j = 1:i(vector(k))
        m = m+1;
        posts(m) = Samples(vector(k));
        %Posterior Samples: Discarded samples with indices stored 
        % at array "vector" are stored in the new object posts.
    end
end


