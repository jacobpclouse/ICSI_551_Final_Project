function profileTEST()

clear all
home


% SET UP ANALYSIS STRUCTURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('running apply')

[Obj, Samples, Try, MODELS, PARAMS] = apply; % create structures

disp('done with apply')

% Extract parameters
Xmax = PARAMS.Xmax;
Xmin = PARAMS.Xmin;
Xrange = Xmax-Xmin;
Ymin = PARAMS.Ymin;
Ymax = PARAMS.Ymax;
Yrange = Ymax-Ymin;
Zmin = PARAMS.Zmin;
Zmax = PARAMS.Zmax;
Zrange = PARAMS.Zrange;
Dmin = PARAMS.Dmin;
Dmax = PARAMS.Dmax;
Drange = PARAMS.Drange;
S = PARAMS.sNPOSTS;     % number of posterior samples

% current z-axis rotation state
currentROTC = 0;

% PLAYING FIELD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure we consider measurements within accessible range
[Xtest,Ytest] = meshgrid(Xmin:Xmax,Ymin:Ymax);  % playing field
[Ny, Nx] = size(Xtest);

% we create a refined map, so that we can achieve an accurate convolution
% with the light sensor psf
% The convolution range depends on sigma
% We will convolve over 2 sigma region (4 sigma x 4 sigma)
refinement = 2;
r = 1/refinement;
[Xs,Ys] = meshgrid(Xmin-r:r:Xmax+r,Ymin-r:r:Ymax+r);  % integration field

% pre-generate point spread function patch
sigma = 1;
convRNG = ceil(2*sigma);
[Xpsf, Ypsf] = meshgrid(-convRNG:r:convRNG,-convRNG:r:convRNG);
psf = gauss2d(Xpsf, 0, Ypsf, 0, sigma);


% Store these results in PARAMS
PARAMS.psfFNC = psf;
PARAMS.psfREF = r;
PARAMS.psfNRM = r^2;


% generate an indicator map of the playing field
Dmin2 = Dmin^2;
Dmax2 = Dmax^2;
Field = zeros(size(Xtest));
for tryX = 1:Nx
    for tryY = 1:Ny
        angle = 180/pi*invtan(Xtest(tryY,tryX),Ytest(tryY,tryX));
        dist = Xtest(tryY,tryX)^2 + Ytest(tryY,tryX)^2;
        
        distOK = (dist > Dmin2) && (dist < Dmax2);
        angleOK = (angle > PARAMS.Amin) && (angle < PARAMS.Amax);
        
        % Field is a flag array indicating coordinates within robot reach
        Field(tryY, tryX) = (distOK && angleOK);
    end
end

% col and row enable one to find the column and row of a pixel in the above
% maps using only the linear array index
col = zeros(1,numel(Xtest));
row = zeros(1,numel(Ytest));
findex = find(Field>0); % field indices > 0 
for ii = 1:length(findex)
    iF = findex(ii);
    col(1,iF) = (1+floor((iF-1)/size(Xtest,1)));    % map to the column
    row(1,iF) = iF - (col(1,iF)-1)*size(Xtest,1);
end

disp('Playing Field ready...');


% SET UP ROBOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('Setting up connection...');
% moveFILE = 'Arm-Move-3.rxe';
% homeFILE = 'Arm-Home.rxe';
% comPORT = input('Enter COM port:');
% lego = legoNXT(['com' num2str(comPORT)]);
% 
% if lego.doesFileExist(moveFILE)
%     disp('Robot Ready');
% else
%     disp('Problem with robot!');
% end

% The robot can vary his height above the field




%%%%%%%%%%%% FORMERLY, DATA WERE ALREADY GIVEN %%%%%%%%%%%%%%%%%%%%%%%%%%
% filename = input('Please enter data source: ' , 's'); % request data
% load (filename, '-mat', 'D', 'X', 'Y'); % retrieve data
continueEXPERIMENT = 1;
START = 1;

N = 0;              % Number of data values


% DATA.D = [0    52    18    16    44    41    25    22    16];
% DATA.X = [0     8   -33   -17    -4    -6    58    39   -10];
% DATA.Y = [0    42    41    46    39    44    22    41    48];
% nextX = 8;
% nextY = 42;
% N = length(DATA.D);


% number of data points
DATA.D = [0];
DATA.X = [0];
DATA.Y = [0];
DATA.D = [26, 11, 11, 11, 11, 11, 11, 24, 11, 11, 24, 11, 24];
DATA.X = [0, -39, -24, 40, -16, 1, 35, 17, 0, 16, 12, 23,  3];
DATA.Y = [30, 15, 49, 29, 57, 51, 26, 35, 48, 26, 34, 45, 44];
N = length(DATA.D);

for i = 1:N
    [DATAX, DATAY] = meshgrid(DATA.X(i)-convRNG:r:DATA.X(i)+convRNG,DATA.Y(i)-convRNG:r:DATA.Y(i)+convRNG);
    DATA.DATAX{i} = DATAX;
    DATA.DATAY{i} = DATAY;
