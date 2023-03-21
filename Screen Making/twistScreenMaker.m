function [ outcode ] = screenMaker( params, window )
%RUNSCREENMAKER Summary of this function goes here
%   Instantiate the noise component, create the screen, and save it

    magicFactor = params.getMagicFactor();

    for k = 1:params.numScreens
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
        
        GSB2 = transpose(GSB1);
        GSB3 = rot90(GSB1);
        GSB4 = rot90(GSB1, 3);
    
        filename = sprintf('%sStraight\\%s%d.bmp', params.outputFolder, params.getFilePrefix(), k);
        imwrite(GSB1, filename, 'bmp');
        
        filename = sprintf('%sFlip\\%s%d.bmp', params.outputFolder, params.getFilePrefix(), k);
        imwrite(GSB2, filename, 'bmp');
        
        filename = sprintf('%sTwist\\%s%d.bmp', params.outputFolder, params.getFilePrefix(), k);
        imwrite(GSB3, filename, 'bmp');
        
        filename = sprintf('%sTwist_2\\%s%d.bmp', params.outputFolder, params.getFilePrefix(), k);
        imwrite(GSB4, filename, 'bmp');
    end

    outcode = 1;
end

