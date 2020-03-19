function segmentationPostProcessing(labelledImage,lumenImage,apicalLayer,basalLayer,outputDir,resizeImg,tipValue,glandOrientation,colours)
    %%Once lumen and cells have been adquired, this function provide a
    %%modification by means of window() 

    outsideGland = labelledImage == 0 & imdilate(lumenImage, strel('sphere', 1)) == 0;

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

    setappdata(0,'imageSequence',imageSequence);    
    setappdata(0,'outputDir', outputDir);
    setappdata(0,'labelledImage',labelledImage);
    setappdata(0,'lumenImage', lumenImage);
    setappdata(0,'resizeImg',resizeImg);
    setappdata(0,'tipValue', tipValue);
    setappdata(0, 'glandOrientation', glandOrientation);
    setappdata(0, 'canModifyOutsideGland', 0);
    setappdata(0, 'hideLumen',0);
    setappdata(0, 'canModifyInsideLumen',0);
    setappdata(0, 'colours', colours);


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
    [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(addTipsImg3D(tipValue,labelledImage), addTipsImg3D(tipValue,lumenImage), addTipsImg3D(tipValue,apicalLayer),addTipsImg3D(tipValue,basalLayer), colours, noValidCells);

    %% Insert no valid cells
    while isequal(answer, 'Yes')
        %volumeViewer(vertcat(labelledImage>0, lumenImage))
        setappdata(0, 'notFoundCellsApical', notFoundCellsApical);
        setappdata(0, 'notFoundCellsBasal', notFoundCellsBasal);
        h = window();
        waitfor(h);

        savingResults = saveResults();

        if isequal(savingResults, 'Yes')
            labelledImage = getappdata(0, 'labelledImageTemp');
            lumenImage = getappdata(0, 'lumenImageTemp');
            colours = getappdata(0, 'colours');

            close all
            [labelledImage, basalLayer, apicalLayer] = postprocessGland(labelledImage,labelledImage==0, lumenImage, outputDir, colours, tipValue);
           
            %% Save apical and basal 3d information
            save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')
    
            [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(addTipsImg3D(tipValue,labelledImage), addTipsImg3D(tipValue,lumenImage), addTipsImg3D(tipValue,apicalLayer),addTipsImg3D(tipValue,basalLayer), colours, noValidCells);
            
            setappdata(0,'labelledImage',labelledImage);
            setappdata(0,'lumenImage',lumenImage);
        else
            [answer] = isEverythingCorrect();
        end
        %volumeViewer close

    end

    %% Save apical and basal 3d information
    save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')

    %% Export to excel cellular features
    cellularFeatures = calculate_CellularFeatures(apical3dInfo,basal3dInfo,apicalLayer,basalLayer,addTipsImg3D(tipValue,labelledImage),noValidCells,validCells,outputDir);
    
    save(fullfile(outputDir, 'Results', 'cellularFeaturesExcel.mat'), 'cellularFeatures'); 




end

