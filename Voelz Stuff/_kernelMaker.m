function [ window ] = kernelMaker( N, type )
%KERNELMAKER Summary of this function goes here
%   Detailed explanation goes here

    %screenSize = params.screenSize;
    %screenType = params.screenType;
    
    screenSize = N;
    screenType = type;
    
    [y,x] = meshgrid(1:screenSize,1:screenSize);   
    r = length(x)/2;       % choose center of grid
    c = length(x)/2;
    rho = sqrt((x-r).^2 + (y-c).^2);
                                        
    %
    % Make the convolution kernal
    %
    switch screenType
        case 'mgsm'
            N = 1;
            M = 40; 
            Corr_width_2 = 512;

            windowx = zeros(size(rho));
            for m = N:1:M;                             % add in additional windows
                window_m = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m ...
                    *exp(-rho.^2/(2*m*Corr_width_2));
                windowx = windowx + window_m;

                cc = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m;
            end

            window = windowx/cc;
            
        case 'ring'
            deltax = 16;
            Beta = 16;
            param1 = Beta*rho/deltax;
            param2 = rho.^2/(2*deltax^2); 
            window = besselj(0,param1).*exp(-param2);
            
        otherwise
            warning('%s unrecognized!', screenType)
            window = ones(size(rho));
    end
    
    fullNormFactor = sum(window(:));
    window = window/fullNormFactor;

end

