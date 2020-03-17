function [] = showSelectedCell(XLimOriginal, YLimOriginal)
%SHOWSELECTEDCELL Summary of this function goes here
%   Detailed explanation goes here
selectCellId = getappdata(0, 'cellId');
labelledImage_Resized = getappdata(0, 'labelledImageTemp_Resized');
labelledImage = getappdata(0, 'labelledImageTemp');
selectedZ = getappdata(0, 'selectedZ');
lumenImage = getappdata(0, 'lumenImage_Resized');
showAllCells = getappdata(0, 'showAllCells');
imageSequence = getappdata(0, 'imageSequence');
resizeImg = getappdata(0, 'resizeImg');
colours = getappdata(0, 'colours');

imgToShow = mat2gray(imageSequence(:, :, selectedZ)');

cla

if showAllCells==1
    %% Showing all cells
    labImageZ = labelledImage_Resized(:, :,  selectedZ)';
    centLab = cat(1,regionprops(labImageZ,'Centroid'));
    centroids = vertcat(centLab.Centroid);
    labelsZ = unique(labImageZ);
    
    B = labeloverlay(imgToShow, labelledImage(:, :,  selectedZ)', 'Colormap', colours);
    imshow(B);
    hold on;
    if isempty(centroids) == 0
        textscatter(centroids(labelsZ(2:end),1)/resizeImg,centroids(labelsZ(2:end),2)/resizeImg,cellfun(@num2str,num2cell(labelsZ(2:end)),'UniformOutput',false),'TextDensityPercentage',100,'ColorData',ones(length(labelsZ(2:end)),3));
        if selectCellId > 0 && selectCellId <= max(labelsZ(:))
            textscatter(centroids(selectCellId,1)/resizeImg,centroids(selectCellId,2)/resizeImg,num2cell(selectCellId),'TextDensityPercentage',100,'ColorData', [1 1 1], 'FontWeight', 'bold', 'FontSize', 11);
        end
    end
else
    imshow(imgToShow);
    if selectCellId > 0
        [xIndices, yIndices] = find(labelledImage_Resized(:, :,  selectedZ) == selectCellId);
        if isempty(xIndices) == 0
            hold on
            s2 = scatter(xIndices/resizeImg, yIndices/resizeImg, 'blue','filled','SizeData',10);
            hold off
            alpha(s2,.4)
        end
    end
    hold off
end

%% Showing lumen
[xIndices, yIndices] = find(lumenImage(:, :,  selectedZ) == 1);
if isempty(xIndices) == 0 && getappdata(0, 'hideLumen') == 0
    hold on
    s = scatter(xIndices/resizeImg, yIndices/resizeImg, 'red', 'filled','SizeData',10);
    hold off
    alpha(s,.5)
end

if exist('YLimOriginal', 'var')
    set(gca, 'XLim', XLimOriginal);
    set(gca, 'YLim', YLimOriginal);
end

end

