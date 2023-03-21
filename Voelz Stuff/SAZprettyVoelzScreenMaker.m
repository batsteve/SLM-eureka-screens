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

M = 40;             % Puts the M in MGSM *** CHANGE
Corr_width_2 = 64;  % MGSM correlation length squared, in pixels *** CHANGE
deltax = 4;         % BGSM ring parameter
Beta = 4;           % BGSM ring parameter
l = 1;              % vortex parameter, roughly "number of turns"

numScreens = 1;   % *** CHANGE

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

kernelType = 'mgsm';      % *** CHANGE
switch kernelType
    case 'mgsm'
        for m = 1:1:M;         % add in additional windows
            window_m = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m ...
                *exp(-rho.^2/(2*m*Corr_width_2));
            windowx = windowx + window_m;

            cc = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m;
        end
        windowName = sprintf('mgsm_%d_%d', Corr_width_2, M);    % *** CHANGE
    
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
% Make each screen
%

for k = 1:numScreens
    
    %
    % Fourier method for randomness.
    % If you prefer the convolution method, comment out the line with
    % ifft2() and replace it with the conv2() line
    %
    
    r = randn(N, N) + 1i*randn(N, N);
    mask = ifft2(r.*sqrtPhi);                % *** CHANGE
    oldMask = conv2(r, kernel, 'same');
    
    maskPhase = angle(mask);
    
    %
    % Put it all together -- Build the screens
    %
    % Can keep both, can write the old screen with sawtooth if you want to
    % compare
    %
    
    oldScreen = mod(angle(oldMask), 2*pi);
    sawScreen = mod(maskPhase + sawPhase + FPhase, 2*pi);
    figname = sprintf('%svoelz_%s_num_%d.bmp', outputFolder, windowName, k);
    imwrite(sawScreen/(2*pi),figname, 'bmp');
end


%
% Simulation Stuff
%

doSim = true;       % *** CHANGE if you don't want pretty pictures %doSim = false;
if doSim
    A = 1;          % normalization thing
    b = N/4;        % incoming beam radius
    rr2 = ((xx-N/2).^2 + (yy-N/2).^2);
    gBeam = A*exp(-rr2/b^2);    % Gaussian illumination of SLM
    uBeam = ones(size(rr2));    % Uniform illumination of SLM
    beam = gBeam;
    beam = beam/sum(beam(:));   % Normalization for prettier plotting

    noSawFarField = fftshift(fft2(exp(1i*oldScreen).*beam));
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