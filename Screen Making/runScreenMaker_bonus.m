% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\Ring_D_2_B_3\';
% mkdir output\Ring_D_2_B_3
% params.screenType = 'ring';
% params.deltax = 2;
% params.Beta = 3;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\Ring_D_8_B_12\';
% mkdir output\Ring_D_8_B_12
% params.screenType = 'ring';
% params.deltax = 8;
% params.Beta = 12;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\Ring_D_4_B_6\';
% mkdir output\Ring_D_4_B_6
% params.screenType = 'ring';
% params.deltax = 4;
% params.Beta = 6;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\mgsm_M_40_D_8\';
% mkdir output\mgsm_M_40_D_8
% params.screenType = 'mgsm';
% params.M = 40;
% params.Corr_width_2 = 8;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\mgsm_M_40_D_16\';
% mkdir output\mgsm_M_40_D_16
% params.screenType = 'mgsm';
% params.M = 40;
% params.Corr_width_2 = 16;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\mgsm_M_40_D_32\';
% mkdir output\mgsm_M_40_D_32
% params.screenType = 'mgsm';
% params.M = 40;
% params.Corr_width_2 = 32;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\mgsm_M_40_D_64\';
% mkdir output\mgsm_M_40_D_64
% params.screenType = 'mgsm';
% params.M = 40;
% params.Corr_width_2 = 64;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\mgsm_M_40_D_128\';
% mkdir output\mgsm_M_40_D_128
% params.screenType = 'mgsm';
% params.M = 40;
% params.Corr_width_2 = 128;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );
% 
% 
% 
% params = ScreenMakerParamStruct();
% params.outputFolder = 'output\mgsm_M_1_D_16\';
% mkdir output\mgsm_M_1_D_16
% params.screenType = 'mgsm';
% params.M = 1;
% params.Corr_width_2 = 16;
% kernel = kernelMaker( params );
% screenMaker( params, kernel );


EE = [4:.5:7];
DD = 2.^EE;
for D = DD
    params = ScreenMakerParamStruct();
    params.outputFolder = sprintf('output\\512_mgsm_M_40_D_%d\\', ceil(D));
    mkdir(sprintf('output\\512_mgsm_M_40_D_%d', ceil(D)));
    params.screenType = 'mgsm';
    params.M = 40;
    params.Corr_width_2 = D;
    params.screenSize = 512;
    kernel = kernelMaker( params );
    screenMaker( params, kernel );
end