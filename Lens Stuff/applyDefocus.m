function [ defocusedPattern ] = applyDefocus( pattern, filter, params )
%APPLYDEFOCUS Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Starting Blur.\n');
    
%     fprintf('Pattern size: %d, %d\n', size(pattern, 1), size(pattern, 2));
%     fprintf('Filter size: %d, %d\n', size(filter, 1), size(filter, 2));

%     patternSize = size(pattern);
%     defocusedPattern = conv(pattern(:), filter(:), 'same');
%     defocusedPattern = reshape(defocusedPattern, patternSize);


    defocusedPattern = zeros(size(pattern));
    for z = 1:params.numFlips
        defocusedPattern(:, :, z) = conv2(pattern(:, :, z), filter, 'same');
    end



end

