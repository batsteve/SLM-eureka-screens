function [ outcode ] = cEstimatePowerDistribution( options, data, results )
%CESTIMATEPOWERDISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

    tic;
    fprintf('Estimating power distribution.\n');

    fftFactor = options.xFullSize*options.yFullSize;

    %XXring = ceil(options.xOffsetFarField+1):floor(options.xFullSize-options.xOffsetFarField);
    %YYring = ceil(options.xOffsetFarField+1):floor(options.yFullSize-options.yOffsetFarField);
    XXring = ceil(options.xOffsetFarField+1):options.xFarFieldSize;
    YYring = ceil(options.xOffsetFarField+1):options.yFarFieldSize;
    
    XXspot = ceil(options.xFullSize/2 - options.xHotspotRadius):floor(options.xFullSize/2 + options.xHotspotRadius);
    YYspot = ceil(options.yFullSize/2 - options.yHotspotRadius):floor(options.yFullSize/2 + options.yHotspotRadius);

    XXvertCross = XXspot;
    YYvertCross = YYring;
    
    XXhorzCross = XXring;
    YYhorzCross = YYspot;
    
    totalInputPower = sum(abs(data.paddedBeam(:)).^2)*fftFactor;
    totalOutputPower = sum(abs(data.farFieldFromPadded(:)).^2);  
    totalZeroOrderPower = sum(sum(abs(data.farFieldFromPadded(XXring, YYring)).^2));    
    totalHotspotPower = sum(sum(abs(data.farFieldFromPadded(XXspot, YYspot)).^2));
    
    horzCrossPower = sum(sum(abs(data.farFieldFromPadded(XXhorzCross, YYhorzCross)).^2));
    vertCrossPower = sum(sum(abs(data.farFieldFromPadded(XXvertCross, YYvertCross)).^2));
    totalCrossPower = horzCrossPower + vertCrossPower - totalHotspotPower;
    
    results.fractionTransmitted = totalOutputPower/totalInputPower;
    results.fractionDiffracted = (totalOutputPower-totalZeroOrderPower)/totalOutputPower;
    results.fractionRing = (totalZeroOrderPower-totalCrossPower)/totalOutputPower;
    results.fractionCross = (totalCrossPower - totalHotspotPower)/totalOutputPower;
    results.fractionHotSpot = totalHotspotPower/totalOutputPower;
    
    
    fprintf('\n');
    fprintf('Fraction Power transmitted:                  %f.\n', results.fractionTransmitted);
    fprintf('Fraction Power in higher diffraction modes:  %f.\n', results.fractionDiffracted);
    fprintf('Fraction Power in ring:                      %f.\n', results.fractionRing);
    fprintf('Fraction Power in diffraction cross:         %f.\n', results.fractionCross);
    fprintf('Fraction Power in hot spot:                  %f.\n', results.fractionHotSpot);
    fprintf('\n');
    
    fprintf('Power distribution estimated in %d seconds.\n', ceil(toc));
    
    outcode = 1;

end

