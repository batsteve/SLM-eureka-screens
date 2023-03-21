path = 'Screens\L=750_C=1e13';
kkk = 1;
filename = sprintf('%s\\Zturb_%04d.bmp', path, kkk);
bitmap = imread(filename);
screen = double(bitmap)/256;

figure(1);
pcolor(screen);
title('Phase Screen');
shading flat;

[XX, YY] = ndgrid(1:256, 1:256);
beam = 1e4*exp(-( (XX-128).^2/16 + (YY-128).^2/16));

farField = abs(fft2(beam.*exp(1i*2*pi*screen))).^2;
farField = fftshift(farField);

figure(2);
pcolor(farField);
title('Effects of Phase Screen on Gaussian Beam');
shading flat;