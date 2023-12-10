% LEGO Light Sensor PSFS
% implemented by Kevin Knuth
% 17 Apr 2013
%
% edited by Jacob Clouse
% 10 Dec 2023
%
% uses code from Nabin Malakar: 'weighted_G_1 copy.m'
% to generate the SSF from a weighted average of the Gaussian SSF fields
% obtained by nested sampling

% Here I implement rotation enabling the SSF to be rotated from
% 90 degrees CW to -90 degrees CW (90 degrees CCW)

% this code will be used in the function shapes to generate a psf
% for each measurement location.  these will be stored with the recorded
% data.  these are twice the resolution previously used.

% i will have to include these psfs in the inquiry part as well.


home
close all;


load('Results1asymm_G_NS.mat')


g = zeros(101,101);
sx = 0.25; sy = 0.25;
limit = 2;
[xp,yp] = meshgrid(-limit:sx:limit, -limit:sy:limit);

for i = 1:181
    
    close all;
    
    disp(i)
    theta = -(i-1-90)*pi/180; % map 1->181 to 0->180 to -90->90 to 90->-90
    
    x = xp*cos(theta) - yp*sin(theta);
    y = xp*sin(theta) + yp*cos(theta);
    
    for jj = 1:nest-1
        wt(jj) = exp(Samples(jj).logWt - logZ);  % proportional weight
        
        lobes = [Samples(jj).x1 Samples(jj).x2];
        std = [Samples(jj).y1 Samples(jj).y2 Samples(jj).y3];
        amp = [Samples(jj).z1];
        
        xl = lobes(1);% left lobe
        yl = lobes(2);
        
        A = std(1);
        B = std(2);
        C = std(3);
        
        Z1 = amp(1);
        
        %get the parameters
        
        A1 = B/(A*B-C^2);
        B1 = A/(A*B-C^2);
        C1 = 2*C/(A*B-C^2);
        
        g = Z1*exp((-1/2)*(A1*(x-xl).^2 + B1*(y-yl).^2+C1*(x-xl).*(y-yl)));
        g = g  + wt(jj)*g;
    end
    % if sum(sum(g))==0
    %     g(:,:)= eps;
    % end
    
    psfs{i} = g./sum(sum(g));
    
    
    h = figure;
    imagesc(psfs{i}); axis xy; colormap bone;
    
    F(i) = getframe(h);
end

 savefile = 'LEGO_light_sensor_psfs.mat';
 save(savefile, 'psfs');

movie(F,20)
 
%%

% compare this to the scale in the old advanced code
% where we used a circular Gaussian

refinement = 4;
r = 1/refinement;

% pre-generate point spread function patch
% psf at 1 cm height has a sigma of about 4 mm
% LEGO stud spacing is 8 mm
% sigma = 4 mm * 1 LEGO/8 mm  = 0.5;
sigma = 0.375;
convRNG = 2;
[Xpsf, Ypsf] = meshgrid(-convRNG:r:convRNG,-convRNG:r:convRNG);
psf = gauss2d(Xpsf, 0, Ypsf, 0, sigma);
h = figure;
imagesc(psf); axis xy; colormap bone;
