function limeSeg_PostProcessing(outputDir, fileName)
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

    tipValue = 0;

    imageSequenceFiles = [dir(fullfile(outputDir, 'ImageSequence/*.tif'));dir(fullfile(outputDir, 'ImageSequence/*.tiff'))];
    NoValidFiles = startsWith({imageSequenceFiles.name},'._','IgnoreCase',true);
    imageSequenceFiles=imageSequenceFiles(~(NoValidFiles));
      
    %% if there is only 1 image, convert to imageSequence, then load.
    if size(imageSequenceFiles,1) == 1
        fname = fullfile(imageSequenceFiles.folder, imageSequenceFiles.name);
        info = imfinfo(fname);
        num_images = numel(info);
        for k = 1:num_images
            demoImg = imread(fname, k);
            imwrite(demoImg , [imageSequenceFiles.folder '\image' num2str(k,'%03.f') '.tif']) ;
        end
        mkdir([imageSequenceFiles.folder,'\rawImageSequence\'])
        movefile(fname, [imageSequenceFiles.folder,'\rawImageSequence\' imageSequenceFiles.name]);
    else
        demoFile =  imageSequenceFiles(3);
        demoImg = imread(fullfile(demoFile.folder, demoFile.name));
    end
    
    if exist(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'file')
        load(fullfile(outputDir, 'Results', '3d_layers_info.mat'))
    else
        colours = [];
        selpath = fullfile(outputDir, fileName);
        tiff_info = imfinfo(selpath); % return tiff structure, one element per image
        tiff_stack = imread(selpath, 1) ; % read in first image
        %concatenate each successive tiff to tiff_stack
        for ii = 2 : size(tiff_info, 1)
            temp_tiff = imread(selpath, ii);
            tiff_stack = cat(3 , tiff_stack, temp_tiff);
        end
        
        %set the background to the '0' label
        if min(tiff_stack(:))==1
            labelledImage = double(tiff_stack)-1;
        else
            labelledImage = double(tiff_stack);
        end
        outsideGland = labelledImage == 0;
        
        if size(dir(fullfile(outputDir, 'Lumen/SegmentedLumen', '*.tif')),1) > 0
            [labelledImage, lumenImage] = processLumen(fullfile(outputDir, 'Lumen', filesep), labelledImage, resizeImg, tipValue);
        else
            %%Posible idea: try catch this line and if an error occurs get
            %%the biggest 'cell' from plantSeg
            %[labelledImage, lumenImage] = inferLumen(labelledImage);
            
            [cellsVolume] = regionprops3(labelledImage, 'Volume');
            [~, lumenIndex] = max(table2array(cellsVolume));
            lumenImage = labelledImage == lumenIndex;
            labelledImage(labelledImage == lumenIndex) = 0;
        end
            
        %% Put both lumen and labelled image at a 90 degrees
        orientationGland = regionprops3(lumenImage>0, 'Orientation');
        glandOrientation = -orientationGland.Orientation(1);
        
        [labelledImage, basalLayer, apicalLayer, colours] = postprocessGland(labelledImage,outsideGland, lumenImage, outputDir, colours, tipValue);
    end
    outsideGland = labelledImage == 0 & imdilate(lumenImage, strel('sphere', 1)) == 0;
    
    setappdata(0,'outputDir', outputDir);
    setappdata(0,'labelledImage',labelledImage);
    setappdata(0,'lumenImage', lumenImage);
    setappdata(0,'resizeImg', resizeImg);
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
    [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(labelledImage, lumenImage, apicalLayer, basalLayer, colours, noValidCells);

    
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
            lumenImage = getappdata(0, 'lumenImage');
            close all
            [labelledImage, basalLayer, apicalLayer] = postprocessGland(labelledImage,labelledImage==0, lumenImage, outputDir, colours, tipValue);
           
            %% Save apical and basal 3d information
            save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')
    
            [answer, apical3dInfo, notFoundCellsApical, basal3dInfo, notFoundCellsBasal] = calculateMissingCells(labelledImage, lumenImage, apicalLayer, basalLayer, colours, noValidCells);
        else
            [answer] = isEverythingCorrect();
        end
        setappdata(0,'labelledImage',labelledImage);
        volumeViewer close
    end

    %% Save apical and basal 3d information
    save(fullfile(outputDir, 'Results', '3d_layers_info.mat'), 'labelledImage', 'basalLayer', 'apicalLayer', 'apical3dInfo', 'basal3dInfo', 'colours', 'lumenImage','glandOrientation', '-v7.3')

    %% Export to excel cellular features
    cellularFeatures = calculate_CellularFeatures(apical3dInfo,basal3dInfo,apicalLayer,basalLayer,labelledImage,noValidCells,validCells,outputDir);
    
    save(fullfile(outputDir, 'Results', 'cellularFeaturesExcel.mat'), 'cellularFeatures'); 
end

