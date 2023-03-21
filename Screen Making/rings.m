numScreens = 1;
outputFolder = 'output\test\';

screenSize = 256;

deltax = 2;   % ring thickness
Beta = 3;     % ring radius


[y,x] = meshgrid(1:screenSize,1:screenSize);   
r = length(x)/2;       % choose center of grid
c = length(x)/2;
rho = sqrt((x-r).^2 + (y-c).^2);    % distance from center, careful as rho 
                                    % very big drives the window function  
                                    % to zero rapidly 
                                    
param1 = Beta*rho/deltax;
param2 = rho.^2/(2*deltax^2); 
window_ring = besselj(0,param1).*exp(-param2);

figure(2);
pcolor(window_ring)
shading flat


for k=1:numScreens
    I=normrnd(0,1,screenSize,screenSize);
    
    GSB1x = conv2(window_ring,I,'same');% convolution of window function with Gaussian Random Number 
    GSB1 = GSB1x- min(min(GSB1x));
    GSB1 = GSB1./max(max(abs(GSB1)));
    
    %figure(k);imshow((GSB1+1)/2);title('screen GSB'); % this how the screen looks that is sent to SLM
    
    filename = sprintf('%sring_B%s_D%s_USNA_%d.bmp', outputFolder, num2str(Beta), num2str(deltax), k);
    %filename=[outputFolder,'ring B',num2str(Beta),' D',num2str(deltax),' ', num2str(k),'.bmp'];
    imwrite(GSB1,filename,'bmp') % make a screen for SLM
end

figure(1);
fg = fft2(GSB1x);
fg = abs(fftshift(fg));
fg = fg- min(min(fg));
fg = fg./max(max(abs(fg)));
imshow(fg)

energy = sum(fg(:).^2);
%deltax=10;Beta =10; 343.3706
%deltax=3;Beta =3;975.0240
%deltax=4;Beta =4;590.2288
%deltax=2.5;Beta =3;1.2769e+03
%deltax=2;Beta =3;1.6264e+03
%deltax=1;Beta =3;3.5802e+03  beamis not good!too wide