    figure;
    hold;
    for s = 300:310
        dispMODEL(Samples(s).MODEL, PARAMS, 'b');
    end
    
%%

p = zeros(1,500);
cdf = zeros(1,500);

p(1) = exp(Samples(1).logWt - logZ);
cdf(1) = p(1);
for s = 2:500
    p(s) = exp(Samples(s).logWt - logZ);
    cdf(s) = cdf(s-1)+p(s);
end


figure;
plot(1:500,p);

figure;
plot(1:500,cdf);

%%
S = 50;
[posts,i,N] = postSAMPLER(S,Samples,logZ)

 figure;
    hold;
    for s = 1:length(posts)
        dispMODEL(posts(s).MODEL, PARAMS, 'b');
    end
    
%%
S = 50;
posts = postSAMPLES(S,Samples,logZ);

 figure;
    hold;
    for s = 1:length(posts)
        dispMODEL(posts(s).MODEL, PARAMS, 'b');
    end
%%

N = length(Samples)
M = 50;

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

for kk = 1:M;
    
    posts(kk) = Samples(vector(kk));%Posterior Samples: Discarded samples with indices stored at array "vector" are stored in the new object
    %posts.
    
end

%%

clear posts
for i = 1:9
    posts = Samples(100*i+50:100*(i+1));

    figure;
    hold;
    for s = 1:length(posts)
        dispMODEL(posts(s).MODEL, PARAMS, 'b');
    end
end

