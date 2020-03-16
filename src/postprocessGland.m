function [labelledImage, basalLayer, apicalLayer, colours] = postprocessGland(labelledImage,outsideGland, lumenImage, outputDir, colours,tipValue)
%POSTPROCESSGLAND Process gland image to obtain layers and export
%   Once the gland has all its features on the 3D images, we extracted the
%   layers (apical and basal) and export it in slices.

%     [labelledImage] = fillEmptySpacesByWatershed3D(labelledImage, outsideGland | lumenImage, 1); % error outsideGland?
%     outsideGland_NotLumen = ~outsideGland | lumenImage;

    %labelledImage = fill0sWithCells(labelledImage, labelledImage, outsideGland | lumenImage);
    %labelledImage(lumenImage) = 0;
    labelImageWithTips = addTipsImg3D(tipValue,labelledImage);
    outsideGlandWithTips = addTipsImg3D(tipValue,outsideGland);
    lumenImageWithTips = addTipsImg3D(tipValue,lumenImage);

    %% Get basal layer by dilating the empty space
    basalLayerWithTips = getBasalFrom3DImage(labelImageWithTips, lumenImageWithTips, outsideGlandWithTips & imdilate(lumenImageWithTips, strel('sphere', 1)) == 0);
    basalLayer = addTipsImg3D(-tipValue,basalLayerWithTips);
    %% Get apical layer by dilating the lumen
    [apicalLayerWithTips] = getApicalFrom3DImage(lumenImageWithTips, labelImageWithTips);
    apicalLayer = addTipsImg3D(-tipValue,apicalLayerWithTips);

    %% Export image sequence
    exportAsImageSequence(apicalLayer+basalLayer, fullfile(outputDir, 'ApicalAndBasal_Labelled'), colours);

    [colours] = exportAsImageSequence(labelledImage, fullfile(outputDir, 'Cells', 'labelledSequence', filesep), colours);
    exportLumen(lumenImage,outputDir);
    
    
end

