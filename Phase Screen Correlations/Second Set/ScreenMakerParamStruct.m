classdef ScreenMakerParamStruct
    %SCREENMAKERPARAMSTRUCT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numScreens  = 8000;
        outputFolder  = 'output\test\';
        screenSize = 256;
        screenType = 'mgsm';
        normalization = 'fullrange';
        
        N = 1;
        M = 40; 
        Corr_width_2 = 16;
        
        deltax = 2;   % ring thickness
        Beta = 3;     % ring radius
    end
    
    methods
        function [ filePrefix ] = getFilePrefix( params )
            switch params.screenType
                case 'mgsm'
                    filePrefix = sprintf('MGSM_%d_c_width_M_%d_USNA_', ...
                        params.Corr_width_2, params.M);  

                case 'ring'
                    filePrefix = sprintf('ring_B%s_D%s_USNA_', ...
                        num2str(params.Beta), num2str(params.deltax));

                otherwise
                    filePrefix = 'error';
            end
        end
        
        function [ magicFactor ] = getMagicFactor( params )
            magicFactor = params.screenSize^3;
        end
    end
    
end

