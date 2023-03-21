numScreens = 1500;
slmSize = 512;
calcFactor = 64/512;

M = 40;
dd = 4:0.5:8.5;
DD = [2.^dd];
folderPath = '..\Phase Screen Making\output';
%dataFolder = '\256_mgsm_M_40_D_46';
%dataFolderBase = 'mgsm_M_%d_D_%d';
dataFolderBase = '%d_mgsm_M_%d_D_%d';
filenameBase = 'MGSM_%d_c_width_M_%d_USNA_%d';

distances = 0:1:32;

[XX, YY] = ndgrid(1:(calcFactor*slmSize), 1:(calcFactor*slmSize));
XX = XX(:);
YY = YY(:);

plotZone = 1;

sCorr = zeros(length(distances), length(DD));

eps = 0.2;

%pool = parpool(6);

for d = 1:length(DD)
    D = DD(d);
    fprintf('D = %d.\n', ceil(D));

    %screens = zeros(slmSize, slmSize, numScreens);
    screens2 = zeros((calcFactor*slmSize)^2, numScreens);

    fprintf('Loading Screens.\n');

    for k = 1:numScreens
        dataFolder = sprintf(dataFolderBase, slmSize, M, ceil(D));
        
        folder = sprintf('%s\\%s', folderPath, dataFolder);
        filename = sprintf(filenameBase, D, M, k);
        fullPath = sprintf('%s\\%s.bmp', folder, filename);

        curScreen = imread(fullPath);
        curScreen = double(curScreen(1:(calcFactor*slmSize),1:(calcFactor*slmSize)));
        %screens(:,:,k) = curScreen;
        screens2(:, k) = curScreen(:);
    end

    fprintf('Calculating near fields.\n');
    beam = exp(1i*2*pi/256*screens2);

    fprintf('Calculating built-in correlation function.\n');
    beamCorrs = corr(transpose(beam));

    sCorrAccum = zeros(length(distances), 1);
    numPairs = zeros(length(distances), 1);

    fprintf('Binning correlations by separation distance.\n');
    for r1 = 1:size(beamCorrs, 1)
        for r2 = (r1):size(beamCorrs, 2)
            RR2 = (XX(r1) - XX(r2)).^2 + (YY(r1) - YY(r2)).^2;
            for k = 1:length(distances)
                if (abs(RR2 - distances(k).^2) < eps)
                    numPairs(k) = numPairs(k) + 1;
                    sCorrAccum(k) = sCorrAccum(k) + beamCorrs(r1, r2);
                end
            end
        end
    end

    for k = 1:length(distances)
        sCorr(k, d) = sCorrAccum(k)/numPairs(k);
    end

end

fprintf('Plotting.\n');

eLine = (1/2.71828)*ones(length(distances), 1);
figure(201);
clf
for d = 1:length(DD)
    subplot(3,4,d)
    hold on
    plot(distances, abs(sCorr(:, d)), 'blue');
    plot(distances, eLine, 'red');
    hold off
    title(sprintf('d2 = %d', DD(d)));
end

