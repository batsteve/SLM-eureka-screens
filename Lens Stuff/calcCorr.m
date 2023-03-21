function [ overallCorrValues ] = calcCorr( pattern, params )
%CALCCORR Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Starting correlation length calculations.\n');

    xSize = size(pattern, 2);
    ySize = size(pattern, 1);
    %[YYY, XXX] = ndgrid(1:ySize, 1:xSize);
    %numFrames = size(curRun.data.vidFrames, 3);
    
    %maxRadius = ceil(sqrt(xSize.^2 + ySize^2));
    %corrRadii = [0:1:maxRadius];
    
    %epsilon = 0.1;  % How much leeway in exact distances.
    overallCorrValues = zeros(length(params.corrDistances), 1);
    numGoodPairs = zeros(length(params.corrDistances), 1);
    
    %
    % Each (x,y) gridpoint has a (fixed) distance from the beam center,
    % wherever it is that is located
    %
    
    %radii = sqrt((XXX - curRun.results.xBeamCenter).^2 + (YYY - curRun.results.yBeamCenter).^2);
    %binnedRadii = ceil(radii) + 1;
    
    %corrValues = zeros(length(params.corrDistances), length(corrRadii));
    
    
    %
    % Some matrix manipulations would prefer a logical mask
    %
%     
%     radiusMask = zeros(ySize, xSize, length(.corrRadii));
%     numRadiusPairs = zeros(length(corrStruct.corrRadii), 1);
%     for k = 1:length(corrStruct.corrRadii)
%         radiusMask(:,:,k) = logical(binnedRadii(:,:) == corrStruct.corrRadii(k));
%         numRadiusPairs(k) = sum(sum(radiusMask(:,:,k)));
%     end
    
    %
    % Cache the temporal means, b/c we gonna be using them a lot
    %
    meanVals = zeros(ySize, xSize);
    for x = 1:xSize
        for y = 1:ySize
            meanVals(y, x) = mean(pattern(y, x, :));
        end
    end

    magicFactor = 1;
    onlyXSeparation = false;
%     if onlyXSeparation, fprintf('Only x-displacements considered.\n');
%     else,               fprintf('Both x and y-displacements considered.\n');
%     end
    
    for k = 1:length(params.corrDistances)
        if onlyXSeparation
            numYBreaks = 1;
        else
            numYBreaks = floor(params.corrDistances(k)/magicFactor)+1;
        end
        
        tic;
        numPairs = zeros(numYBreaks, 1);
        rankValues = zeros(numYBreaks, 1);
        for j = 1:numYBreaks
            yDiff = floor(j-1);
            xDiff = floor(sqrt(params.corrDistances(k)^2 - (magicFactor*yDiff)^2));
            yInt = 1:(ySize - yDiff);
            xInt = 1:(xSize - xDiff);
            corrFunction = mean(pattern(yInt, xInt, :).* ...
                pattern(yInt + yDiff, xInt + xDiff, :), 3);
            meanProduct = meanVals(yInt, xInt, :).* ...
                meanVals(yInt + yDiff, xInt+xDiff, :);
            
            numPairs(j) = length(corrFunction(:));
            rankValues(j) = sum(corrFunction(:) - meanProduct(:));
        end
        numGoodPairs(k) = sum(numPairs);
        overallCorrValues(k) = sum(rankValues(:))/numGoodPairs(k);
        
        %fprintf('Length %d calculation complete after %d seconds.\n', ...
        %    params.corrDistances(k), ceil(toc));
    end



end

