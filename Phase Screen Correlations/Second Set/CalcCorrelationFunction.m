function [ corrs ] = CalcCorrelationFunction( UUin )
%CALCCORRELATIONFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    xSize = size(UUin, 1);
    ySize = size(UUin, 2);
    xDiffs = -128:128;
    yDiffs = -128:128;
    
    corrs = zeros(length(xDiffs), length(yDiffs));
    numPairs = zeros(length(xDiffs), length(yDiffs));
    %corrAccum = zeros(length(xDiffs), length(yDiffs));
    
    meanAbs = mean(abs(UUin(:)));
    %UU = UUin./abs(UUin);
    UU = UUin./meanAbs;
    %UU = UUin;


    for j = 1:length(xDiffs)
        for k = 1:length(yDiffs)
            %tic
            
            yDiff = yDiffs(k);
            xDiff = xDiffs(j);
            yInt = (1+abs(yDiff)):(ySize - abs(yDiff));
            xInt = (1+abs(xDiff)):(xSize - abs(xDiff));
            corrProduct = conj(UU(xInt, yInt)).* ...
                UU(xInt + xDiff, yInt + yDiff);
            
%             if ((yDiff == 1) && (xDiff == 1))
%                 plotCorrProduct(corrProduct);
%             end
%             
%             figure(104);
%             clf
%             mesh(abs(UU(xInt, yInt)).*abs(UU(xInt+xDiff, yInt+yDiff)));
            
            corrFunction = mean(corrProduct(:));
            %meanProduct = meanVals(yInt, xInt, :).* ...
            %    meanVals(yInt + yDiffs, xInt+xDiffs, :);
            meanProduct = 0;
            
            %val = (corrFunction - meanProduct)./...
            %    (abs(UU(xInt, yInt)).*abs(UU(xInt+xDiff, yInt+yDiff)));
            val = (corrFunction - meanProduct);
            
            numPairs(j, k) = length(corrFunction(:));
            corrs(j, k) = sum(val(:))/numPairs(j, k);

            %fprintf('(dx, dy) = (%d, %d) calculation complete after %d seconds.\n', ...
            %    xDiff, yDiff, ceil(toc));
        end
    end
    
    
end

