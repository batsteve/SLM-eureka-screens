function [ outcode ] = cBeam( options, data )
%CBEAM Summary of this function goes here
%   Detailed explanation goes here

    tic
    fprintf('Calculating beam intensities.');

    switch options.beamType
        case 'gaussian'
            xOff = 0.5+options.xBeamCenter;
            yOff = 0.5+options.yBeamCenter;
            rXX = linspace(0, 1, options.xRawSize);
            rYY = linspace(0, 1, options.yRawSize);
            [rXXX, rYYY] = ndgrid(rXX, rYY);
            
            rRR2 = ((rXXX - xOff).^2 + (rYYY - yOff).^2);
            rawBeam = exp(-rRR2/options.beamRadius^2);
            data.rawIntensityFactor = (options.xRawSize*options.yRawSize)/sum(rawBeam(:).^2);
            data.rawBeam = rawBeam*sqrt(data.rawIntensityFactor);

            pXX = linspace(0 - options.xOutsideFactor, 1 + options.xOutsideFactor, options.xFullSize);
            pYY = linspace(0 - options.yOutsideFactor, 1 + options.yOutsideFactor, options.yFullSize);
            [pXXX, pYYY] = ndgrid(pXX, pYY);
            pRR2 = ((pXXX-xOff).^2 + (pYYY - yOff).^2);
            paddedBeam = exp(-pRR2/options.beamRadius^2);
            data.paddedIntensityFactor = (options.xInnerSize*options.yInnerSize)/sum(paddedBeam(:).^2);
            data.paddedBeam = paddedBeam*sqrt(data.paddedIntensityFactor);
    
        case 'uniform'
            data.rawBeam = ones(options.xRawSize, options.yRawYSize);
            data.rawIntensityFactor = 1;
            
            data.rawBeam = ones(options.xFullSize, options.yFullSize);
            data.paddedIntensityFactor = 1;
            
        otherwise
            warning('Unrecognized beam type: %s!\n', options.beamType);
            
            data.rawBeam = ones(options.xRawSize, options.yRawYSize);
            data.rawIntensityFactor = 1;
            
            data.rawBeam = ones(options.xFullSize, options.yFullSize);
            data.paddedIntensityFactor = 1;
    end

    fprintf('  Done after %d seconds.\n', ceil(toc));
    
    outcode = 1;
    
end

