% Stephen Guth, USNA, 12/03/2015, implementing Hyde, Basu, Voelz, and Xiao
% (2015).
%
% Script to generate sawtooth-displaced [mgsm] phase screens
%
% Define terms:
%
% mask - the full size grid controlling phase
% saw - the full size grid controlling amplitude
% F - the full size grid correcting the phase distortions due to saw
% screen - the full grid controlling both phase and amplitde
% reducedN - the "small grid" over which the saw heights are defined.  In
%   practice, we don't care much about this.
% kernel - also window, the coherence function convolved with random noise
%   to produce the grid phi_0

%
% Algorithm steps:
% 1) Set parameters
% 2) Create the window function (or kernel)
% 3) Voodoo magic to find h(x, y)  [Not important]
% 4) Create the sawtooth using h(x, y)
% 5) Create the sawtooth correction
% 6) Create and save each screen by convoling the kernel with circularly
%   complex Gaussian noise, and then adding the sawtooth and sawtooth
%   correction
% 7) Plots!
%

N = 256;            % SLM grid size
d = 8;              % Sawtooth length
Ufactor = 0.7;      % Voodoo from the blackest depths

M = 40;             % Puts the M in MGSM
Corr_width_2 = 16;  % MGSM correlation length squared, in pixels
deltax = 4;         % BGSM ring parameter
Beta = 4;           % BGSM ring parameter
l = 1;              % vortex parameter, roughly "number of turns"

numScreens = 1000;

reducedN = floor(N/d);
[xx, yy] = ndgrid(1:N, 1:N);

%
% Make the convolution kernal for the phase relations
% 'kernel' and 'window' are the same thing.
%

r = size(xx, 1)/2;       % choose center of grid
c = size(yy, 2)/2;
rho = sqrt((xx-r).^2 + (yy-c).^2);
rho2 = (xx-r).^2 + (yy-c).^2;
theta = atan2(xx-r, yy-c);

windowx = zeros(size(rho));
windowName = 'default';         % for output naming

kernelType = 'mgsm';
switch kernelType
    case 'mgsm'
        for m = 1:1:M;         % add in additional windows
            window_m = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m ...
                *exp(-rho.^2/(2*m*Corr_width_2));
            windowx = windowx + window_m;

            cc = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m;
        end
        windowName = sprintf('mgsm_%d_%d', Corr_width_2, M);
    
    case 'ring'
        param1 = Beta*rho/deltax;
        param2 = rho.^2/(2*deltax^2); 
        windowx = besselj(0,param1).*exp(-param2);
        windowName = sprintf('ring_%d_%d', deltax, Beta);
        
    case 'vortex'
        windowx = exp(-rho2/(2*Corr_width_2));
        prefactor = -sqrt(1/(2*pi))*rho/sqrt(Corr_width_2).* ...
            exp(-rho2/(4*Corr_width_2));
        for m = 1:1:M;        % add in additional windows
            window_m = prefactor.*(1/m)*(-1i)^(m*l).*sin(m*l*theta).*...
                 (besseli((m*l-1)/2, rho2/(4*Corr_width_2)) - ...
                  besseli((m*l+1)/2, rho2/(4*Corr_width_2)));

            windowx = windowx + window_m;
        end
        windowName = sprintf('vortex_%d_%d', l, Corr_width_2);
        
    case 'swirl'
        windowx = exp(-rho2/(2*Corr_width_2));
        windowv = (-1i)^l*pi^(1/2)*rho/(2*sqrt(2)*sqrt(Corr_width_2)).* ...
                exp(-rho2/(4*Corr_width_2)).*...
                    (besseli((l-1)/2, rho2/(4*Corr_width_2)) - ... 
                     besseli((l+1)/2, rho2/(4*Corr_width_2))).* ...
                cos(l*theta);
        windowx = windowx + windowv;
        windowName = sprintf('swirl_%d_%d', l, Corr_width_2);
        
    %
    % If you make a new window function, put it here in a new [case 'foo']
    % block.  Select if by changing [kernelType = 'foo'] above the switch
    % block.
    %
        
    otherwise
        warning('No instructions for making the %s kernel yet!', kernelType);
        
end

%
% Normalize the window function, then save its power spectrum.
%

window = windowx;
fullNormFactor = sum(window(:));
kernel = window/fullNormFactor;
sqrtPhi = fft2(kernel);

%
% Name the folder where the screens are gonna go
%

outputFolder = sprintf('Output\\Saw_%s\\', windowName);
mkdir(outputFolder);

%
% Calculate the amplitude relations.
%
% Inverting H (to go from field ratios to h) is not quite as simple as
% Voelz makes it out to be.
%
% I don't have much flexibility to pick U, and still get h to converge.  U
% must be less than or equal to 1.
%
% Voelz takes U from the complex screen amplitudes in a way that I don't
% entirely understand.  That step remains unimplemented.
%
% hbar = h/lambda;
%

