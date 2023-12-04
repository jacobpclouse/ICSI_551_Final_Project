% circle.m
% Bayesian Adaptive Exploration applied to characterizing a circle with a
% robotic arm.
%
% Adapted from code written by Phil Erner summer 2007
% Modified: 9 Sept 2007 by Kevin Knuth

function shapes()

close all
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




% TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PARAMS.diagnostics = true;  % Turn on diagnostics
PARAMS.robot = false;       % Control whether robot runs
PARAMS.experiment = true;  % Control whether we will loop through a complete experiment
PARAMS.prevdata = true;  % Enable previous data inclusion

% PARAMS.diagnostics = false;  % Turn on diagnostics
% PARAMS.robot = false;       % Control whether robot runs
% PARAMS.experiment = true;  % Control whether we will loop through a complete experiment
% PARAMS.prevdata = true;  % Enable previous data inclusion

% PLAYING FIELD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section modified by Kevin Knuth on 17 Apr 2013
%
% make sure we consider measurements within accessible range
[Xtest,Ytest] = meshgrid(Xmin:Xmax,Ymin:Ymax);  % playing field
[Ny, Nx] = size(Xtest);

% we create a refined map, so that we can achieve an accurate convolution
% with the light sensor psf
refinement = 4;
r = 1/refinement;
%[Xs,Ys] = meshgrid(Xmin-r:r:Xmax+r,Ymin-r:r:Ymax+r);  % integration field
convRNG = 2; % two LEGO units left and right

