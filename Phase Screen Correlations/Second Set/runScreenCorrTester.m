params = ScreenMakerParamStruct();
params.outputFolder = 'output\mgsm_M_40_D_256\';
%mkdir output\mgsm_M_40_D_256
params.screenType = 'mgsm';
params.M = 40;
params.Corr_width_2 = 256;
params.normalization = 'absolute';

kernel = kernelMaker( params );
screen = screenMaker( params, kernel );

%magicFactor = params.getMagicFactor();
%screen = screen*(magicFactor);

fprintf('Subtracting %f.\n', min(min(screen)));
screen = screen - min(min(screen));
fprintf('Dividing by %d.\n', max(abs(screen(:))));
screen = screen./max(abs(screen(:)));

xInt = 1:256;
yInt =  1:256;
[xx, yy] = ndgrid(xInt, yInt); 
rr2 = (xx-128).^2 + (yy-128).^2;
intensity = exp(-rr2/64^2);
phase = exp(1i*2*pi*screen);
corr = CalcCorrelationFunction(phase);

figure(99)
clf;
pcolor(abs(fftshift(fft2(intensity.*phase))).^2);
caxis([0 1e5])
shading flat

figure(100)
clf;
pcolor(screen)
shading flat
title('screen')
colorbar()

xSize = 128;
figure(101)
clf;
mesh(-xSize:xSize, -xSize:xSize, real(corr));
xlim([-xSize, xSize]);
ylim([-xSize, xSize]);
title('correlation');

kernelMax = kernel(128, 128);
figure(102)
clf;
mesh(-127:128, -127:128, kernel/kernelMax);
xlim([-xSize, xSize]);
ylim([-xSize, xSize]);
title('kernel');