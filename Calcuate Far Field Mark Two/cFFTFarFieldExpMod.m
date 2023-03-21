function [ outcode ] = cFFTFarFieldExpMod( options, data )
%CFARFIELD Summary of this function goes here
%   Detailed explanation goes here

    tic
    
    fprintf('Beginning FFT calculation of far field.');
    [XX, YY] = ndgrid(1:size(data.screen, 1), 1:size(data.screen, 2));
    RR2 = XX.^2 + YY.^2;
    L = 15.44;
    k = 2*pi/(633e-9);
    A = (6.14e-3/size(XX, 1));
    expTerm = exp(1i*k*RR2*A^2/(2*L));
    %expTerm = exp(1i*RR2*1e-3);
    
    data.farField = fftshift(fft2(data.incidentBeam.*data.screen.*expTerm));
    
    fprintf('  Done after %d seconds.\n', ceil(toc));

    outcode = 1;

end

