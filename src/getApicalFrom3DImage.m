function [apicalLayer] = getApicalFrom3DImage(lumenImage, labelledImage)
%GETAPICALFRO3DIMAGE Summary of this function goes here
%   Detailed explanation goes here
    se = strel('sphere', 1);
    lumenImage = imclose(lumenImage, strel('sphere', 5));
    dilatedLumen = imdilate(lumenImage, se);
    apical1Pixel = (dilatedLumen - lumenImage);
    apicalLayer = labelledImage .* apical1Pixel;
    apicalLayer = fill0sWithCells(apicalLayer, labelledImage, apical1Pixel == 0);
    %% For ecadhi
%     glandPlusLumenImage = fill0sWithCells(labelledImage, labelledImage, imdilate(lumenImage, strel('sphere', 5))==0);
%     apicalLayer = fill0sWithCells(apicalLayer, glandPlusLumenImage, apical1Pixel == 0);
    
%     [x,y,z] = ind2sub(size(apicalLayer),find(apicalLayer>0));
%     figure;
%     pcshow([x,y,z]);
end

