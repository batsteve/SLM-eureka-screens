classdef ParamStruct < handle
    %PARAMSTRUCT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xNumBlocks = 8;
        yNumBlocks = 8;
        xBlockSize = 32;
        yBlockSize = 32;
        blackVal = 1;
        whiteVal = -1;
        numFlips = 1024;
        
        corrDistances = [0:1:80];
        
        filterXRad = 128;
        filterYRad = 128;
        filterWidth = 0.35;
        %filterScale = 1;
    end
    
    methods
    end
    
end

