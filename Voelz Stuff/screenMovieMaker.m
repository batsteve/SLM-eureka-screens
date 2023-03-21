N = 256;            % SLM grid size
d = 8;              % Sawtooth length
Corr_width_2 = 64;  % MGSM correlation length squared, in pixels
M = 40;             % Puts the M in MGSM
Ufactor = 0.7;      % Voodoo from the blackest depths
deltax = 4;
Beta = 4;
l = 1;
delta2 = 16;
numScreens = 1;
outputFolder = sprintf('Output\\Movies\\');
mkdir(outputFolder);

reducedN = floor(N/d);
[xx, yy] = ndgrid(1:N, 1:N);
r = size(xx, 1)/2;       % choose center of grid
c = size(yy, 2)/2;
rho = sqrt((xx-r).^2 + (yy-c).^2);
rho2 = (xx-r).^2 + (yy-c).^2;
theta = atan2(xx-r, yy-c);



kernelType = 'swirl';
switch kernelType
    case 'mgsm'
        windowx = zeros(size(rho));
        for m = 1:1:M;                             % add in additional windows
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
        %windowx = zeros(size(rho));
        windowx = exp(-rho2/(2*delta2));
        prefactor = -sqrt(1/(2*pi))*rho/sqrt(delta2).*exp(-rho2/(4*delta2));
        for m = 1:1:M;                             % add in additional windows
            window_m = prefactor.*(1/m)*(-1i)^(m*l).*sin(m*l*theta).*...
                 (besseli((m*l-1)/2, rho2/(4*delta2)) - besseli((m*l+1)/2, rho2/(4*delta2)));
            %window_m = prefactor.*(1/m)*(-1i)^(m*l).*exp(1i*m*l*theta).*...
            %     (besseli((m*l-1)/2, rho2/(4*delta2)) - besseli((m*l+1)/2, rho2/(4*delta2)));

            windowx = windowx + window_m;
        end
        windowName = sprintf('vortex_%d', l);
        
    case 'swirl'
        windowx = exp(-rho2/(2*delta2));
        windowv = (-1i)^l*pi^(1/2)*rho/(2*sqrt(2)*sqrt(delta2)).*exp(-rho2/(4*delta2)).*...
            (besseli((l-1)/2, rho2/(4*delta2)) - besseli((l+1)/2, rho2/(4*delta2))).*cos(l*theta);
        windowx = windowx + windowv;
        windowName = sprintf('swirl_%d', l);
        
end

%window = windowx/cc;
window = windowx;
fullNormFactor = sum(window(:));
kernel = window/fullNormFactor;
sqrtPhi = fft2(kernel);


A = 1;
b = N/4;
rr2 = ((xx-N/2).^2 + (yy-N/2).^2);
gBeam = A*exp(-rr2/b^2);    % Gaussian illumination of SLM
uBeam = ones(size(rr2));    % Uniform illumination of SLM
beam = gBeam;
beam = beam/sum(beam(:));   % Normalization for prettier plotting

ffBeams = zeros(4*N, 4*N, numScreens);

for k = 1:numScreens
    r = randn(N, N) + 1i*randn(N, N);
    mask = ifft2(r.*sqrtPhi);
    
    maskPhase = angle(mask);
    
    screen = mod(maskPhase, 2*pi);
    nearField = exp(1i*screen).*beam;
    bigNearField = zeros(4*N, 4*N);
    innerIndices = (1.5*N+1):(2.5*N);
    bigNearField(innerIndices, innerIndices) = nearField;
    
    noSawFarField = fftshift(fft2(bigNearField));
    ffBeams(:, :, k) = abs(noSawFarField).^2;
end

figure(1);
clf;
subplot(1, 2, 1)
mesh(real(window));
d = 32;
xlim([129-d 128+d])
ylim([129-d 128+d])
title('real')
subplot(1, 2, 2)
mesh(imag(window));
d = 32;
xlim([129-d 128+d])
ylim([129-d 128+d])
title('imaginary')

figname = sprintf('%sscreen.bmp', outputFolder);
imwrite(screen/(2*pi),figname, 'bmp');

%
% Housekeeping things for the VideoWriter class
% Default framerate should hit 20 fps
%

filename = sprintf('%sscreens_%s.avi', outputFolder, windowName);
vidObj = VideoWriter(filename);
vidObj.Quality =60;
vidObj.FrameRate = 3;

open(vidObj);
ff=figure('Visible','Off');
%ff=figure('Visible','On');
%colors = jet(NumWaves+1);


plotType = 'pcolor';
for t = 1:numScreens
    clf
    %hold on
    %text(0,0.6*YMax,ZMin, num2str(TimeStart + t*TimeStep));
    
    %meanIntensity = squeeze(mean(ffBeams(:, :, 1:t), 3));
    meanIntensity = squeeze(ffBeams(:, :, t));
    
    switch plotType
        case 'pcolor'
            pcolor(meanIntensity);
            shading interp;
            caxis([0 1e-2])
    
        case 'mesh'
            mesh(meanIntensity);
            shading interp;
            caxis([0 1e-2])
            zlim([0 1e-2])
    end
    
    x = 0.5*N;
    xlim([1+x    4*N-x]);
    ylim([1+x    4*N-x]);
    
    %xlim([1.5*XMin 1.5*XMax]);
    %ylim([1.5*YMin 1.5*YMax]);
    %zlim([ZMin ZMax]);
    
    %set(gca, 'CameraPositionMode', 'manual');
    %set(gca, 'CameraPosition', [XMax YMax 1.5*ZMax]);
    %set(gca, 'Color', 'none');
    %set(gca, 'DataAspectRatioMode', 'manual');
    %set(gca, 'DataAspectRatio', [1 1 1]);
    %set(gcf, 'Color', [1 1 1]);
    %zoom(1.5);
    
    
    %cdata = hardcopy(ff, '-Dzbuffer', '-r0');
    cdata = print(ff, '-RGBImage', '-r0');
    currFrame = im2frame(cdata);
    writeVideo(vidObj, currFrame)
    %hold off
end

close(ff);
close(vidObj);