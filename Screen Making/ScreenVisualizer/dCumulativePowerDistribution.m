function [ outcode ] = dCumulativePowerDistribution( options, data )
%DCUMULATIVEPOWERDISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

    tic;
    fprintf('Beginning cumulative power plotting.');

    cX = options.xFullSize/2;
    cY = options.yFullSize/2;
    
    [XX, YY] = ndgrid(1:options.xFullSize, 1:options.yFullSize);
    
    N = 100;
    maxRadius = 0.5;
    radii = linspace(0, maxRadius, N);
    accum = zeros(N, 1);
    
%     for x = 1:options.xFullSize
%         for y = 1:options.yFullSize
%             rad2 = ((x-cX)/options.xFullSize).^2 + ((y-cY)/options.yFullSize).^2;
%             for k = 1:N
%                 if (rad2 < radii.^2)
%                     accum(k) = accum(k) + abs(data.farFieldFromPadded(x, y)).^2;
%                 end
%             end
%         end
%     end

    for k = 1:N
        %mask = ((XX-cX)/options.xFullSize).^2 + ((YY-cY)/options.yFullSize).^2 < radii(k).^2;
        mask = ((XX-cX)/options.xFarFieldSize).^2 + ((YY-cY)/options.yFarFieldSize).^2 < radii(k).^2;
        accum(k) = sum(abs(data.farFieldFromPadded(mask)).^2);
    end
    
    %hotspotRad = sqrt(((options.xHotspotRadius/options.xFarFieldSize).^2 + ...
    %                (options.yHotspotRadius/options.yFarFieldSize).^2 / 2));
    hotspotRad = options.xHotspotRadius/options.xFarFieldSize;
    innerRingRad = options.xInnerRingRadius/options.xFarFieldSize;
    outerRingRad = options.xOuterRingRadius/options.xFarFieldSize;
    
    accum = accum/accum(N);
    
    curFig = 10;
    
    if options.drawCumulativeRadialPower
        figure(curFig);
        clf;
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        plot(radii, accum);
        if options.includePlotTitles, title('cumulative power as a function of radius'); end
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_cumulative_power_with_radius.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    if options.drawDifferentialRadialPower
        figure(curFig);
        clf;
        hold on
        if options.makeInvisibleFigures, set(gcf, 'Visible', 'off'); end
        set(gcf, 'Position', [0, 0, options.figSize, options.figSize]);
        set(gca,'Position',[0.05 0.05 0.9 0.9])
        plot(radii, [accum(1); diff(accum)]);
        hx1 = graph2d.constantline(hotspotRad, 'LineStyle',':', 'Color',[.7 .7 .7]);
        changedependvar(hx1,'x');
        hx2 = graph2d.constantline(innerRingRad, 'LineStyle',':', 'Color',[.7 .7 .7]);
        changedependvar(hx2,'x');
        hx3 = graph2d.constantline(outerRingRad, 'LineStyle',':', 'Color',[.7 .7 .7]);
        changedependvar(hx3,'x');
        if options.includePlotTitles, title('differential power as a function of radius'); end
        hold off
        arg = sprintf('-f%d', curFig);
        print(arg, options.printResolution, '-dpng', sprintf('%s%s_differential_power_with_radius.png', options.outputPath, options.filePrefix));
        if options.clearFigureWhenFinished, clf; end
        curFig = curFig+1;
    end
    
    fprintf('Done after %d seconds.\n', ceil(toc));
    
    outcode = 1;

end

