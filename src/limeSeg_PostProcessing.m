function limeSeg_PostProcessing(outputDir)
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here
    mkdir(fullfile(outputDir, 'Cells', 'OutputLimeSeg'));
    mkdir(fullfile(outputDir, 'ImageSequence'));
    mkdir(fullfile(outputDir, 'Lumen', 'SegmentedLumen'));
    mkdir(fullfile(outputDir, 'Results'));
    mkdir(fullfile(outputDir, 'Apical_Labelled'));


    if exist(fullfile(outputDir, 'Results', 'zScaleOfGland.mat'), 'file') == 0
        zScale = inputdlg('Insert z-scale of Gland');
        zScale = str2double(zScale{1});

        save(fullfile(outputDir, 'Results', 'zScaleOfGland.mat'), 'zScale');
    else
        load(fullfile(outputDir, 'Results', 'zScaleOfGland.mat')); 
    end
    
    if exist(fullfile(outputDir, 'Results', 'pixelScaleOfGland.mat'), 'file') == 0
        pixelScale = inputdlg('Insert pixel width of Gland');
        pixelScale = str2double(pixelScale{1});

        save(fullfile(outputDir, 'Results', 'pixelScaleOfGland.mat'), 'pixelScale');
    else
        load(fullfile(outputDir, 'Results', 'pixelScaleOfGland.mat')); 
    end
    
    resizeImg = 0.25;

    tipValue = 5;

    imageSequenceFiles = dir(fullfile(outputDir, 'ImageSequence/*.tif'));
    NoValidFiles = startsWith({imageSequenceFiles.name},'._','IgnoreCase',true);
    imageSequenceFiles=imageSequenceFiles(~NoValidFiles);
    demoFile =  imageSequenceFiles(3);
    demoImg = imread(fullfile(demoFile.folder, demoFile.name));
    
    imageSequence = zeros(size(demoImg,1),size(demoImg,2),size(imageSequenceFiles, 1));
    for numImg = 1:size(imageSequenceFiles, 1)
        actualFile = imageSequenceFiles(numImg);
        actualImg = imread(fullfile(actualFile.folder, actualFile.name));
        imageSequence(:, :, numImg) = actualImg;
    end
    imgSize = size(imageSequence);
    imgSize(1:2)= imgSize(1:2).*resizeImg;
    %imgSize = size(imresize(demoImg, resizeImg));

    if exist(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'file')
        load(fullfile(outputDir, 'Results', '3d_layers_info.mat'))
    else
        colours = [];
        [labelledImage, outsideGland] = processCells(fullfile(outputDir, 'Cells', filesep), resizeImg, imgSize, zScale, tipValue);
        
     if size(dir(fullfile(outputDir, 'Lumen/SegmentedLumen', '*.tif')),1) > 0
        [labelledImage, lumenImage] = processLumen(fullfile(outputDir, 'Lumen', filesep), labelledImage, resizeImg, tipValue);
     else
        [labelledImage, lumenImage] = inferLumen(labelledImage);
     end
     
        %It add pixels and remove some
        validRegion = imfill(bwmorph3(labelledImage>0 | imdilate(lumenImage, strel('sphere', 5)), 'majority'), 'holes');
        %outsideGland = validRegion == 0;
        questionedRegion = imdilate(outsideGland, strel('sphere', 2));
        outsideGland(questionedRegion) = ~validRegion(questionedRegion);
        outsideGland(lumenImage) = 0;
        
        labelledImage = fill0sWithCells(labelledImage, labelledImage, outsideGland | lumenImage);
            
        %% Put both lumen and labelled image at a 90 degrees
        orientationGland = regionprops3(lumenImage>0, 'Orientation');
        glandOrientation = -orientationGland.Orientation(1);
        %labelledImage = imrotate(labelledImage, glandOrientation);
        %lumenImage = imrotate(lumenImage, glandOrientation);
        
        labelledImage = addTipsImg3D(-tipValue,labelledImage);
        outsideGland = addTipsImg3D(-tipValue,outsideGland);
        lumenImage = addTipsImg3D(-tipValue,lumenImage);
        
        [labelledImage, basalLayer, apicalLayer, colours] = postprocessGland(labelledImage, outsideGland, lumenImage, outputDir, colours, tipValue);
    end
    imgSize(1:2)= imgSize(1:2)./resizeImg;
    labelledImage = imresize3(labelledImage,imgSize,'nearest');
    lumenImage = imresize3(lumenImage,imgSize,'nearest');
    %%%From this lime limeSeg_PostProcessing and platSeg_PostProcessing are
    %%%equal
    outsideGland = labelledImage == 0 & imdilate(lumenImage, strel('sphere', 1)) == 0;

    
    
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
        h = window();
        waitfor(h);

        savingResults = saveResults();

        if isequal(savingResults, 'Yes')
            labelledImage = getappdata(0, 'labelledImageTemp');
            lumenImage = getappdata(0, 'lumenImage');
            close all
            [labelledImage, basalLayer, apicalLayer] = postprocessGland(labelledImage,labelledImage==0, lumenImage, outputDir, colours, tipValue);
           
            %% Save apical and basal 3d information
            save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')
    
            [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(addTipsImg3D(tipValue,labelledImage), addTipsImg3D(tipValue,lumenImage), addTipsImg3D(tipValue,apicalLayer),addTipsImg3D(tipValue,basalLayer), colours, noValidCells);
        else
            [answer] = isEverythingCorrect();
        end
        setappdata(0,'labelledImage',labelledImage);
    end

    %% Save apical and basal 3d information
    save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')

    %% Export to excel cellular features
    cellularFeatures = calculate_CellularFeatures(apical3dInfo,basal3dInfo,apicalLayer,basalLayer,addTipsImg3D(tipValue,labelledImage),noValidCells,validCells,outputDir);
    
    save(fullfile(outputDir, 'Results', 'cellularFeaturesExcel.mat'), 'cellularFeatures'); 
end