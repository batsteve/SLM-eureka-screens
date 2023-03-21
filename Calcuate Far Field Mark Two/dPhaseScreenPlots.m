function [ outcode ] = dPhaseScreenPlots( options, output, data )
%DPHASESCREENPLOTS Summary of this function goes here
%   Detailed explanation goes here

    tic;
    fprintf('Beginning phase screen plotting.');
    curFig = 1;
    
    if output.drawScreen
        figure(curFig);
        clf;
        if output.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, output.figSize, output.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(angle(data.screen));
        shading flat
        if output.includePlotTitles, title('Padded screen'); end
        arg = sprintf('-f%d', curFig);
        print(arg, output.printResolution, '-dpng', sprintf('%s%s_padded_screen.png', output.outputPath, output.filePrefix));
        if output.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if output.drawFarField
        figure(curFig)
        clf;
        if output.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, output.figSize, output.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(abs(data.farField).^2);
        shading flat
        colorbar();
        %caxis([0, options.paddedMaxIntensity]);
        if output.includePlotTitles, title('Far field of padded screen');end
        arg = sprintf('-f%d', curFig);
        print(arg, output.printResolution, '-dpng', sprintf('%s%s_padded_far_field.png', output.outputPath, output.filePrefix));
        if output.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if output.drawFarFieldZoom
        XX = (options.xOffsetFarField+1):(options.xFullSize-options.xOffsetFarField);
        YY = (options.xOffsetFarField+1):(options.yFullSize-options.yOffsetFarField);
        figure(curFig)
        clf;
        if output.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, output.figSize, output.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        pcolor(abs(data.farField(XX, YY)).^2);
        shading flat
        %caxis([0, options.paddedMaxIntensity]);
        if output.includePlotTitles, title('Far field of padded screen zoom');end
        arg = sprintf('-f%d', curFig);
        print(arg, output.printResolution, '-dpng', sprintf('%s%s_padded_far_field_zoom.png', output.outputPath, output.filePrefix));
        if output.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    fprintf('  Done after %d seconds.\n', ceil(toc));
    
    outcode = 1;
    
end

