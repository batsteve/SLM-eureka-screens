function [ outcode ] = cPaddedScreen( options, data )
%PROCESSPHASESCREEN Summary of this function goes here
%   Detailed explanation goes here

    tic
    fprintf('Beginning phase screen processing.');
    
    switch options.paddingMethod
        case 'fully nested loops'
                 
            for jj = 1:options.xInputSize
                for kk = 1:options.yInputSize


                    xDiff = jj*(options.xBlowupFactor + options.xBevelSize);
                    yDiff = kk*(options.yBlowupFactor + options.yBevelSize);     

                    for jjj = 0:(1-options.xBlowupFactor)
                        for kkk = 0:(1-options.yBlowupFactor)
                            data.processedScreen(xOffset+xDiff+jjj, yOffset+yDiff+kkk) = options.bevelTransmittance;
                        end
                    end 

                    for jjj = 1:options.xBlowupFactor
                        for kkk = 1:options.yBlowupFactor
                            data.processedScreen(xOffset+xDiff+jjj, yOffset+yDiff+kkk) = data.rawScreen(jj, kk);
                        end
                    end     
                end
            end
    
        case 'block by block'
            data.paddedScreen = ones(options.xFullSize, options.yFullSize)*options.exteriorTransmittance;

            XX = options.xOffset:(options.xOffset+options.xInnerSize);
            YY = options.yOffset:(options.yOffset+options.yInnerSize);

            data.paddedScreen(XX, YY) = options.bevelTransmittance;

            for jj = 0:(options.xRawSize-1)
                for kk = 0:(options.yRawSize-1)
                    xDiff = jj*(options.xBlowupFactor) + (jj+1)*options.xBevelSize;
                    yDiff = kk*(options.yBlowupFactor) + (kk+1)*options.yBevelSize;
                    
                    XXX = (options.xOffset+xDiff):(options.xOffset+xDiff+options.xBlowupFactor);
                    YYY = (options.yOffset+yDiff):(options.yOffset+yDiff+options.yBlowupFactor);
                    
                    data.paddedScreen(XXX, YYY) = data.rawScreen(jj+1, kk+1);
                end
            end
            
        % Best Method.  Do this one.
        %   
        case 'travelling raw';
            data.paddedScreen = ones(options.xFullSize, options.yFullSize)*options.exteriorTransmittance;

            XX = options.xOffset + 1:options.xInnerSize;
            YY = options.yOffset + 1:options.yInnerSize;

            data.paddedScreen(XX, YY) = options.bevelTransmittance;
            XXX = options.xOffset + options.xBlockSize*(0:(options.xRawSize-1));
            YYY = options.yOffset + options.yBlockSize*(0:(options.yRawSize-1));

            for jj = 1:(options.xBlowupFactor)
                for kk = 1:(options.yBlowupFactor)
                    data.paddedScreen(XXX+jj, YYY+kk) = data.rawScreen(:, :);
                end
            end
            
        otherwise
            warning('Padding Method unrecognized:  %s.\n', options.paddingMethod);
    end

    
    fprintf('  Done after %d seconds.\n', ceil(toc));
    outcode = 1;

end

