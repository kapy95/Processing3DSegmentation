function [CellularFeaturesWithNoValidCells, meanSurfaceRatio, apicobasal_neighbours] = calculate_CellularFeatures(apical3dInfo,basal3dInfo,apicalLayer,basalLayer,labelledImage,noValidCells,validCells,outputDir, total_neighbours3D)
%CALCULATE_CELLULARFEATURES Summary of this function goes here
%   Detailed explanation goes here

%% Check if there is any atypical cell.
if isempty(outputDir)==0
    if contains(lower(outputDir), 'echinoid')
        loadEchnoidAtypicalCells = 1;
    else
        loadEchnoidAtypicalCells = 0;
    end
else
    loadEchnoidAtypicalCells = 0;
end

if loadEchnoidAtypicalCells
    if exist(fullfile(outputDir, 'atypicalCells.mat'), 'file')
        load(fullfile(outputDir, 'atypicalCells.mat'))
    else
        prompt = {'Enter atypical cells:'};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {'20','hsv'};
        atypicalCells = inputdlg(prompt,dlgtitle,dims,definput);
        atypicalCells = str2num(atypicalCells{1});
        save(fullfile(outputDir, 'atypicalCells.mat'), 'atypicalCells')
    end
    
    [basal3dInfo] = checkAtypicalCells(atypicalCells,basal3dInfo);
    [apical3dInfo] = checkAtypicalCells(atypicalCells,apical3dInfo);
end

%% Check cell motives that participate in apico-basal intercalations.
apicobasal_neighbours=cellfun(@(x,y)(unique(vertcat(x,y))), apical3dInfo, basal3dInfo, 'UniformOutput',false);
apicoBasalTransitionsLabels = cellfun(@(x, y) unique(vertcat(setdiff(x, y), setdiff(y, x))), apical3dInfo, basal3dInfo, 'UniformOutput', false);
apicoBasalTransitions = cellfun(@(x) length(x), apicoBasalTransitionsLabels);
[verticesInfo] = getVertices3D(labelledImage, apicobasal_neighbours);
indexCells = find(apicoBasalTransitions>0);
totalMsgs = 'Motives that could not be involved in apico-basal intercalations';

