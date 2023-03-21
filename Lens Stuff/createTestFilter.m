function [ filter ] = createTestFilter( params )
%CREATETESTFILTER Summary of this function goes here
%   Detailed explanation goes here

    [XX, YY] = ndgrid(1:(2*params.filterXRad + 1), 1:(2*params.filterYRad + 1));
    xCenter = params.filterXRad + 1;
    yCenter = params.filterYRad + 1;
    
%     fullXSize = 1:(params.xNumBlocks*params.xBlockSize);
%     fullYSize = 1:(params.xNumBlocks*params.xBlockSize);
%     [XX, YY] = ndgrid(fullXSize, fullYSize);
%     xCenter = fullXSize(ceil(length(fullXSize)/2));
%     yCenter = fullYSize(ceil(length(fullYSize)/2));
    
    RR2 = (XX-xCenter).^2 + (YY-yCenter).^2;
    %filter = params.filterScale*exp(-RR2/params.filterWidth);
    filter = exp(-RR2/params.filterWidth);

    weight = sum(filter(:));
    %fprintf('Filter weight: %f\n', weight);
    filter = filter/weight;
    
end

