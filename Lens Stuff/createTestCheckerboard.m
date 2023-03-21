function [ pattern ] = createTestCheckerboard( params  )
%CREATETESTCHECKBOARD Summary of this function goes here
%   Detailed explanation goes here

    pattern = zeros(params.xNumBlocks*params.xBlockSize, ...
        params.yNumBlocks*params.yBlockSize, params.numFlips);
    [XX, YY] = ndgrid(1:(params.xNumBlocks*params.xBlockSize), ...
        1:(params.yNumBlocks*params.yBlockSize));
    
    
    for k = 1:params.numFlips
        randomXOffset = floor(rand()*params.xBlockSize);
        randomYOffset = floor(rand()*params.yBlockSize);
        xColor = floor((XX+randomXOffset)/params.xBlockSize);
        yColor = floor((YY+randomYOffset)/params.yBlockSize);
        pattern(:,:, k) = params.blackVal*mod(xColor+yColor, 2) + ...
                params.whiteVal*mod(xColor+yColor + 1, 2);
    end
    
%     figure(1001);
%     clf
%     pcolor(pattern(:,:,1));
%     shading flat
%     
%     figure(1002);
%     clf
%     pcolor(pattern(:,:,2));
%     shading flat


end

