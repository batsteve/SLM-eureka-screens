function [ outcode ] = dPhaseScreenPlots( options, data )
%DPHASESCREENPLOTS Summary of this function goes here
%   Detailed explanation goes here

    tic;
    fprintf('Beginning phase screen plotting.');
    curFig = 1;

    if options.drawRawScreen
        figure(curFig);
        clf;
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(angle(data.rawScreen));
        shading flat
        if options.includePlotTitles, title('Raw screen'); end
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_raw_screen.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if options.drawPaddedScreen
        figure(curFig);
        clf;
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(angle(data.paddedScreen));
        shading flat
        if options.includePlotTitles, title('Padded screen'); end
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_padded_screen.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if options.drawRawFarField
        figure(curFig)
        clf;
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(abs(data.farFieldFromRaw).^2);
        shading flat
        caxis([0, options.rawMaxIntensity]);
        if options.includePlotTitles, title('Far field of raw screen'); end
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_raw_far_field.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if options.drawPaddedFarField
        figure(curFig)
        clf;
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(abs(data.farFieldFromPadded).^2);
        shading flat
        caxis([0, options.paddedMaxIntensity]);
        if options.includePlotTitles, title('Far field of padded screen');end
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_padded_far_field.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if options.drawPaddedFarFieldZoom
        XX = (options.xOffsetFarField+1):(options.xFullSize-options.xOffsetFarField);
        YY = (options.xOffsetFarField+1):(options.yFullSize-options.yOffsetFarField);
        figure(curFig)
        clf;
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(abs(data.farFieldFromPadded(XX, YY)).^2);
        shading flat
        caxis([0, options.paddedMaxIntensity]);
        if options.includePlotTitles, title('Far field of padded screen zoom');end
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_padded_far_field_zoom.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    fprintf('  Done after %d seconds.\n', ceil(toc));
    
    outcode = 1;
    
end

