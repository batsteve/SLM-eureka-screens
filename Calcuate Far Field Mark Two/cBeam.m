function [ outcode ] = cBeam( options, data )
%CBEAM Summary of this function goes here
%   Detailed explanation goes here

    tic
    fprintf('Calculating beam intensities.');

    switch options.beamType
        case 'gaussian'
            xOff = 0.5+options.xBeamCenter;
            yOff = 0.5+options.yBeamCenter;
            
            pXX = linspace(0 - options.xOutsideFactor, 1 + options.xOutsideFactor, options.xFullSize);
            pYY = linspace(0 - options.yOutsideFactor, 1 + options.yOutsideFactor, options.yFullSize);
            [pXXX, pYYY] = ndgrid(pXX, pYY);
            pRR2 = ((pXXX-xOff).^2 + (pYYY - yOff).^2);
            paddedBeam = exp(-pRR2/options.beamRadius^2);
            data.intensityFactor = (options.xInnerSize*options.yInnerSize)/sum(paddedBeam(:).^2);
            data.incidentBeam = paddedBeam*sqrt(data.intensityFactor);
    
        case 'uniform'
            data.incidentBeam = ones(options.xFullSize, options.yFullSize);
            data.intensityFactor = 1;
            
        otherwise
            warning('Unrecognized beam type: %s!\n', options.beamType);
           
            data.incidentBeam = ones(options.xFullSize, options.yFullSize);
            data.intensityFactor = 1;
    end

    fprintf('  Done after %d seconds.\n', ceil(toc));
    
    outcode = 1;
    
end

