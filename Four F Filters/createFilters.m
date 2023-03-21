function [ outcode ] = createFilters(  )
%CREATEFILTERS Summary of this function goes here
%   Detailed explanation goes here

    sizeList = [1, 2, 4, 8, 16];
    screenSize = 256;
    spacing = 1;
    
    for kkk = 1:length(sizeList)
        curSize = sizeList(kkk);
        dir = sprintf('Size_%d', curSize);
        path = sprintf('Output\\%s\\', dir);
        cd Output
        mkdir(dir);
        cd ..
        for xxx = 96:spacing:160
            for yyy = 96:spacing:160
                filename = sprintf('%sX_%d_Y_%d.bmp', path, xxx, yyy);
                A = zeros(screenSize, screenSize);
                for x = xxx:(xxx+curSize)
                    for y = yyy:(yyy+curSize)
                        A(x, y) = 128;
                    end
                end
                
                imwrite(A, filename, 'BMP');
            end
        end
    end

    outcode = 1;

end