% we load the pre-generated LEGO Light Sensor PSFS
% these were generated from 'LEGO_light_sensor_psfs.m' using nested sampling
% results from Nabin's file 'Results1asymm_G_NS.mat'
% these are stored in a cell array with element 1 mapping to an arm
% orientation of 0 degrees (3 o'clock when viewed from above) to element 
% 181 mapping to 180 degrees (9 o'clock when viewed from above).
load('LEGO_light_sensor_psfs.mat');


% Store these results in PARAMS
PARAMS.psfFNC = psfs;
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
        
        % Field is a flag array indicating which coordinates are within robot reach
        Field(tryY, tryX) = (distOK && angleOK);
    end
end

% col and row enable one to find the column and row of a pixel in the above
% maps using only the linear array index
% col = zeros(1,numel(Xtest));
% row = zeros(1,numel(Ytest));
% findex = find(Field>0); % field indices > 0 
% for ii = 1:length(findex)
%     iF = findex(ii);
%     col(1,iF) = (1+floor((iF-1)/size(Xtest,1)));    % map to the column
%     row(1,iF) = iF - (col(1,iF)-1)*size(Xtest,1);
%     
%     % generate hiRes patches for convolution
%     [hiRESXs{iF}, hiRESYs{iF}] = meshgrid(row(1,iF)-convRNG:r:row(1,iF)+convRNG, col(1,iF)-convRNG:r:col(1,iF)+convRNG);
% end


% generate hires X and Y maps for each pixel in the playing area
findex = find(Field>0); % field indices > 0 
for ii = 1:length(findex)
    iF = findex(ii);
    
    % generate hiRes patches for convolution
    [hiRESXs{iF}, hiRESYs{iF}] = meshgrid(Xtest(iF)-convRNG:r:Xtest(iF)+convRNG, Ytest(iF)-convRNG:r:Ytest(iF)+convRNG);
end

disp('Playing Field ready...');


% SET UP ROBOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code works by creating files with instructions (usually coordinates)
% and then running programs that were written on the LEGO brick using the
% NXT programming language.
% The tasks can be replaced by functions in MatLab to communicate directly
% with newer LEGO brick models.
if PARAMS.robot
    disp('Setting up connection...');
    moveFILE = 'Arm-Move-3.rxe';
    homeFILE = 'Arm-Home.rxe';
    comPORT = input('Enter COM port:');
    lego = legoNXT(num2str(comPORT));

    if lego.doesFileExist(moveFILE)
        disp('Robot Ready');
    else
        disp('Problem with robot!');
    end

    % The robot can vary his height above the field

    % Set up robot state cell
    currentROTC = 0;    % current z-axis rotation state
    STATE.rotc = currentROTC;
    STATE.movefile = moveFILE;
    STATE.homefile = homeFILE;

    % Check Robot Power
%     power = lego.getBatteryLevel();
%     if power < 0.5
%         disp(['WARNING: Robot Power Low!']);
%     end
%     disp(['Robot Power = ' num2str(power)]);
end

%%%%%%%%%%%% FORMERLY, DATA WERE ALREADY GIVEN %%%%%%%%%%%%%%%%%%%%%%%%%%
% filename = input('Please enter data source: ' , 's'); % request data
% load (filename, '-mat', 'D', 'X', 'Y'); % retrieve data
continueEXPERIMENT = 1;
START = 1;
STATE.start = START;

N = 0;              % Number of data values





if PARAMS.prevdata
    % MANY BLACK DATA POINTS WITH TWO WHITE AND ONE EDGE
    % number of data points
    DATA.D = [22, 11, 11, 11, 11, 11, 11, 24, 11, 11, 28, 11, 24, 40, 40];
    DATA.X = [0, -39, -24, 40, -16, 1, 35, 17, 0, 16, 12, 23,  3, -22, -10];
    DATA.Y = [30, 15, 49, 29, 57, 51, 26, 35, 48, 26, 34, 45, 44, 31, 31];
    N = length(DATA.D);
    
%     DATA.D = [26, 11, 11, 11, 11, 11];
%     DATA.X = [0, -39, -24, 40, -16, 1];
%     DATA.Y = [30, 15, 49, 29, 57, 51];
%     N = length(DATA.D);
    
    % DATA.D = [0    52    18    16    44    41    25    22    16];
    % DATA.X = [0     8   -33   -17    -4    -6    58    39   -10];
    % DATA.Y = [0    42    41    46    39    44    22    41    48];
    % nextX = 8;
    % nextY = 42;
    % N = length(DATA.D);

    for i = 1:N
        % map (x,y_ coordinates to an angle, convert to degrees, round up,
        % floor it so it doesn't go above 180, and add 1 to account for the
        % fact that matlab starts arrays with 1.
        DATA.PSFindex{i} = 1+floor(0.5+(invtan(DATA.X(i),DATA.Y(i))*180/pi));
        DATA.PSF{i} = psfs{DATA.PSFindex{i}};
        [DATAX, DATAY] = meshgrid(DATA.X(i)-convRNG:r:DATA.X(i)+convRNG,DATA.Y(i)-convRNG:r:DATA.Y(i)+convRNG);
        DATA.DATAX{i} = DATAX;
        DATA.DATAY{i} = DATAY;
    end
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




%%%%%%%%%%%%%%%%%%%%% LET'S GO! %%%%%%%%%%%%%%%%%%%%%%%%%%%


ready = input('Ready? ');

tic;

while (continueEXPERIMENT == 1)
    
    % Turn off the experimental loop if we are not doing an experiment
    if PARAMS.experiment == false
        continueEXPERIMENT = 0;
    end

    % we enter this loop with (nextX, nextY) defined
    % request a measurement from the robot
    thisX = nextX;
    thisY = nextY;
    
    % let the robot acquire the data
    acquired = false;
    if PARAMS.robot
        STATE.rotc = currentROTC;
        [newData STATE] = acquireDATA(thisX, thisY, lego, PARAMS, STATE);
        currentROTC = STATE.rotc;
        acquired = true;
    else
        if PARAMS.experiment
            newData = input('Enter intensity by hand...  ');
            acquired = true;
        end
    end

    % Add new Data Value
    % modified 17 Apr 2013: this section now identifies the psf associated
    % with the measurement location
    if acquired
        N = N + 1;
        DATA.D(N) = newData;
        DATA.X(N) = thisX;
        DATA.Y(N) = thisY;
        DATA.PSFindex{N} = 1+floor(0.5+(invtan(DATA.X(N),DATA.Y(N))*180/pi));
        DATA.PSF{N} = psfs{DATA.PSFindex{N}};
        [DATAX, DATAY] = meshgrid(thisX-convRNG:r:thisX+convRNG,thisY-convRNG:r:thisY+convRNG);
        DATA.DATAX{N} = DATAX;
        DATA.DATAY{N} = DATAY;
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
        
        % modified on 17 Apr 2013
        % Since there used to be just one PSF, I could handle this in on
        % line.  Now I have to loop through points.
        
        % I only want to compute this at the field index points
        % so loop through them
        intFIELD = zeros(size(Xtest));
        
        for ii = 1:length(findex)
            % for each field index point have a high-res patch made to
            % integrate over.  keep these in a cell array, and pass them
            % to intensity
            
            iF = findex(ii); % get coords of valid measurement location
            iX = Xtest(iF);
            iY = Ytest(iF);
            PSFind = 1+floor(0.5+(invtan(iX,iY)*180/pi));
            psfnc = psfs{PSFind};   % get psf function for that location

            % get coords to integrate over
            hiRESX = hiRESXs{iF};   % row
            hiRESY = hiRESYs{iF};   % col
            
            % intensity will fill this with an indicator map for the circle
            % model and return it
            intMAP = intensity(thisMODEL, PARAMS, hiRESX, hiRESY);
            
            % convolve the maps (take product then sum)
            summedINTENSITY = sum(sum((intMAP .* psfnc)));
            
%             if (sum(sum(intMAP))) == 289
%                 disp(['inside circle (' num2str(iF) '): ' num2str(sum(sum(intMAP))) ' '  num2str(sum(sum(psfnc))) ' ' num2str(summedINTENSITY)]);
%                 
%                 figure;
%                 imagesc(intMAP);
%                 axis xy
%                 pause;
%                 
%                 figure;
%                 imagesc(psfnc);
%                 axis xy
%                 pause;
%                 
%                 close all
%                 
%             end
            
            % convolve the maps (take product then sum)
            %summedINTENSITY = sum(sum((intMAP .* psfnc)));
            %summedINTENSITY = intMAP(9,9);
            
            intFIELD(iF) = (PARAMS.Light-PARAMS.Dark)*summedINTENSITY + PARAMS.Dark;
       
        end
        
        % compute viewed intensity over the field for this model
        posts(i).MODEL.INTFIELD = intFIELD;
        
        % To Display what the robot would see for model i, use:
%         figure;
%         imagesc(posts(i).MODEL.INTFIELD);
%         axis xy
%         colormap bone
%         pause;
        
    end


%   %  Display an intensity prediction map with the shape model
%     figure;
%     image(Xmin:Xmax, Ymin:Ymax, posts(46).MODEL.INTFIELD);
%     colormap bone
%     hold;
%     dispMODEL(posts(46).MODEL, PARAMS, 'b');
    
    
    

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

START = 0;

if PARAMS.diagnostics
    toc;
end

end

if PARAMS.robot
    % wait until ready
    waiting = 1;
    while waiting
        pause(1);   % wait 1 second
        disp(['FILE EXIST: ' num2str(lego.doesFileExist('ready.txt'))]);
        if lego.doesFileExist('ready.txt')
            waiting = 0;
        end
        disp('robot not ready')
    end
    
    % Check Robot Power
    power = lego.getBatteryLevel;
    if power < 5
        disp(['WARNING: Robot Power Low!']);
    end
    disp(['Robot Power = ' num2str(power)]);
end


% Go to the Center
if PARAMS.robot
    lego.playTone(500,1000);
    lego.playTone(1000,1000);
    lego.playTone(2000,1000);
end

    
    disp(' ')
    disp('I HAVE FOUND THE CIRCLE!')
    disp(' ')
    disp(['Number of measurements: ' num2str(N)])
    disp(' ')
    disp(['mean(x) = ' num2str(xo) ', stddev(x) = ' num2str(sxo)]);
    disp(['mean(y) = ' num2str(yo) ', stddev(y) = ' num2str(syo)]);
    disp(['mean(r) = ' num2str(ro) ', stddev(r) = ' num2str(sro)]);
    disp(' ')
    % disp(['DARK value was ' num2str(PARAMS.Dark)])
    % disp(['LIGHT value was ' num2str(PARAMS.Light)])
    % disp(['UNCERTAINTY was ' num2str(PARAMS.Sigma)])

% send it home
if PARAMS.robot
    lego.playTone(500,1000);
    lego.playTone(1000,1000);
    lego.playTone(2000,1000);

    lego.startProgram(homeFILE);
end




