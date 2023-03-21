function [ outcode ] = cFarField( options, data )
%CFARFIELD Summary of this function goes here
%   Detailed explanation goes here

    tic
    
    fprintf('Beginning calculation of far field.');
    
    data.farFieldFromRaw = fftshift(fft2(data.rawBeam.*data.rawScreen));
    
    data.farFieldFromPadded = fftshift(fft2(data.paddedBeam.*data.paddedScreen));
    
    fprintf('  Done after %d seconds.\n', ceil(toc));

    outcode = 1;

end

