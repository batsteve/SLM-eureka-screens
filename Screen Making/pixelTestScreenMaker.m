allSizes = [256, 512];
%whiteVal = 0;
blackVal = 0.5;
for k = 1:2
    screenSize = allSizes(k);
    outputFolder = sprintf('output\\pixelTestScreens\\%d', screenSize);
    mkdir(outputFolder);
    [XX, YY] = ndgrid(1:screenSize, 1:screenSize);
    
    

    vertScreen = zeros(screenSize, screenSize);
    vertScreen = vertScreen + blackVal*(XX > screenSize/2);
    filename = sprintf('%s\\Vert_%d.bmp', outputFolder, screenSize);
    imwrite(vertScreen, filename, 'bmp');
    
   

    horzScreen = zeros(screenSize, screenSize);
    horzScreen = horzScreen + blackVal*(YY > screenSize/2);
    filename = sprintf('%s\\Horz_%d.bmp', outputFolder, screenSize);
    imwrite(horzScreen, filename, 'bmp');



    diagScreen = zeros(screenSize, screenSize);
    diagScreen = diagScreen + blackVal*(XX - YY > 0);
    filename = sprintf('%s\\Diag_%d.bmp', outputFolder, screenSize);
    imwrite(diagScreen, filename, 'bmp');
    
    
    
    lineVertScreen = zeros(screenSize, screenSize);
    lineVertScreen = lineVertScreen + blackVal*(XX == screenSize/2);
    filename = sprintf('%s\\Line_Vert_%d.bmp', outputFolder, screenSize);
    imwrite(lineVertScreen, filename, 'bmp');
    
    
    
    lineHorzScreen = zeros(screenSize, screenSize);
    lineHorzScreen = lineHorzScreen + blackVal*(YY == screenSize/2);
    filename = sprintf('%s\\Line_Horz_%d.bmp', outputFolder, screenSize);
    imwrite(lineHorzScreen, filename, 'bmp');
    
    
    
    lineDiagScreen = zeros(screenSize, screenSize);
    lineDiagScreen = lineDiagScreen + blackVal*(YY - XX == 0);
    filename = sprintf('%s\\Line_Diag_%d.bmp', outputFolder, screenSize);
    imwrite(lineDiagScreen, filename, 'bmp');
    


    LL = [1, 2, 3, 4, 5, 6];
    for ll = 1:length(LL)
        boxSize = LL(ll);
        boxScreen = zeros(screenSize, screenSize);
        for x = 1:boxSize
            for y = 1:boxSize
                boxScreen(screenSize/2+x, screenSize/2+y) = blackVal;
            end
        end
        filename = sprintf('%s\\Box_%d_%d.bmp', outputFolder, boxSize, screenSize);
        imwrite(boxScreen, filename, 'bmp');
    end
end