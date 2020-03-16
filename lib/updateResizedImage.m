function updateResizedImage()
%UPDATERESIZEDIMAGE Summary of this function goes here
%   Detailed explanation goes here
    labelledImage = getappdata(0, 'labelledImageTemp');
    lumenImage = getappdata(0, 'lumenImage');
    resizeImg = getappdata(0,'resizeImg');
    
    originalSize = size(labelledImage);
    sizeResized = originalSize * resizeImg;
    sizeResized(3) = originalSize(3);
    
    setappdata(0, 'labelledImageTemp_Resized', imresize3(labelledImage, sizeResized, 'nearest'));
    setappdata(0, 'lumenImage_Resized', imresize3(double(lumenImage), sizeResized, 'nearest')>0);
end