for nIndex= 1:length(indexCells')
    [row,~]=find(verticesInfo.verticesConnectCells==indexCells(nIndex));
    pairedCells = apicoBasalTransitionsLabels{1,indexCells(nIndex)};
    for indexPairedCells = 1:length(pairedCells)
        [row2,~]=find(verticesInfo.verticesConnectCells == pairedCells(indexPairedCells));
        rows = intersect(row,row2);
        chosenNumbers = verticesInfo.verticesConnectCells(rows,:);
        wrongScutoids = unique(chosenNumbers(:)');
         otherMotifCells = setdiff(wrongScutoids,[pairedCells(indexPairedCells) indexCells(nIndex)]);
        if ismember(otherMotifCells(1) ,apicoBasalTransitionsLabels{1,otherMotifCells(end)}) == 0 || length(otherMotifCells) > 2
            msg1 = 'All cells of this motif could not be involved in a apico-basal intercalation: ';
            msg2= string(num2str(unique(chosenNumbers(:)')));
            msg=strcat(msg1,msg2);
            if ismember(msg2,totalMsgs) == 0
                totalMsgs = [totalMsgs, msg2];
                warning(msg);
            end
            if length(otherMotifCells) == 2
                newApicalNeighs = apical3dInfo{1,indexCells(nIndex)}';
                  newApicalNeighs(newApicalNeighs == pairedCells(indexPairedCells)) = [];
                newBasalNeighs = basal3dInfo{1,indexCells(nIndex)}';
                  newBasalNeighs(newBasalNeighs == pairedCells(indexPairedCells)) = [];
                apical3dInfo{1,indexCells(nIndex)} = newApicalNeighs';
                basal3dInfo{1,indexCells(nIndex)} = newBasalNeighs';
            end
        end
    end
end

%% Calculate poligon distribution
[polygon_distribution_Apical] = calculate_polygon_distribution(cellfun(@length, apical3dInfo), validCells);
[polygon_distribution_Basal] = calculate_polygon_distribution(cellfun(@length, basal3dInfo), validCells);
neighbours_data = table(apical3dInfo, basal3dInfo);
polygon_distribution = table(polygon_distribution_Apical, polygon_distribution_Basal);
neighbours_data.Properties.VariableNames = {'Apical','Basal'};
polygon_distribution.Properties.VariableNames = {'Apical','Basal'};

%%  Calculate number of neighbours of each cell
if exist('total_neighbours3D', 'var') == 0
    total_neighbours3D = calculateNeighbours3D(labelledImage, 2);
    total_neighbours3D = checkPairPointCloudDistanceCurateNeighbours(labelledImage, total_neighbours3D.neighbourhood', 1);
end
if length(apical3dInfo) > length(basal3dInfo)
    basal3dInfo(length(apical3dInfo)) = {[]};
elseif length(apical3dInfo) < length(basal3dInfo)
    apical3dInfo(length(basal3dInfo)) = {[]};
end
number_neighbours = table(cellfun(@length,(apical3dInfo)),cellfun(@length,(basal3dInfo)));
apicobasal_neighbours=cellfun(@(x,y)(unique(vertcat(x,y))), apical3dInfo, basal3dInfo, 'UniformOutput',false);


if length(total_neighbours3D) < length(apicobasal_neighbours)
    total_neighbours3D(length(apicobasal_neighbours)) = {[]};
end
total_neighbours3DRecount=cellfun(@(x) length(x), total_neighbours3D, 'UniformOutput',false);
apicobasal_neighboursRecount=cellfun(@(x) length(x),apicobasal_neighbours,'UniformOutput',false);

%%  Calculate area cells
apical_area_cells=cell2mat(struct2cell(regionprops(apicalLayer,'Area'))).';
basal_area_cells=cell2mat(struct2cell(regionprops(basalLayer,'Area'))).';
if length(apical_area_cells) > length(basal_area_cells)
    basal_area_cells(length(apical3dInfo)) = 0;
    neighbours_data.Basal(length(apical3dInfo)) = {[]};
elseif length(apical_area_cells) < length(basal_area_cells)
    apical_area_cells(length(basal3dInfo)) = 0;
    neighbours_data.Apical(length(basal3dInfo)) = {[]};
end
surfaceRatio = basal_area_cells ./ apical_area_cells;
%meanSurfaceRatio = mean(surfaceRatioValidCells);
meanSurfaceRatio = sum(basal_area_cells(validCells)) / sum(apical_area_cells(validCells));

%%  Calculate volume cells
volume_cells=table2array(regionprops3(labelledImage,'Volume'));

%%  Determine if a cell is a scutoid or not
scutoids_cells=cellfun(@(x,y) double(~isequal(x,y)), neighbours_data.Apical,neighbours_data.Basal);
apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(x, y), setdiff(y, x)))), neighbours_data.Apical,neighbours_data.Basal);

%%  Export to a excel file
ID_cells=(1:length(basal3dInfo)).';
CellularFeatures=table(ID_cells,number_neighbours.Var1',number_neighbours.Var2',total_neighbours3DRecount',apicobasal_neighboursRecount',scutoids_cells', apicoBasalTransitions', apical_area_cells,basal_area_cells, surfaceRatio, volume_cells);
CellularFeatures.Properties.VariableNames = {'ID_Cell','Apical_sides','Basal_sides','Total_neighbours','Apicobasal_neighbours','Scutoids', 'apicoBasalTransitions', 'Apical_area','Basal_area', 'Surface_Ratio','Volume'};
CellularFeaturesWithNoValidCells = CellularFeatures;
CellularFeatures(noValidCells,:)=[];


% if isempty(outputDir) == 0
%     writetable(CellularFeatures,fullfile(outputDir, 'cellular_features_LimeSeg3DSegmentation.xls'), 'Range','B2');
% 
%     %% Poligon distribution 
%     polygon_distribution_3D=calculate_polygon_distribution(cellfun(@length, apicobasal_neighbours), validCells);
%     writetable(table('','VariableNames',{'Apical'}),fullfile(outputDir,'Results', 'cellular_features_LimeSeg3DSegmentation.xls'), 'Sheet', 2, 'Range', 'B2')
%     writetable(table(polygon_distribution.Apical),fullfile(outputDir,'Results', 'cellular_features_LimeSeg3DSegmentation.xls'), 'Sheet', 2, 'Range', 'B3', 'WriteVariableNames',false);
%     writetable(table('','VariableNames',{'Basal'}),fullfile(outputDir,'Results', 'cellular_features_LimeSeg3DSegmentation.xls'), 'Sheet', 2, 'Range', 'B6')
%     writetable(table(polygon_distribution.Basal),fullfile(outputDir,'Results', 'cellular_features_LimeSeg3DSegmentation.xls'), 'Sheet', 2, 'Range', 'B7', 'WriteVariableNames',false);
%     writetable(table('','VariableNames',{'Accumulate'}),fullfile(outputDir,'Results', 'cellular_features_LimeSeg3DSegmentation.xls'), 'Sheet', 2, 'Range', 'B10')
%     writetable(table(polygon_distribution_3D),fullfile(outputDir,'Results', 'cellular_features_LimeSeg3DSegmentation.xls'), 'Sheet', 2, 'Range', 'B11', 'WriteVariableNames',false);
% end