U = Ufactor*ones(reducedN,reducedN);

H = @(x) sinc(pi*(1 - x));
x0 = 0.1; % guess
hbar = zeros(reducedN,reducedN);
for k = 1:reducedN
    for j = 1:reducedN
        hbar(k, j) = fzero( @(x)(H(x)-U(k,j)), x0 );
    end
end

%
% Build the saw
%

sawInterval = linspace(0, 1, d);
[sawXX, sawYY] = ndgrid(sawInterval, sawInterval);
sawTemplate = (sawXX+sawYY)*pi*2;

saw = zeros(N, N);
for k = 1:reducedN
    for j = 1:reducedN
        sawBlockXX = (k-1)*d + (1:d);
        sawBlockYY = (j-1)*d + (1:d);
        saw(sawBlockXX, sawBlockYY) = sawTemplate*hbar(k,j);
    end
end
sawPhase = saw;

%
% Correct the phase from the saw distortion
%

F = zeros(N, N);
for k = 1:reducedN
    for j = 1:reducedN
        sawBlockXX = (k-1)*d + (1:d);
        sawBlockYY = (j-1)*d + (1:d);
        F(sawBlockXX, sawBlockYY) = exp(-1i*pi*(1-hbar(k, j)));
    end
end
FPhase = angle(F);


%
% Making the comparison stuff
%

hydeFourierPhaseOnlyCross = zeros(numScreens, N);
hydeFourierPhaseAmpCross = zeros(numScreens, N);
hydeConvPhaseOnlyCross = zeros(numScreens, N);
hydeConvPhaseAmpCross = zeros(numScreens, N);
oldSvetlanaAmpFullCross = zeros(numScreens, N);
oldSvetlanaAmpToPhaseCross = zeros(numScreens, N);
stephenUIICross = zeros(numScreens, N);
%theoryCross = zeros(numScreens, N);



A = 1;          % normalization thing
b = N/4;        % incoming beam radius
rr2 = ((xx-N/2).^2 + (yy-N/2).^2);
gBeam = A*exp(-rr2/b^2);    % Gaussian illumination of SLM
uBeam = ones(size(rr2));    % Uniform illumination of SLM
beam = gBeam;
beam = beam/sum(beam(:));   % Normalization for prettier plotting

cXX = (floor(N/2));
cYY = (1:N);

for k = 1:numScreens    
    realR = randn(N, N);
    imagR = 1i*randn(N, N);
    r = realR + imagR;
    angleR = angle(r);
    
    
    mask = ifft2(r.*sqrtPhi);
    maskPhase = angle(mask);
    screen = mod(maskPhase, 2*pi);
    farField = fftshift(fft2(exp(1i*screen).*beam));
    farIntensity = abs(farField).^2;
    hydeFourierPhaseOnlyCross(k, :) = farIntensity(cXX, cYY);
    
    mask = ifft2(r.*sqrtPhi);
    farField = fftshift(fft2(mask));
    farIntensity = abs(farField).^2;
    hydeFourierPhaseAmpCross(k, :) = farIntensity(cXX, cYY);
    
    mask = conv2(r, kernel, 'same');
    maskPhase = angle(mask);
    screen = mod(maskPhase, 2*pi);
    farField = fftshift(fft2(exp(1i*screen).*beam));
    farIntensity = abs(farField).^2;
    hydeConvPhaseOnlyCross(k, :) = farIntensity(cXX, cYY);
    
    mask = conv2(R, kernel, 'same');
    farField = fftshift(fft2(mask));
    farIntensity = abs(farField).^2;
    hydeConvPhaseAmpCross(k, :) = farIntensity(cXX, cYY);
    
    
    mask = conv2(realR, kernel, 'same');
    farField = fftshift(fft2(mask));
    farIntensity = abs(farField).^2;
    oldSvetlanaAmpFullCross(k, :) = farIntensity(cXX, cYY);
    
    mask = conv2(realR, kernel, 'same');
    mask = (mask-min(mask(:)))/max(mask(:));
    farField = fftshift(fft2(exp(1i*2*pi*mask)));
    farIntensity = abs(farField).^2;
    oldSvetlanaAmpToPhaseCross(k, :) = farIntensity(cXX, cYY);
    
    mask = conv2(exp(1i*angleR), kernel, 'same');
    screen = angle(mask);
    farField = fftshift(fft2(exp(1i*screen).*beam));
    farIntensity = abs(farField).^2;
    stephenUIICross(k, :) = farIntensity(cXX, cYY);
    
    fprintf('k = %d\n', k);
end



