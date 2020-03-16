function [labelledImage, basalLayer, apicalLayer, colours] = postprocessGland(labelledImage,outsideGland, lumenImage, outputDir, colours, tipValue)
%POSTPROCESSGLAND Process gland image to obtain layers and export
%   Once the gland has all its features on the 3D images, we extracted the
%   layers (apical and basal) and export it in slices.

%     [labelledImage] = fillEmptySpacesByWatershed3D(labelledImage, outsideGland | lumenImage, 1); % error outsideGland?
%     outsideGland_NotLumen = ~outsideGland | lumenImage;

    %labelledImage = fill0sWithCells(labelledImage, labelledImage, outsideGland | lumenImage);
    %labelledImage(lumenImage) = 0;

    %% Get basal layer by dilating the empty space
    basalLayer = getBasalFrom3DImage(labelledImage, lumenImage, tipValue, outsideGland & imdilate(lumenImage, strel('sphere', 1)) == 0);

    %% Get apical layer by dilating the lumen
    [apicalLayer] = getApicalFrom3DImage(lumenImage, labelledImage);
    exportAsImageSequence(apicalLayer, fullfile(outputDir, 'Apical_Labelled'), colours, tipValue);

    %% Export image sequence
    [colours] = exportAsImageSequence(labelledImage, fullfile(outputDir, 'Cells', 'labelledSequence', filesep), colours, tipValue);
    exportLumen(lumenImage,outputDir, tipValue);
end

