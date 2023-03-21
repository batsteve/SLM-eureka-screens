outputFolder = 'Output\';
mkdir(outputFolder);

for k = 1:8
    size = 2^k;
    [XX, YY] = ndgrid(1:256, 1:256);
    diagScreen = floor(2*mod(XX+YY, size)/size)/2;
    figname = sprintf('%sdiagonal_%d_pixels.bmp',outputFolder, size);  
    imwrite(diagScreen,figname, 'bmp');
    
    vertScreen = floor(2*mod(XX, size)/size)/2;
    figname = sprintf('%svert_%d_pixels.bmp',outputFolder, size);  
    imwrite(vertScreen,figname, 'bmp');
    
    whoreScreen = floor(2*mod(YY, size)/size)/2;
    figname = sprintf('%swhore_%d_pixels.bmp',outputFolder, size);  
    imwrite(whoreScreen,figname, 'bmp');
    
    checkerScreen =mod(vertScreen + whoreScreen, 1);
    figname = sprintf('%schecker_%d_pixels.bmp',outputFolder, size);  
    imwrite(checkerScreen,figname, 'bmp');
        
end

blackScreen = zeros(256, 256);
figname = sprintf('%sblack.bmp',outputFolder);  
imwrite(blackScreen,figname, 'bmp');