hydeFourierPhaseOnlyCrossMean = mean(hydeFourierPhaseOnlyCross, 1)*2;
hydeFourierPhaseAmpCrossMean =  mean(hydeFourierPhaseAmpCross, 1)*2;
hydeConvPhaseOnlyCrossMean =  mean(hydeConvPhaseOnlyCross, 1)*2;
hydeConvPhaseAmpCrossMean =  mean(hydeConvPhaseAmpCross, 1)*2;
oldSvetlanaAmpFullCrossMean =  mean(oldSvetlanaAmpFullCross, 1)*2;
oldSvetlanaAmpToPhaseCrossMean =  mean(oldSvetlanaAmpToPhaseCross, 1)*2;
stephenUIICrossMean = mean(stephenUIICross, 1)*2;

hydeFourierPhaseOnlyCrossMean = hydeFourierPhaseOnlyCrossMean/max(hydeFourierPhaseOnlyCrossMean(:));
hydeFourierPhaseAmpCrossMean = hydeFourierPhaseAmpCrossMean/max(hydeFourierPhaseAmpCrossMean(:));
hydeConvPhaseOnlyCrossMean = hydeConvPhaseOnlyCrossMean/max(hydeConvPhaseOnlyCrossMean(:));
hydeConvPhaseAmpCrossMean = hydeConvPhaseAmpCrossMean/max(hydeConvPhaseAmpCrossMean(:));
oldSvetlanaAmpFullCrossMean = oldSvetlanaAmpFullCrossMean/max(oldSvetlanaAmpFullCrossMean(:));
oldSvetlanaAmpToPhaseCrossMean = oldSvetlanaAmpToPhaseCrossMean/max(oldSvetlanaAmpToPhaseCrossMean(:));
stephenUIICrossMean = stephenUIICrossMean/max(stephenUIICrossMean(:));

pixelScale = (6.04e-3)/256;
z = 10;
d2 = Corr_width_2*pixelScale^2;
sigma = (6.04e-3)/4;
RR = ((1:N)-N/2 -1)*pixelScale*z*4.5;
lambda = 632e-9;
beamIntensity = zeros(length(RR), 1);
for j = 1:length(RR)
        %p1 = [RR(j), 0, LL];
        x1 = RR(j);
        y1 = 0;
        val1 = calcMGSMCrossCorrelation(x1, y1, x1, y1, z, d2, M, sigma, lambda);
        beamIntensity(j) = abs(val1)^2;
end
theoryProfile = beamIntensity/beamIntensity(ceil(N/2));


names = cell(8, 1);
names{1} = 'FFT Phase only';
names{2} = 'FFT Phase and Amplitude';
names{3} = 'Convolution Phase only';
names{4} = 'Convolution Phase and Amplitude';
names{5} = 'Real Convolution Amplitude only';
names{6} = 'Real Convolution Bounded to Phase';
names{7} = 'Phase Convolution Phase Only';
names{8} = 'Analytical';

figure(1);
clf;
hold on
plot(hydeFourierPhaseOnlyCrossMean, 'Color', 'red', 'LineWidth', 2);
plot(hydeFourierPhaseAmpCrossMean, 'Color', 'blue', 'LineWidth', 2);
plot(hydeConvPhaseOnlyCrossMean, 'Color', 'green', 'LineWidth', 2);
plot(hydeConvPhaseAmpCrossMean, 'Color', 'yellow', 'LineWidth', 2);
plot(oldSvetlanaAmpFullCrossMean, 'Color', 'magenta', 'LineWidth', 2);
plot(oldSvetlanaAmpToPhaseCrossMean, 'Color', 'cyan', 'LineWidth', 2);
plot(stephenUIICrossMean, 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
plot(theoryProfile, 'Color', 'black', 'LineWidth', 2);
legend(names);
title(sprintf('MGSM cross section \\delta^2=%d M=%d', Corr_width_2, M));
xlim([50 216])
hold off

figure(2);
clf;
hold on
plot(log(hydeFourierPhaseOnlyCrossMean), 'Color', 'red', 'LineWidth', 2);
plot(log(hydeFourierPhaseAmpCrossMean), 'Color', 'blue', 'LineWidth', 2);
plot(log(hydeConvPhaseOnlyCrossMean), 'Color', 'green', 'LineWidth', 2);
plot(log(hydeConvPhaseAmpCrossMean), 'Color', 'yellow', 'LineWidth', 2);
plot(log(oldSvetlanaAmpFullCrossMean), 'Color', 'magenta', 'LineWidth', 2);
plot(log(oldSvetlanaAmpToPhaseCrossMean), 'Color', 'cyan', 'LineWidth', 2);
plot(log(stephenUIICrossMean), 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
plot(log(theoryProfile), 'Color', 'black', 'LineWidth', 2);
legend(names);
title(sprintf('MGSM cross section \\delta^2=%d M=%d', Corr_width_2, M));
hold off