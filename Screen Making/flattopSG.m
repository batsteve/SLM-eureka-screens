numScreens = 1;
outputFolder = 'output\test\';

N = 1;
M = 40; 
Corr_width_2 = 16;
screenSize = 256;

[y,x] = meshgrid(1:screenSize,1:screenSize);   
r = length(x)/2;       % choose center of grid
c = length(x)/2;
rho = sqrt((x-r).^2 + (y-c).^2);    % distance from center, careful as rho 
                                    % very big drives the window function  
                                    % to zero rapidly
                                    
                                    
windowx = zeros(size(rho));
for m = N:1:M;                             % add in additional windows
    window_m = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m ...
        *exp(-rho.^2/(2*m*Corr_width_2));
    windowx = windowx + window_m;
        
    cc = factorial(M)/factorial(m)/factorial(M-m)*(-1)^(m-1)/m;
end

windowx=windowx/cc; 

    
for k = 1:numScreens
    I = normrnd(0,1,screenSize,screenSize);
    
    GSB1x = conv2(windowx,I,'same');% convolution of window function with Gaussian Random Number 
    
    GSB1 = GSB1x - min(min(GSB1x));
    GSB1 = GSB1./max(max(abs(GSB1)));             
    
    figname = sprintf('%sMGSM_%d_c_width_M_%d_USNA_%d.bmp', outputFolder, Corr_width_2, M, k);  
    imwrite(GSB1,figname, 'bmp');
end


 