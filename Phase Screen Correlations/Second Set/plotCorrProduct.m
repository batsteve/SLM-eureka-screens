function [ outcode ] = plotCorrProduct( corrProduct )
%PLOTCORRPRODUCT Summary of this function goes here
%   Detailed explanation goes here

    figure(103);
    clf;
    subplot(2, 2, 1);
    pcolor(real(corrProduct));
    title('real');
    shading flat
    colorbar();

    subplot(2, 2, 2);
    pcolor(imag(corrProduct));
    title('imaginary');
    shading flat
    colorbar();

    subplot(2, 2, 3);
    pcolor(abs(corrProduct));
    title('modulus');
    shading flat
    colorbar();

    subplot(2, 2, 4);
    pcolor(angle(corrProduct));
    title('angle');
    shading flat
    colorbar();

    outcode = 1;

end

