function [labelledImage, lumenImage, glandOrientation] = processLumen(lumenDir, labelledImage, resizeImg, tipValue)
%PROCESSLUMEN Obtain segmented lumen from images
%   Import the lumen from the original images where the lumen is in black
%   and white to remove the cells invading it on the 3D labelled image.

    lumenStack = dir(fullfile(lumenDir, 'SegmentedLumen', '*.tif'));
    NoValidFiles = startsWith({lumenStack.name},'._','IgnoreCase',true);
    lumenStack=lumenStack(~NoValidFiles);
    lumenImage = zeros(size(labelledImage)-((tipValue+1)*2));
    for numZ = 1:size(lumenStack, 1)
        imgZ = imread(fullfile(lumenStack(numZ).folder, lumenStack(numZ).name));
        
        [y, x] = find(imgZ == 0);
        ry=round(y*resizeImg);
        rx=round(x*resizeImg);
        
        rx(rx<1)=1;
        ry(ry<1)=1;
      
        if isempty(x) == 0
            lumenIndices = sub2ind(size(lumenImage), round(rx), round(ry), repmat(numZ, length(x), 1));
            lumenImage(lumenIndices) = 1;
        end
    end
%     lumenFile = dir(fullfile(lumenDir, '**', '*.ply'));
%     lumenPC = pcread(fullfile(lumenFile.folder, lumenFile.name));
    %pcshow(lumenPC);
%     pixelLocations = round(double(lumenPC.Location)*resizeImg);
%     [lumenImage] = addCellToImage(pixelLocations, lumenImage, 1);
    lumenImage = addTipsImg3D(tipValue+1, lumenImage);
    lumenImage = double(lumenImage);
    
    
    if 0 %% WT yes
        [x, y, z] = ind2sub(size(lumenImage), find(lumenImage));
        pixelLocations = [x, y, z];
        [lumenImage] = smoothObject(lumenImage, pixelLocations, -1);
    end
    

    %% Remove pixels of lumen from the cells image

    lumenImageLabel = bwlabeln(lumenImage,26);
    volume = regionprops3(lumenImageLabel,'Volume');
    [~,indMax] = max(cat(1,volume.Volume));
    lumenImage = lumenImageLabel==indMax;
    
    labelledImage(lumenImage == 1) = 0;
end