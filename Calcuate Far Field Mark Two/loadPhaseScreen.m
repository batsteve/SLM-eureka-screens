function [ outcode ] = loadPhaseScreen( options, output, data )
%LOADPHASESCREEN Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Loading phase screen %d.\n', data.n);

    infilename = sprintf('%s%s%d.bmp', output.screenPath, output.screenName, data.n);
    image = imread(infilename);
    rawScreen = double(image(:,:));
    
    data.screen = exp(1i*rawScreen*2*pi/256);

    outcode = 1;
    
end

