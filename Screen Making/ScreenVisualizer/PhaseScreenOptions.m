classdef PhaseScreenOptions < handle
    %PHASESCREENOPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        screenPath;
        screenName;
        paddedScreenPath;
        outputPath;
        filePrefix;
        
        xRawSize;
        yRawSize;
        
        xBlockSize;
        yBlockSize;
        
        xBlowupFactor;
        yBlowupFactor;
        
        xOutsideFactor;
        yOutsideFactor;
        
        xBevelSize;
        yBevelSize;
        
        xOffset;
        yOffset;
        
        xInnerSize;
        yInnerSize;
        
        xFullSize;
        yFullSize;
        
        xFarFieldSize
        yFarFieldSize
        
        xOffsetFarField;
        yOffsetFarField;
        
        xHotspotRadius;
        yHotspotRadius;
        
        xInnerRingRadius;
        yInnerRingRadius;
        
        xOuterRingRadius;
        yOuterRingRadius;
        
        xBeamCenter;
        yBeamCenter;
        
        beamType;
        beamRadius;
        
        bevelTransmittance;
        exteriorTransmittance;
        
        rawMaxIntensity;
        paddedMaxIntensity;
        
        paddingMethod;
        
        drawRawScreen;
        drawPaddedScreen;
        drawRawFarField;
        drawPaddedFarField;
        drawPaddedFarFieldZoom;
        
        drawCumulativeRadialPower;
        drawDifferentialRadialPower;
        
        includePlotTitles;
        clearFigureWhenFinished;
        figSize;
        makeInvisibleFigures;
        printResolution;
    end
    
    methods
        function opt = PhaseScreenOptions()
            opt.screenPath = 'ring D4 B4\';
            opt.paddedScreenPath = 'PaddedScreens\';
            opt.screenName = 'ring B4 D4 ';
            opt.outputPath = 'Output\';
            opt.filePrefix = 'run_1';
            
            opt.xRawSize = 256;
            opt.yRawSize = 256;

            opt.xBlowupFactor = 10;
            opt.yBlowupFactor = 10;

            opt.xOutsideFactor = 3;
            opt.yOutsideFactor = 3;

            opt.xBevelSize = 1;
            opt.yBevelSize = 1;
            
            opt.xBeamCenter = 0;
            opt.yBeamCenter = 0;
            
            opt.bevelTransmittance = 0;
            opt.exteriorTransmittance = 0;
            
            opt.includePlotTitles = true;
            opt.clearFigureWhenFinished = false;
            opt.figSize = 1600;
            opt.makeInvisibleFigures = false;
            opt.printResolution = '-r1000';
            
%             opt.xOffset = opt.xRawSize*(opt.xBlowupFactor) + ...
%                          (opt.xRawSize-1)*(opt.xBevelSize);
%             opt.yOffset = opt.yRawSize*(opt.yBlowupFactor) + ...
%                          (opt.yRawSize-1)*(opt.yBevelSize);
      
                        
            opt.beamType = 'gaussian';
            opt.beamRadius = 0.25;
            
            opt.paddingMethod = 'travelling raw';
            
            opt.drawRawScreen = true;
            opt.drawPaddedScreen = true;
            opt.drawRawFarField = true;
            opt.drawPaddedFarField = true;
            opt.drawPaddedFarFieldZoom = true;
            
            opt.drawCumulativeRadialPower = true;
            opt.drawDifferentialRadialPower = true;
            
            opt.recalculateDerivedStatistics();
        end
        
        function [ outcode ] = recalculateDerivedStatistics(opt) 
            opt.xBlockSize = opt.xBlowupFactor + opt.xBevelSize;
            opt.yBlockSize = opt.yBlowupFactor + opt.yBevelSize;
            
            opt.xInnerSize = opt.xRawSize*(opt.xBlowupFactor) + ...
                (opt.xRawSize+1)*(opt.xBevelSize);
            
            opt.yInnerSize = opt.yRawSize*(opt.yBlowupFactor) + ...
                (opt.yRawSize+1)*(opt.yBevelSize); 
            
            opt.xOffset = opt.xInnerSize*opt.xOutsideFactor;
            opt.yOffset = opt.yInnerSize*opt.xOutsideFactor;

            opt.xFullSize = opt.xInnerSize*(1+2*opt.xOutsideFactor);
            opt.yFullSize = opt.yInnerSize*(1+2*opt.yOutsideFactor);
            
            opt.xFarFieldSize = ceil(opt.xFullSize/opt.xBlockSize);
            opt.yFarFieldSize = ceil(opt.yFullSize/opt.yBlockSize);
            
            opt.xOffsetFarField = ceil((1/2)*(opt.xFullSize - opt.xFarFieldSize));
            opt.yOffsetFarField = ceil((1/2)*(opt.yFullSize - opt.yFarFieldSize));
            
            opt.xHotspotRadius = ceil((1/64)*opt.xFarFieldSize);
            opt.yHotspotRadius = ceil((1/64)*opt.yFarFieldSize);
            
            opt.xInnerRingRadius = ceil((6/64)*opt.xFarFieldSize);
            opt.yInnerRingRadius = ceil((6/64)*opt.yFarFieldSize);
            
            opt.xOuterRingRadius = ceil((14/64)*opt.xFarFieldSize);
            opt.yOuterRingRadius = ceil((14/64)*opt.yFarFieldSize);
            
            opt.rawMaxIntensity = opt.xRawSize*opt.yRawSize*5;
            %opt.paddedMaxIntensity = (opt.xInnerSize*opt.yInnerSize)^2/(opt.xFarFieldSize*opt.yFarFieldSize)*20;
            opt.paddedMaxIntensity = opt.xInnerSize*opt.yInnerSize*opt.xBlowupFactor*opt.yBlowupFactor*5;
            
            outcode = 0;
        end
    end
    
end

