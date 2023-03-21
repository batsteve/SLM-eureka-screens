function [ screen ] = screenMaker( params, window )
%RUNSCREENMAKER Summary of this function goes here
%   Instantiate the noise component, create the screen, and save it

    magicFactor = params.getMagicFactor();

        I = normrnd(0,1, params.screenSize, params.screenSize);
    
        % convolution of window function with Gaussian Random Number 
        GSB1x = conv2(window,I,'same');
        
        switch params.normalization
            case 'fullrange'
                GSB1 = GSB1x - min(min(GSB1x));
                GSB1 = GSB1./max(max(abs(GSB1)));
                
            case 'absolute'
                GSB1 = GSB1x*(magicFactor/(2*pi));
                GSB1 = mod(GSB1, 1);
                
            otherwise
                warning('%s not recognized!\n', params.normalization)
        end
    
        %filename = sprintf('%s%s%d.bmp', params.outputFolder, params.getFilePrefix(), k);
        %imwrite(GSB1, filename, 'bmp');
        
        screen = GSB1x;

    %outcode = 1;
end

