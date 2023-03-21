options = PhaseScreenOptions();
output = OutputOptions();

slmSize = 256;
M = 40;
delta = 46;
exactDelta = 2^(5.5);


%output.filePrefix = sprintf('mgsm_M_%d_D_%d_SLM_%d', M, delta, slmSize);
output.paddedScreenPath = sprintf('Output\\Corr Sets\\MGSM_M_%d_D_%d_SLM_%d\\', M, delta, slmSize);
output.outputPath = sprintf('Output\\Corr Sets\\MGSM_M_%d_D_%d_SLM_%d\\', M, delta, slmSize);
% output.screenPath = sprintf('D:\\Matlab\\Phase Screen Making\\output\\%d_mgsm_M_%d_D_%d\\', slmSize, M, delta);
% output.screenName = sprintf('MGSM_%d_c_width_M_%d_USNA_', exactDelta, M);

output.filePrefix = sprintf('ring_B_%d_D_%d_SLM_%d', B, D, slmSize);
output.screenPath = sprintf('D:\\Matlab\\Phase Screen Making\\output\\Ring_D_%d_B_%d\\', D, B);
output.screenName = sprintf('ring_B%d_D%d_USNA_', B, D);

%output.screenPath = sprintf('D:\\Matlab\\Phase Screen Making\\output\\mgsm_M_%d_D_%d_SLM_%d\\', M, delta, slmSize);
%output.screenName = sprintf('MGSM_32_c_width_M_40_USNA_');

output.outputPath = 'Output\Test\\';

mkdir(output.paddedScreenPath);
mkdir(output.outputPath);
mkdir(output.screenPath);


options.xRawSize = slmSize;
options.yRawSize = slmSize;
options.xBlowupFactor = 1;  options.yBlowupFactor = 1;
options.xOutsideFactor = 0; options.yOutsideFactor = 0;
options.xBevelSize = 0;     options.yBevelSize = 0;
%options.printResolution = '-r1000';
output.printResolution = '-r128';
output.figSize = 640;

options.xBeamCenter = 0.0; options.yBeamCenter = 0.0;
options.beamRadius = 2*18.283847/80;

options.hfDistance = 15.44;
options.hfOutputSizeXReal = 0.06;
options.hfOutputSizeYReal = 0.06;
options.hfInputSizeXReal = 0.00614;
options.hfInputSizeYReal = 0.00614;
options.hfOutputSizeX = 16;
options.hfOutputSizeY = 16;

options.recalculateDerivedStatistics();

%output.makeInvisibleFigures = false;
output.clearFigureWhenFinished = false;
output.drawFarFieldZoom = false;
output.saveDomain = 'quarter';
options.paddedMaxIntensity = 0.05;

for k = 1:1 
    data = DataStruct();
    data.n = k;

    loadPhaseScreen(options, output, data);
    cBeam(options, data);
    cPaddedScreen(options, data);
    %savePaddedScreens(options, data);
    %loadPaddedScreens(options, data);
    %cFFTFarField(options, data);
    cHFFarField(options, data);
    %saveFarField(options, output, data);
    saveFarFieldIntensity(options, output, data);
    %dPhaseScreenPlots(options, output, data);
    %cEstimatePowerDistribution(options, data, results);
    %dCumulativePowerDistribution(options, data);
    
    figure(329);
    clf
    pcolor(abs(data.farField).^2)
    shading flat
    colorbar()
    %caxis([0 1e-3]);
end

outcode = 1;
