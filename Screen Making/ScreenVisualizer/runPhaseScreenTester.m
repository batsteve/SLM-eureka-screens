%magicVals = linspace(0.2, 2, 19);
magicVals = [1];

for k = 1:length(magicVals)
    options = PhaseScreenOptions();
    options.filePrefix = sprintf('run_%d', k);
    
    options.xBlowupFactor = 1;
    options.yBlowupFactor = 1;
    options.xOutsideFactor = 1;
    options.yOutsideFactor = 1;
    options.xBevelSize = 0;
    options.yBevelSize = 0;
    %options.printResolution = '-r1000';
    options.printResolution = '-r128';
    options.xRawSize = 512;
    options.yRawSize = 512;
    
    options.xBeamCenter = 0.0;
    options.yBeamCenter = 0.0;
    options.beamRadius = 0.35;
    
    options.recalculateDerivedStatistics();
    
    options.drawPaddedScreen = false;
    options.drawPaddedFarField = false;
    %options.makeInvisibleFigures = false;
    options.clearFigureWhenFinished = false;
    
    params = ScreenMakerParamStruct();
    params.screenSize = 512;
    params.screenType = 'ring';
    params.normalization = 'absolute';
    params.numScreens = magicVals(k);
    params.deltax = 2;
    params.Beta = 3;
    kernel = kernelMaker( params );
    
    data = DataStruct();
    data.n = k;
    
    %results = ResultsStruct();
    
    
    %dEstimateMemoryUsage(options);
    createPhaseScreen(params, kernel, options, data);
    cBeam(options, data);
    cPaddedScreen(options, data);
    %savePaddedScreens(options, data);
    %loadPaddedScreens(options, data);
    cFarField(options, data);
    %saveFarField(options, data);
    dPhaseScreenPlots(options, data);
    %cEstimatePowerDistribution(options, data, results);
    %dCumulativePowerDistribution(options, data);
end

