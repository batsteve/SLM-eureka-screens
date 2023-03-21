EE = [4:7];
DD = 2.^EE;
for D = DD
    params = ScreenMakerParamStruct();
    params.outputFolder = sprintf('output\\Twist Screens\\256_mgsm_M_40_D_%d\\', ceil(D));
    mkdir(sprintf('output\\Twist Screens\\256_mgsm_M_40_D_%d', ceil(D)));
    mkdir(sprintf('output\\Twist Screens\\256_mgsm_M_40_D_%d\\Straight', ceil(D)));
    mkdir(sprintf('output\\Twist Screens\\256_mgsm_M_40_D_%d\\Flip', ceil(D)));
    mkdir(sprintf('output\\Twist Screens\\256_mgsm_M_40_D_%d\\Twist', ceil(D)));
    mkdir(sprintf('output\\Twist Screens\\256_mgsm_M_40_D_%d\\Twist_2', ceil(D)));
    params.screenType = 'mgsm';
    params.M = 40;
    params.Corr_width_2 = D;
    params.screenSize = 256;
    params.numScreens = 8000;
    kernel = kernelMaker( params );
    twistScreenMaker( params, kernel );
end