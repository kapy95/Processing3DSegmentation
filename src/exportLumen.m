function exportLumen(lumenImage, outputDir, tipValue)
%EXPORTASIMAGESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
    mkdir(fullfile(outputDir, 'Lumen', 'inferLumen'));        
    for numZ = 1:(size(lumenImage, 3))
        actualImg = imcomplement(lumenImage(:, :, numZ));
        imwrite(double(actualImg), fullfile(outputDir,'Lumen/inferLumen', strcat('/lumenImage_', num2str([numZ].','%03d'), '.tif')))
    end
end