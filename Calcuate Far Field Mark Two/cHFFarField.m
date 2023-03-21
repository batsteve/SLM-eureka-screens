function [ outcode ] = cHFFarField( options, data )
%CFARFIELD Summary of this function goes here
%   Detailed explanation goes here

    tic
    
    fprintf('Beginning HF calculation of far field.');
    
    if (options.xOutsideFactor ~= 0) || (options.yOutsideFactor ~= 0)
        warning('HF Integrator may behave badly if the phase screen padded beyond the SLM boundary.\n');
    end
    
    %data.farFieldFromRaw = fftshift(fft2(data.rawBeam.*data.rawScreen));
    

    
    L = options.hfDistance;
    k = 2*pi/options.lambda;
    
    xInt = linspace(-options.hfInputSizeXReal/2, options.hfInputSizeXReal/2, options.xInnerSize);
    yInt = linspace(-options.hfInputSizeYReal/2, options.hfInputSizeYReal/2, options.yInnerSize);
    [XXsource, YYsource] = ndgrid(xInt, yInt);
    
    xInt = linspace(-options.hfOutputSizeXReal/2, options.hfOutputSizeXReal/2, options.hfOutputSizeX);
    yInt = linspace(-options.hfOutputSizeYReal/2, options.hfOutputSizeYReal/2, options.hfOutputSizeY);
    [XXfarfield, YYfarfield] = ndgrid(xInt, yInt);
    
    inputCellSize = (options.hfInputSizeXReal/options.xInnerSize)*(options.hfInputSizeYReal/options.yInnerSize);
    prefactor = inputCellSize*(1i*k)/(2*pi.*L) .* exp(1i*k*L);
    %prefactor = inputCellSize*(1i*k)/(2*pi.*L);
    
    outputPlane = zeros(options.hfOutputSizeX, options.hfOutputSizeY);
%     for x = 1:size(outputPlane, 1)
%         fprintf('(x,y) = (%d, %d)\n', x, 1);
%         for y = 1:size(outputPlane, 2)
%             xDist2 = (XXfarfield(x,y) - XXsource).^2;
%             yDist2 = (YYfarfield(x,y) - YYsource).^2;
%             RR2 = xDist2 + yDist2;
%              kernel = prefactor*exp(1i*k*abs(RR2./(2.*L))).* ...
%                  exp(data.screen).*data.incidentBeam;
% %            kernel = prefactor*exp(1i*k*sqrt(RR2+L^2)).* ...
% %                exp(data.screen).*data.incidentBeam;
%             outputPlane(x, y) = abs(sum(kernel(:)))^2;
%         end
%     end

    %integral approach
    
    for x = 1:size(outputPlane, 1)
        for y = 1:size(outputPlane, 2)
            xf = XXfarfield(x, y);
            yf = YYfarfield(x, y);
            fprintf('(x_%d,y_%d) = (%0.3f, %0.3f)\n', x, y, xf, yf);
            for xsk = 1:options.xInnerSize
                for ysk = 1:options.yInnerSize
                    xs = XXsource(xsk, ysk);
                    ys = YYsource(xsk, ysk);
                    %kernel  = @(xx, yy) prefactor*exp(1i*k*sqrt(RR2(xs+xx, ys+yy)+L^2)).* incident(xs, ys);
                    %kernel  = @(xx, yy) exp(1i*k*sqrt(RR2(xs+xx, ys+yy, xf, yf)/L^2)).* incident(xs, ys);
                    %outputPlane(x, y) = outputPlane(x, y) + integral2(kernel, 0, 1, 0, 1);
                    kernel  = @(xx, yy) exp(1i*k*sqrt(RR22(xs+xx, ys+yy, xf, yf)/L^2)).* incident_2(xsk, ysk);
                    outputPlane(x, y) = outputPlane(x, y) + integral2(kernel, 0, inputCellSize, 0, inputCellSize);
                end
            end
%             kernel  = @(xx, yy) prefactor*exp(1i*k*sqrt(RR2(xx, yy)+L^2)).* ...
%                  incident(xx, yy);
%              
%             outputPlane(x, y) = integral2(kernel, 1, options.xInnerSize, 1, options.yInnerSize);
        end
    end
    
    
    
    data.farField = abs(prefactor*outputPlane).^2;
    
    fprintf('  Done after %d seconds.\n', ceil(toc));

    outcode = 1;
    
    function [ val ] = RR2(xx, yy, xff, yff)
        trueX = ((xx-1)/options.xInnerSize*options.hfInputSizeXReal) - options.hfInputSizeXReal/2;
        trueY = ((yy-1)/options.yInnerSize*options.hfInputSizeYReal) - options.hfInputSizeYReal/2;
        
        val = (trueX - xff).^2 + (trueY - yff).^2;
    end

    function [ val ] = RR22(xx, yy, xff, yff)
        val = (xx - xff).^2 + (yy - yff).^2;
    end

    function [ val ] = incident(xx, yy)
        xIndex = floor(xx);
        yIndex = floor(yy);
        totalIndex = xIndex + (yIndex-1)*size(data.screen, 2);
        val = exp(data.screen(totalIndex)).*data.incidentBeam(totalIndex);
%         val = exp(data.screen(xIndex(:), yIndex(:)).* ...
%             exp(data.incidentBeam(xIndex(:), yIndex(:))));
    end

    function [ val ] = incident_2(xx, yy)
        %xIndex = floor(xx);
        %yIndex = floor(yy);
        %totalIndex = xIndex + (yIndex-1)*size(data.screen, 2);
        val = exp(data.screen(xx, yy)).*data.incidentBeam(xx, yy);
%         val = exp(data.screen(xIndex(:), yIndex(:)).* ...
%             exp(data.incidentBeam(xIndex(:), yIndex(:))));
    end

end