end



% SET UP DISPLAY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scrsz = get(0,'ScreenSize');
offset = 200;
scrnDIMS = [scrsz(1) 200 scrsz(3) scrsz(4)-200];
figure('Name','The Robot''s Thoughts','Position',scrnDIMS);
hold on;
axis xy;
axis equal;
axis([Xmin Xmax Ymin Ymax]);

% initial guess is in the center
xo = (Xmax + Xmin)/2;
yo = (Ymax + Ymin)/2;
ro = (PARAMS.Rmax + PARAMS.Rmin)/2;
sxo = Xmax-Xmin;
syo = Ymax-Ymin;
sro = PARAMS.Rmax - PARAMS.Rmin;

disp(['mean(x) = ' num2str(xo) ', stddev(x) = ' num2str(sxo)]);
disp(['mean(y) = ' num2str(yo) ', stddev(y) = ' num2str(syo)]);
disp(['mean(r) = ' num2str(ro) ', stddev(r) = ' num2str(sro)]);



% SELECT STARTING MEASUREMENT LOCATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
notOK = 1;
while notOK
    xCOORD = ceil(Nx*rand);
    yCOORD = ceil(Ny*rand);

    if Field(yCOORD, xCOORD)
        notOK = 0;
        nextX = Xtest(yCOORD, xCOORD);
        nextY = Ytest(yCOORD, xCOORD);
    end
end




    % Save previous solution
    prevXO = xo;
    prevYO = yo;
    prevRO = ro;
    prevSXO = sxo;
    prevSYO = syo;
    prevSRO = sro;

    % Sample from the Posterior Probability
    posts = samplePOSTERIOR(Obj, Samples, Try, DATA, MODELS, PARAMS);

  
    % save intensity field for each model
    %theFIELD = zeros(size(Field));

    for i = 1:length(posts)
        thisMODEL = posts(i).MODEL;
        %%% downsample this
        intMAP = (PARAMS.Light-PARAMS.Dark)*conv2(intensity(thisMODEL, PARAMS, Xs, Ys), PARAMS.psfFNC, 'same') + PARAMS.Dark;
        
        intFIELD = zeros(size(Xtest));
        % loop through all valid field indices
        for ii = 1:length(findex)
            iF = findex(ii);
            iX = 2*row(iF);
            iY = 2*col(iF);
            intFIELD(findex(ii)) = sum(intMAP(iX-1:iX+1,iY-1)) + sum(intMAP(iX-1:iX+1,iY)) + sum(intMAP(iX-1:iX+1,iY+1));
        end
        posts(i).MODEL.INTFIELD = intFIELD*PARAMS.psfNRM;
       
        % To Display what the robot would see for model i, use:
%         figure;
%         image(posts(i).MODEL.INTFIELD);
%         colormap bone
    end


    % Display an intensity prediction map with the shape model
%     figure;
%     image(Xmin:Xmax, Ymin:Ymax, posts(3).MODEL.INTFIELD);
%     colormap bone
%     hold;
%     dispMODEL(posts(3).MODEL, PARAMS, 'b');
    
    
    

    % Compute mean and standard deviation from samples drawn from posterior
    xo = 0;
    xxo = 0; % 1st and 2nd moments of x
    yo = 0;
    yyo = 0; % 1st and 2nd moments of y
    ro = 0;
    rro = 0;
    for i = 1:S;
        %         w = exp(posts(i).logWt - logZ);
        xo = xo + posts(i).MODEL.XO;
        xxo = xxo + posts(i).MODEL.XO * posts(i).MODEL.XO;
        yo = yo + posts(i).MODEL.YO;
        yyo = yyo + posts(i).MODEL.YO * posts(i).MODEL.YO;
        ro = ro + posts(i).MODEL.R;
        rro = rro + posts(i).MODEL.R * posts(i).MODEL.R;
    end
    xo = xo/S;
    yo = yo/S;
    ro = ro/S;
    xxo = xxo/S;
    yyo = yyo/S;
    rro = rro/S;
    sxo = sqrt(abs(xxo-xo*xo));
    syo = sqrt(abs(yyo-yo*yo));
    sro = sqrt(abs(rro-ro*ro));
    disp(['mean(x) = ' num2str(xo) ', stddev(x) = ' num2str(sxo)]);
    disp(['mean(y) = ' num2str(yo) ', stddev(y) = ' num2str(syo)]);
    disp(['mean(r) = ' num2str(ro) ', stddev(r) = ' num2str(sro)]);


    
    % Select the next measurement
    entropy = selectMEAS([Nx, Ny], Xtest, Ytest, posts, Field, MODELS, PARAMS);
    
    
    % generate entropy map
    [nextX, nextY] = entropyMAP(entropy, posts, nextX, nextY, DATA, Xtest, Ytest, Field, PARAMS);

    % print the next measurement location
    disp(['Next x-coordinate: ' num2str(nextX)])
    disp(['Next y-coordinate: ' num2str(nextY)])
