function [ outcode ] = ZPScreenCreator( )
%ZPSCREENCREATOR Creates SLM phase screens of simulated turbulence via a
%Zernicke polynomial method
%   Detailed explanation goes here


    %
    % Set parameters for the algorithm.
    %
    numScreens = 20;
    numAtmos = 4;      % Make this numScreens to have independent screens
    screenSize = [256, 256];
    numZernickeModes = 400;
    piBased = true;     % Set the fluctuations pi + phi(r), instead of
                        % 0 + phi(r).  Makes the image slightly prettier
                        % for weak turbulence
    
    lambda = 633e-9;
    k = 2*pi/lambda;
    Cn2 = 1e-12;                         % Atmospheric Turbulence Measure
    L = 750;                             % path length -- distance travelled
    r0 = ( 0.423*k^2*(Cn2*L) )^(-3/5);   % correlation length, according
                                         % to Fried 1966 and wikipedia
                                         
    %interpType = 'linear';
    interpType = 'spline';
    
                                            
    %
    % Create the (SLM) phase screen grid.  I don't really understand what
    % the aperture size is.
    %
    apertureSize = 1/sqrt(2);
    xInterval = linspace(-apertureSize, apertureSize, screenSize(1));
    yInterval = linspace(-apertureSize, apertureSize, screenSize(2));
    [xx, yy] = ndgrid(xInterval, yInterval);
    rr = sqrt(xx.^2 + yy.^2);
    theta = atan2(yy, xx);
    
    
    
    %
    % Instantiate the random variables determining the strength of the
    % Zernicke modes.
    %
    zernickeModesSkeleton = zeros(numZernickeModes, numAtmos);
    for z = 1:numAtmos
        for mm = 1:numZernickeModes
            zernickeModesSkeleton(mm, z) = randn(1)*sqrt(ZPKolmogorovVariance(mm, L/r0));
        end
    end
    
     
    %
    % Create the phase screens by finding the position in the Zernicke
    % list, interpolating the magnitude of each mode, and then drawing the
    % resulting polynomial onto the screen.
    %
    % Linear interpolation looks a bit unnatural, adding a spline
    % interpolation method.
    %
    % May eventually decide that each Zernicke mode needs a phase offset,
    % so output looks less obviously interpolated?
    %
    localMode = zeros(numZernickeModes, numScreens);
    switch interpType
        
        case 'linear'
            for jj = 1:numScreens
                indexFrac = (jj/numScreens)*(numAtmos-1)+1;
                prevIndex = floor(indexFrac);
                fracNext = mod(indexFrac,1);
                nextIndex = ceil(indexFrac);
                fracPrev = 1-fracNext;
                if prevIndex < 1
                    prevIndex = 1;
                    fracPrev = 1;
                    fracNext = 0;
                end
                if nextIndex > numAtmos,
                    nextIndex = numAtmos;
                    fracPrev = 0;
                    fracNext = 1;
                end

                for mm = 1:numZernickeModes
                    localMode(mm, jj) = fracPrev*zernickeModesSkeleton(mm, prevIndex) + ...
                        fracNext*zernickeModesSkeleton(mm, nextIndex);
                end
            end
            
        case 'spline'
            for mm = 1:numZernickeModes
                localMode(mm, :) = spline(linspace(1, numScreens, numAtmos), ...
                    zernickeModesSkeleton(mm, :), linspace(1, numScreens, numScreens));
            end
    end
    
    
    
    %
    % Create the data arrays.  Since phase is only determined up to a
    % constant, the offset set here doesn't matter.
    %
    if piBased,screens = pi*ones(screenSize(1), screenSize(2), numScreens);
    else       screens = zeros(screenSize(1), screenSize(2), numScreens);
    end
    
    
    
    %
    % Create the phase screens by drawing the Zernicke polynomials of each
    % degree onto the screen according to the appropriate phase.
    %
    for jj = 1:numScreens
        for mm = 1:numZernickeModes
            screens(:,:,jj) = screens(:,:,jj) + localMode(mm, jj).*ZPZernicke(mm, rr, theta);
        end
    end
    
    
    
    %
    % Convert the screens into uint8 in the range 0->255
    %
    discScreens = uint8(mod(256/(2*pi)*screens, 256));
    
    
    
    %
    % Save the screens as ouput
    %
    for jj = 1:numScreens
        outfilename = sprintf('Screens\\Zturb_%04d.bmp', jj);
        imwrite(discScreens(:,:,jj), outfilename);
    end
    
    

    outcode = 1;

end

