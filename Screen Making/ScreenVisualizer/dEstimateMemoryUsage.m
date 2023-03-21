function [ outcode ] = dEstimateMemoryUsage( options )
%DESTIMATEMEMORYUSAGE Summary of this function goes here
%   Detailed explanation goes here

    doubleSize = 8;
    gridN = options.xFullSize * options.yFullSize;
    
    % Num Grids:
    % input             - complex
    % beam intensity    - real
    % far field         - complex
    numGrids = 5;
    
    estSize = ceil(doubleSize * gridN * numGrids / 1024^2);
        
    fprintf('Esimated Memory Use:  %d MB.\n', estSize);
    fprintf('Open figures may require substantially more!\n');
    fprintf('Cumulative Power charts currently memory inefficient.\n');

    outcode = 1;

end

