function [neighboursInfo] = checkAtypicalCells(atypicalCells,neighboursInfo)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    for nCells = 1:length(atypicalCells)
        for indexCell = 1:size(neighboursInfo,2)
        
            if ismember(atypicalCells(nCells),neighboursInfo{1,indexCell})
                selectedCell = neighboursInfo{1,indexCell};
                selectedCell(selectedCell == atypicalCells(nCells)) = [];
                neighboursInfo{1,indexCell} = selectedCell;
            end

        end
    end
end

