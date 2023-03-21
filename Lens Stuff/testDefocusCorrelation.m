blurSizes = 16;

params = ParamStruct();
pattern = createTestCheckerboard(params);
rawNormPattern = normalizePattern( pattern, params );
rawCorrs = calcCorr(rawNormPattern, params);

figure(1001)
clf;
pcolor(rawNormPattern(:,:,1));
shading flat;

blurCorrs = cell(length(blurSizes), 1);

for k = 1:length(blurSizes)
    params.filterWidth = blurSizes(k);
    filter = createTestFilter( params );
    blurPattern = applyDefocus( pattern, filter, params );
    normBlurPattern = normalizePattern( blurPattern, params );
    blurCorrs{k} = calcCorr(normBlurPattern, params);
    
    figure(1001+k)
    clf;
    pcolor(normBlurPattern(:,:,1));
    shading flat;
     
    figure(1010+k)
    clf;
    pcolor(filter);
    shading flat;
end



fprintf('Checkboard square size: %d, %d\n', params.xBlockSize,  params.yBlockSize);
fprintf('Filter characteristic size: %0.2f\n', params.filterWidth);


cmap = colormap();

figure(1026)
clf;
hold on
names = cell(length(blurSizes)+1, 1);
plotXX = params.corrDistances;
plotYY = rawCorrs;
plot(plotXX, plotYY, 'blue');
names{1} = 'raw';

for k = 1:length(blurSizes)
    plotXX = params.corrDistances;
    plotYY = blurCorrs{k};
    color = cmap(ceil((k+1)/(length(blurSizes)+1)*size(cmap, 1)), :);
    plot(plotXX, plotYY, 'color', color);
    names{k+1} = sprintf('d = %0.2f', blurSizes(k));
end
hold off
legend(names);