function [labelledImage, lumenImage] = inferLumen(labelledImage)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

filledImage = imfill(imclose(labelledImage,strel('sphere', 8)));
lumenImage = filledImage- imclose(labelledImage,strel('sphere', 8));

% filledImage = zeros(size(labelledImage));
% 
% for numZ = 1:size(labelledImage, 1)
%    filledImage(:,:,numZ) = imfill(labelledImage(:,:,numZ),strel('disk', 5));
% end
%  lumenImage = addTipsImg3D(tipValue+1, lumenImage);
%     lumenImage = double(lumenImage);

    

    %% Remove pixels of lumen from the cells image

    lumenImageLabel = bwlabeln(lumenImage,26);
    volume = regionprops3(lumenImageLabel,'Volume');
    [~,indMax] = max(cat(1,volume.Volume));
    lumenImage = lumenImageLabel >= indMax;
    
    labelledImage(lumenImage == 1) = 0;
    
end

