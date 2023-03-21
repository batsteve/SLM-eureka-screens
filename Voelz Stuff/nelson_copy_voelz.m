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
d = 8;              % Sawtooth length, in pixels
Ufactor = 0.7;      % Voodoo from the blackest depths, E(h)/E(h=lambda), mathematically does not work if 1.0

M = 40;             % Puts the M in MGSM
Corr_width_2 = 64;  % MGSM correlation length squared, in pixels_squared
deltax = 4;         % BGSM ring parameter in pixels
Beta = 4;           % BGSM ring parameter in pixels?
l = 1;              % vortex parameter (from paper), roughly "number of turns", l=3 gives triangle

numScreens = 10;    % change to 8000 for example

reducedN = floor(N/d);  % number of sawtooths in SLM screen
[xx, yy] = ndgrid(1:N, 1:N);  % takes two intervals and makes 2D arrays, tiled version of intervals, similar to meshgrid

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

kernelType = 'mgsm';            % so do not have to comment and uncomment, 'mgsm', 'ring, 'vortex'
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
        
    case 'vortex'    % from paper by Olga etal, new 2016?
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
        
    case 'swirl'   % from paper by Olga etal, new 2016?  Note change to besseli vs. besselj
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

window = windowx;     % where windowx is always the final window function (array) from above
                       % This is then normalized to 1 for ease of viewing
                       % the window.  This was more important before switching to Voelz method.  For example plotting
                       % two window functions for comparison, side-by-side.
fullNormFactor = sum(window(:));
kernel = window/fullNormFactor;
sqrtPhi = fft2(kernel);     % sqrt of Power Spectrum  Voelz uses, as faster vs. convolution method

%
% Name the folder where the screens are gonna go
%

outputFolder = sprintf('Output\\Saw_%s\\', windowName);
mkdir(outputFolder);

% Voodoo section from Hyde and Voelz paper . . . we all are in the woods at
% the moment . . .
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
% hbar = h/lambda;  This is roughly the height of the sawtooth. . .
%  If want to modulate the amplitude, Voelz does, we do not want this, this
%  is how you go between amplitdue modulation and SLM screen

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
sawTemplate = (sawXX+sawYY)*pi*2;  % making go to 0 - 2pi vs. 0 -1

% created saw function
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
    
    r = randn(N, N) + 1i*randn(N, N);  % circularly complex Gaussian
    mask = ifft2(r.*sqrtPhi);  % this is different from before? see next line.  Seems to work better?
    %mask = conv2(r, kernel, 'same');  % kernal is the ifft of sqrtPHi,
    %this was the method that we did before.  For reasons? the mask -=
    %ifft2(r*sqrtPhi) works better?  Note, the conv2 also works.  Gives a factor
    %difference . . .
    
    maskPhase = angle(mask);  % now take the phase of the created mask vs. just the amplitude, where
                                % previously we had a real randn(N, N)
                                % where we did a max and min, here we can
                                % take a phase which bounds between 0 and
                                % 2pi . . . around the circle, vs. just
                                % along the 0 or 180 degree direction which
                                % is what we did previously with tne
                                % non-complex Gaussian.  We were a bit
                                % confused before, where before we spent
                                % one month with the 0 and 2pi which was at
                                % the time inexplicably better as we took
                                % the phase of the real numbers.  0 - 2pi
                                % comes naturally vs. arbitrary before.
    
    %
    % Put it all together
    %
    
    screen = mod(maskPhase, 2*pi);  % subract as many 2pis before going negative and keep the remainder,
                                    %divide by 2pi and take the integer remainder . . .
    sawScreen = mod(maskPhase + sawPhase + FPhase, 2*pi);  % FPhase distortion correction for sawtooth
    figname = sprintf('%svoelz_%s_num_%d.bmp', outputFolder, windowName, k);
    imwrite(sawScreen/(2*pi),figname, 'bmp');
end


%
% Simulation Stuff
%

doSim = true;   % if make false, then skips section
if doSim
    A = 1;          % normalization thing
    b = N/4;        % incoming beam radius
    rr2 = ((xx-N/2).^2 + (yy-N/2).^2);
    gBeam = A*exp(-rr2/b^2);    % Gaussian illumination of SLM, 
    uBeam = ones(size(rr2));    % Uniform illumination of SLM
    beam = gBeam;
    % beam = uBeam;  % For uniform illumination
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