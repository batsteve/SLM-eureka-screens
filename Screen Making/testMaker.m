% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\test\';
% mkdir output\test
% params.screenType = 'ring';
% params.normalization = 'absolute';
% params.numScreens = 1;
% params.deltax = 2;
% params.Beta = 3;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );

params = ScreenMakerParamStruct();
params.outputFolder = 'output\mgsm_M_40_D_256\';
mkdir output\mgsm_M_40_D_256
params.screenType = 'mgsm';
params.M = 40;
params.Corr_width_2 = 256;
kernel = kernelMaker( params );
screenMaker( params, kernel );