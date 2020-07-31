function [labelledImage] = edited_processCells(directoryOfCell, resizeImg, imgSize, zScale, tipValue)
%PROCESSCELLS Obtain cells from output limeSeg
%   Import the point cloud of cells to create a 3D image (as a 3D matrix)
%   that will allow to use it here on Matlab.

    cellFiles = dir(directoryOfCell);
    
    if size(cellFiles, 1) == 0
        ME = MException('MyComponent:noCells', ...
        'No cells were found');
        throw(ME)
    end
    imgSize=round(imgSize);%cambio
    labelledImage = zeros(imgSize);

%     figure;
        %plyFile = fullfile(cellFiles().folder, cellFiles(numCe).name, 'T_1.ply');
        plyFile=strcat(strcat(cellFiles(4).folder,"\"),cellFiles(4).name);%el cuarto elemento siempre es el ply
        ptCloud = pcread(plyFile);
        pixelLocations = double(ptCloud.Location);
        pixelLocations(:,1:2) = pixelLocations(:,1:2).*resizeImg;
        pixelLocations(:,3) = pixelLocations(:,3)./zScale;
        
        if ~isempty(pixelLocations)
            try
                % Import a single cell
                [labelledImage] = addCellToImage(round(pixelLocations(:,[2,1,3])), labelledImage,1);
            catch ex
                if isequal(ex.message, 'The alpha shape is empty.')
                    newException = MException(ex.identifier,strcat('There is a cell with no points. Please, check if that cell should have points or, instead, remove the directory: ', cellFiles(numCell).name));
                    throwAsCaller(newException);
                    %throw(ex)
                end
            end
        end
%         [x,y,z] = ind2sub(size(labelledImage),find(labelledImage>0));
%         pcshow(ptCloud);
    
    %Crop image 3D to minimal bounding box
    %props = regionprops3(labelledImage>0, 'BoundingBox');
    %bbox = props.BoundingBox;
    %labelledImage = labelledImage(floor(bbox(2)):size(labelledImage, 1), floor(bbox(1)):size(labelledImage, 2), :);
    
%     % Fill cells
%     se = strel('sphere',8);
%     for numCell = 1:size(cellFiles, 1)
%         numCell
%         maskImg = labelledImage == numCell;
% %         sum(maskImg(:))
%         objectDilated = imdilate(maskImg>0, se);
%         objectDilated = imfill(objectDilated, 'holes');
%         maskImgFilled = imerode(objectDilated, se);
% %         sum(maskImgFilled(:))
%         labelledImage(maskImgFilled>0) = numCell;
%     end
    
    labelledImage = addTipsImg3D(tipValue, labelledImage);
%     labelledImage = double(labelledImage);
%     
%     % HERE WE CHANGE THE LABELS OF LABELLED IMAGE (CARE)
%     [labelledImage] = fillEmptySpacesByWatershed3D(labelledImage, outsideGland);

end

