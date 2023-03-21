% from http://www.mathworks.com/matlabcentral/answers/80612-modeling-the-point-spread-function-of-a-simple-lens-with-defocus-aberration

% I am trying to model the PSF of a simple lens with a defocus aberration.
% I started by finding the geometric optics prediction of the system blur
% and convolving it with the impulse response of the exit pupil to account
% for diffraction. This gave me physically believable results. I would like
% to verify that with a purely wave-optical approach. I have attempted to
% do this following Goodman's formulation of an aberrated spherical wave
% front in chapter 6 of Introduction to Fourier Optics:

% P(x,y) = P(x,y)*exp[j*k*W(x,y)]

% where P(x,y) is the aperture and 
% W(x,y) = (-1/2)*((1/za)-(1/zi))*(x^2 + y^2). zi is the distance between
% the lens and the image plane. za is the distance between the lens and the
% point to which the aberrated wave is converging. As the difference
% between zi and za gets larger, the PSF should get wider (more blur). But
% in the code that follows, I am seeing no change as a function of za.

% Camera system parameters
zi = .0981;                 % Distance to image plane (m)
Feff = .078;                % Effective focal length of the system (m)
w = .001;                   % Radius of the aperture (m)

% Array paramters
M = 1280;                   % number of pixels wide
N = 1040;                   % number of pixels long
dx = 6e-6;                  % sample interval (m)
Lx = dx*M;                  % physical width (m)
Ly = dx*N;                  % physical length (m)

% Create array
x = -Lx/2:dx:Lx/2-dx;
y = -Ly/2:dx:Ly/2-dx;
[xx,yy] = meshgrid(x,y);

% Illumination
lambda = 0.4e-6;            % wavelength (m)
k = 2*pi/lambda;            % wavenumber (1/m)

% Center of focus of aberrated wave (this is what is changing)
za = .099;

% wave front aberration
kW =  -0.5*((1/za) - (1/zi))*(xx.*xx + yy.*yy);

% complex pupil function
P = ((sqrt(xx.*xx + yy.*yy)/(2*w)) < 1) .* exp(1i*k*kW);

% transfer function
h = fftshift(fft2(fftshift(P))) * dx^2;
im = abs(h).^2;

figure(326);
clf;
pcolor(xx, yy, im);
shading flat;
colorbar();
caxis([0 1e-16]);
