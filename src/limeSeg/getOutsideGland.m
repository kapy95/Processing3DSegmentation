function [outsideGland] = getOutsideGland(labelledImage)
%GETOUTSIDEGLAND Summary of this function goes here
%   Detailed explanation goes here
    [allX,allY,allZ] = ind2sub(size(labelledImage),find(zeros(size(labelledImage))==0));
    [x, y, z] = ind2sub(size(labelledImage), find(labelledImage>0));
    glandObject = alphaShape(x, y, z);
    pc = criticalAlpha(glandObject,'one-region');
    glandObject.Alpha = pc;

    numPartitions = 100;
    partialPxs = ceil(length(allX)/numPartitions);
    idIn = false(length(allX),1);
    for nPart = 1 : numPartitions
        subIndCoord = (1 + (nPart-1) * partialPxs) : (nPart * partialPxs);
        if nPart == numPartitions
            subIndCoord = (1 + (nPart-1) * partialPxs) : length(allX);
        end
        idIn(subIndCoord) = glandObject.inShape([allX(subIndCoord),allY(subIndCoord),allZ(subIndCoord)]);
    end
    outsideGland = true(size(labelledImage));
    outsideGland(idIn) = 0;
    
    insideGland = imdilate(outsideGland == 0, strel('sphere', 1));
    insideGlandFilled = imfill(double(insideGland),  4, 'holes');
    insideGlandFilled = imerode(insideGlandFilled, strel('sphere', 1));
    
    outsideGland = insideGlandFilled == 0;
end

