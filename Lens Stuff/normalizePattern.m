function [ normPattern ] = normalizePattern( pattern, params )
%NORMALIZEPATTERN Summary of this function goes here
%   Detailed explanation goes here

    mu = mean(pattern, 3);
    sigma = sqrt(var(pattern, [], 3));
    
    normPattern = zeros(size(pattern));
    for k = 1:params.numFlips    
        normPattern(:, :, k) = (pattern(:,:,k) - mu)./sigma;
    end

    normPattern(isnan(normPattern)) = 0;
    
end

