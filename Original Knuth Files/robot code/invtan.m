% invtan -- Calculates the inverse tangent function from real and imag components
%
%  Usage
%    phase = invtan(real, imag)
%  Inputs
%    real        real component
%    imag        imaginary component
%  Outputs
%    phase       phase angle from -pi to pi
%
%  Description
%     Computes the phase angle given the real and imaginary components of 
%     a point in the complex plane.
%
%   Created by
%       Kevin Knuth      16 Apr 2002

function [phase] = invtan(real, imag)

if (real == 0)
    if (imag > 0)
        phase = pi/2;
    elseif (imag < 0)
        phase = -pi/2;
    else
        phase = NaN;
    end
else
    if (imag == 0)
        if (real > 0)
            phase = 0;
        else
            phase = pi;
        end
    else
       ratio = imag/real;
       angle = atan(ratio);
       if (real > 0)
           phase = angle;
       else %real < 0
           if (ratio > 0)
               phase = -pi + angle;
           else
               phase = pi + angle;
           end
       end
   end
end



    