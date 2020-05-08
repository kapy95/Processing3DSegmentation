function segmentationPostProcessing(labelledImage,lumenImage,apicalLayer,basalLayer,outputDir,resizeImg,tipValue,glandOrientation,colours)
    %%Once lumen and cells have been adquired, this function provide a
    %%modification by means of window() 

    %load imageSequence
    imageSequenceFiles = dir(fullfile(outputDir, 'ImageSequence/*.tif'));
    NoValidFiles = startsWith({imageSequenceFiles.name},'._','IgnoreCase',true);
    imageSequenceFiles = imageSequenceFiles(~NoValidFiles);
    imageSequence = [];

    for numImg = 1:size(imageSequenceFiles, 1)
        actualFile = imageSequenceFiles(numImg);
        actualImg = imread(fullfile(actualFile.folder, actualFile.name));
        imageSequence(:, :, numImg) = actualImg';
    end

    if exist(fullfile(outputDir, 'Results', 'valid_cells.mat'), 'file')
        load(fullfile(outputDir, 'Results', 'valid_cells.mat'))
    else
        [noValidCells] = insertNoValidCells();
        validCells = setdiff(1:max(labelledImage(:)), noValidCells);
        if noValidCells == -1
            noValidCells = [];
        end 
        save(fullfile(outputDir, 'Results', 'valid_cells.mat'), 'noValidCells', 'validCells')
    end
    [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(labelledImage, lumenImage, apicalLayer,basalLayer, colours, noValidCells);

    %% Insert no valid cells
    while isequal(answer, 'Yes')
        %volumeViewer(vertcat(labelledImage>0, lumenImage))
        [h, labelledImage_Temp, lumenImage_Temp, colours_Temp] = window(imageSequence, outputDir, labelledImage, lumenImage, resizeImg, tipValue, glandOrientation, colours, notFoundCellsApical, notFoundCellsBasal);

        savingResults = saveResults();

        if isequal(savingResults, 'Yes')
            %% Get info from window
            labelledImage = labelledImage_Temp;
            lumenImage = lumenImage_Temp;
            colours = colours_Temp;

            close all
            [basalLayer, apicalLayer] = postprocessGland(labelledImage,labelledImage==0, lumenImage, outputDir, colours, 0);
           
            %% Save apical and basal 3d information
            save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')
    
            [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(labelledImage, lumenImage, apicalLayer,basalLayer, colours, noValidCells);
            
            %setappdata(0,'labelledImage',labelledImage);
            %setappdata(0,'lumenImage',lumenImage);
        else
            [answer] = isEverythingCorrect();
        end
        %volumeViewer close

    end

    %% Save image with real size
    
    %% Save apical and basal 3d information
    save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')

%     %% Export to excel cellular features
%     cellularFeatures = calculate_CellularFeatures(apical3dInfo,basal3dInfo,apicalLayer,basalLayer,labelledImage,noValidCells,validCells,outputDir);
%     
%     save(fullfile(outputDir, 'Results', 'cellularFeaturesExcel.mat'), 'cellularFeatures'); 




end

