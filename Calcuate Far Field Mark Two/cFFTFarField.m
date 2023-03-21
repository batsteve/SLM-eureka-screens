function [ outcode ] = cFFTFarField( options, data )
%CFARFIELD Summary of this function goes here
%   Detailed explanation goes here

    tic
    
    fprintf('Beginning FFT calculation of far field.');
    
    data.farField = fftshift(fft2(data.incidentBeam.*data.screen));
    
    fprintf('  Done after %d seconds.\n', ceil(toc));

    outcode = 1;

end

