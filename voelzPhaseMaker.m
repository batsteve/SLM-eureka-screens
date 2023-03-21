% Stephen Guth, USNA, 9/28/2015, implementing Hyde, Basu, Voelz, and Xiao
% (2015).
%
% Script to generate sawtooth-displaced mgsm phase screens
%
% Define terms:
%
% mask - the full size grid controlling phase
% saw - the full size grid controlling amplitude
% F - the full size grid correcting the phase distortions due to saw
% screen - the full grid controlling both phase and amplitde

N = 256;            % SLM grid size
d = 8;              % Sawtooth length
l = 5;
delta2 = 256;
M = 40;
Ufactor = 0.7;      % Voodoo from the blackest depths
numScreens = 100;
outputFolder = sprintf('Output\\Saw_vortex_%d_d2_%d\\', l, delta2);
mkdir(outputFolder);

reducedN = floor(N/d);
[xx, yy] = ndgrid(1:N, 1:N);

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
% Make the convolution kernal for the mgsm phase relations
%

r = size(xx, 1)/2;       % choose center of grid
c = size(yy, 2)/2;
rho = sqrt((xx-r).^2 + (yy-c).^2);
rho2 = (xx-r).^2 + (yy-c).^2;
theta = atan2(xx-r, yy-c);

windowx = zeros(size(rho));
windowx = exp(-rho2/(2*delta2));
% prefactor = -sqrt(1/(2*pi))*rho/sqrt(delta2).*exp(-rho2/(4*delta2));
% for m = 1:1:M;                             % add in additional windows
%     window_m = prefactor.*(1/m)*(-1i)^(m*l).*sin(m*l*theta).*...
%          (besselj((m*l-1)/2, rho2/(4*delta2)) - besselj((m*l+1)/2, rho2/(4*delta2)));
%     
%     windowx = windowx + window_m;
% end

windowv = (-1i)^l*pi^(1/2)*rho/(2*sqrt(2)*sqrt(delta2)).*exp(-rho2/(4*delta2)).*...
    (besselj((l-1)/2, rho2/(4*delta2)) - besselj((l+1)/2, rho2/(4*delta2))).*cos(l*theta);
windowx = windowx + windowv;

%window = windowx/cc;
window = windowx;
fullNormFactor = sum(window(:));
kernel = window/fullNormFactor;
sqrtPhi = fft2(kernel);

for k = 1:numScreens
    
    %
    % Fourier method for randomness
    %
    
    r = randn(N, N) + 1i*randn(N, N);
    mask = ifft2(r.*sqrtPhi);
    
    maskPhase = angle(mask);
    
    %
    % Put it all together
    %
    
    screen = mod(maskPhase, 2*pi);
    sawScreen = mod(maskPhase + sawPhase + FPhase, 2*pi);
    figname = sprintf('%svoelz_phase_l_%d_d2_%d_num_%d.bmp', outputFolder, ...
        l, delta2, k);
    %figname = sprintf('%svoelz_vortex_l_%d_d2_%d_num_%d.bmp', outputFolder, ...
    %    l, delta2, k);
    imwrite(sawScreen/(2*pi),figname, 'bmp');
end


%
% Simulation Stuff
%

doSim = true;
if doSim
    A = 1;
    b = N/4;
    rr2 = ((xx-N/2).^2 + (yy-N/2).^2);
    gBeam = A*exp(-rr2/b^2);    % Gaussian illumination of SLM
    uBeam = ones(size(rr2));    % Uniform illumination of SLM
    beam = gBeam;
    beam = beam/sum(beam(:));   % Normalization for prettier plotting

    noSawFarField = fftshift(fft2(exp(1i*screen).*beam));
    noSawFarIntensity = abs(noSawFarField).^2;

    sawFarField = fftshift(fft2(exp(1i*sawScreen).*beam));
    sawFarIntensity = abs(sawFarField).^2;

    figure(1);
    clf;
    pcolor(abs(sawScreen));
    shading flat
    title('phase screen')
    colorbar();

    maxIntensity = max(max(noSawFarIntensity(:)), max(sawFarIntensity(:)));

    figure(2)
    clf
    pcolor(noSawFarIntensity);
    shading flat
    title('no saw far field intensity');
    caxis([0 maxIntensity*1e-1])
    colorbar();

    figure(3)
    clf
    pcolor(sawFarIntensity);
    shading flat
    title('saw far field intensity');
    caxis([0 maxIntensity*1e-1])
    colorbar();
end