function [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(labelledImage, lumenImage, apicalLayer, basalLayer, colours, noValidCells)
%CALCULATEMISSINGCELLS Calculate and plot missing cells in both layers
%   We calculate which cells are missing from apical and basal layer, which
%   may be a mistake. In addition, we plot the layers and where are the
%   missing cells.

    allCells = unique(labelledImage(:));
    allCells(allCells == 0) = [];
    
    [apical3dInfo] = calculateNeighbours3D(apicalLayer, 2, apicalLayer == 0);
    apical3dInfo = apical3dInfo.neighbourhood';
%     apical3dInfo = getNeighboursFromFourProjectedPlanesFrom3Dgland(apicalLayer, colours);
%     apical3dInfo = checkPairPointCloudDistanceCurateNeighbours(apicalLayer, apical3dInfo);
    if length(allCells) ~= length(apical3dInfo)
        addingCells = length(allCells) - length(apical3dInfo);
        apical3dInfo(end+addingCells) = {[]};
    end
    notFoundCellsApical = find(cellfun(@(x) isempty(x), apical3dInfo))';

    %Display missing cells in basal
    [basal3dInfo] = calculateNeighbours3D(basalLayer, 2, basalLayer == 0);
    basal3dInfo = basal3dInfo.neighbourhood';
%     basal3dInfo = getNeighboursFromFourProjectedPlanesFrom3Dgland(basalLayer, colours);
%     basal3dInfo = checkPairPointCloudDistanceCurateNeighbours(basalLayer, basal3dInfo);
    if length(allCells) ~= length(basal3dInfo)
        addingCells = length(allCells) - length(basal3dInfo);
        basal3dInfo(end+addingCells) = {[]};
    end
    notFoundCellsBasal = find(cellfun(@(x) isempty(x), basal3dInfo))';

    answer = 'Yes';
%     %% Plot with missing cells
%     figure;
%     set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
%     %Basal plot
%     subplot(2, 2, 1);
%     paint3D(basalLayer, [], colours);
%     title('Basal layer');
% 
%     %Apical plot
%     subplot(2, 2, 2);
%     paint3D(apicalLayer, [], colours);
%     title('Apical layer');
% 
%     %Basal missing cells
%     missingCellsStr = [];
%     %notFoundCellsBasal = setdiff(notFoundCellsBasal, noValidCells);
%     subplot(2, 2, 3);
%     if isempty(notFoundCellsBasal) == 0
%         paint3D(labelledImage, notFoundCellsBasal, colours);
%         missingCellsStr = strjoin(arrayfun(@num2str, notFoundCellsBasal, 'UniformOutput', false), ', ');
% %     else
% %         paint3D(labelledImage, [], colours);
%     end
%     
%     paint3D(lumenImage, 1);
%     title(strcat('Missing basal cells: ', missingCellsStr));
% 
%     %Apical missing cells
%     subplot(2, 2, 4);
%     %notFoundCellsApical = setdiff(notFoundCellsApical, noValidCells);
%     if isempty(notFoundCellsApical) == 0
%         paint3D(labelledImage, notFoundCellsApical, colours);
%         missingCellsStr = strjoin(arrayfun(@num2str, notFoundCellsApical, 'UniformOutput', false), ', ');    
% %     else
% %         paint3D(labelledImage, [], colours);
%     end
%     paint3D(lumenImage, 1);
%     
%     title(strcat('Missing apical cells: ', missingCellsStr));
% 
%     [answer] = isEverythingCorrect();
end

