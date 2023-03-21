dd = [1 2 4 8 16 32 64 128 256];

curFig = 851;
for k = 1:4
    figure(curFig)
    clf
    hold on
    curFig = curFig+1;
end

for k = 1:length(dd)
    params = ScreenMakerParamStruct();
    params.outputFolder = 'output\test\';
    % mkdir output\test
    % params.screenType = 'ring';
    % params.deltax = 2;
    % params.Beta = 3;
    params.screenType = 'mgsm';
    params.M = 40;
    params.Corr_width_2 = dd(k);
    kernel = kernelMaker( params );

    rad = 1/8;
    windowX = floor((1/2-rad)*params.screenSize):ceil((1/2+rad)*params.screenSize);
    windowY = windowX;

    curFig = 851;
    figure(curFig)
    subplot(3, 3, k);
    mesh(windowX, windowY, kernel(windowX, windowY));
    xlim([floor((1/2-rad)*params.screenSize), ceil((1/2+rad)*params.screenSize)]);
    ylim([floor((1/2-rad)*params.screenSize), ceil((1/2+rad)*params.screenSize)]);
    title(sprintf('corr length = %d', params.Corr_width_2));
    curFig = curFig+1;
    
    figure(curFig)
    subplot(3, 3, k);
    surf(windowX, windowY, kernel(windowX, windowY));
    xlim([floor((1/2-rad)*params.screenSize), ceil((1/2+rad)*params.screenSize)]);
    ylim([floor((1/2-rad)*params.screenSize), ceil((1/2+rad)*params.screenSize)]);
    title(sprintf('corr length = %d', params.Corr_width_2));
    shading interp
    curFig = curFig+1;
    
    figure(curFig)
    subplot(3, 3, k);
    pcolor(windowX, windowY, kernel(windowX, windowY));
    title(sprintf('corr length = %d', params.Corr_width_2));
    shading flat
    curFig = curFig+1;
    
    figure(curFig)
    subplot(3, 3, k);
    [XX, YY] = meshgrid(1:params.screenSize,  1:params.screenSize);
    RR = sqrt((XX - params.screenSize/2).^2 + (YY - params.screenSize/2).^2);
    plotXX = RR(:);
    plotYY = kernel(:);
    plot(plotXX, plotYY, '.');
    xlim([0 50])
    title(sprintf('corr length = %d', params.Corr_width_2));
    shading flat
end

curFig = 851;
for k = 1:4
    figure(curFig)
    hold off
    curFig = curFig+1;
end



% dd = linspace(1, 128, 100);
% signedWeight = zeros(length(dd), 1);
% unsignedWeight = zeros(length(dd), 1);
% 
% for k = 1:length(dd)
%     params = ScreenMakerParamStruct();
%     params.outputFolder = 'output\test\';
%     params.screenType = 'mgsm';
%     params.M = 40;
%     params.Corr_width_2 = dd(k);
%     kernel = kernelMaker( params );
%     
%     signedWeight(k) = sum(kernel(:));
%     unsignedWeight(k) = sum(abs(kernel(:)));
% end
% 
% curFig = 876;
% 
% figure(curFig);
% clf;
% plot(dd, signedWeight);
% title('signed weight of window function (screen kernel)');
% curFig = curFig + 1;
% 
% figure(curFig);
% clf;
% plot(dd, unsignedWeight);
% title('unsigned weight of window function (screen kernel)');
% curFig = curFig + 1;