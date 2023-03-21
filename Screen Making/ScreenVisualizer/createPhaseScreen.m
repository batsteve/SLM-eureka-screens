function [ outcode ] = createPhaseScreen( params, window, options, data )
%LOADPHASESCREEN Summary of this function goes here
%   Detailed explanation goes here


    magicFactor = params.getMagicFactor();

    I = normrnd(0,1, params.screenSize, params.screenSize);
    
    % convolution of window function with Gaussian Random Number
    GSB1x = conv2(window,I,'same');
    
    switch params.normalization
        case 'fullrange'
            GSB1 = GSB1x - min(min(GSB1x));
            GSB1 = GSB1./max(max(abs(GSB1)));
            
        case 'absolute'
            fprintf('Magic Factor: %f\n', magicFactor);
            fprintf('Max Val:      %f\n', max(abs(GSB1x(:))));
            GSB1 = GSB1x*(magicFactor/(2*pi));
            GSB1 = mod(GSB1, 1);
            
        otherwise
            warning('%s not recognized!\n', params.normalization)
    end
    
    data.rawScreen = exp(1i*GSB1*2*pi);

    outcode = 1;
    
end

