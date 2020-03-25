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
            [indx,~] = listdlg('PromptString',{'Lumen selection'},'SelectionMode','single','ListString',{'Infer lumen','Draw in matlab'});
            switch indx                   
                case 1
                    [labelledImage, lumenImage] = inferLumen(labelledImage);
                case 2
                    lumenImage = zeros(size(labelledImage));
            end
        end
     
        %It add pixels and remove some
        validRegion = imfill(bwmorph3(labelledImage>0 | imdilate(lumenImage, strel('sphere', 5)), 'majority'), 'holes');
        %outsideGland = validRegion == 0;
        questionedRegion = imdilate(outsideGland, strel('sphere', 2));
        outsideGland(questionedRegion) = ~validRegion(questionedRegion);
        %% Put both lumen and labelled image at a 90 degrees
        if sum(lumenImage(:))>0
            outsideGland(lumenImage) = 0;

            orientationGland = regionprops3(lumenImage>0, 'Orientation');
            glandOrientation = -orientationGland.Orientation(1);
            %labelledImage = imrotate(labelledImage, glandOrientation);
            %lumenImage = imrotate(lumenImage, glandOrientation);
        else
            glandOrientation=0;
        end      
        
        answer = questdlg('Would you fill empty space with cell labels?','Choose', 'yes', 'no');
        
        % Handle response
        switch answer
            case 'yes'
                labelledImage = fill0sWithCells(labelledImage, labelledImage, outsideGland | lumenImage);
        end           
        
        labelledImage = addTipsImg3D(-tipValue,labelledImage);
        outsideGland = addTipsImg3D(-tipValue,outsideGland);
        lumenImage = addTipsImg3D(-tipValue,lumenImage);
        
        [labelledImage, basalLayer, apicalLayer, colours] = postprocessGland(labelledImage, outsideGland, lumenImage, outputDir, colours, tipValue);
    end
    imgSize(1:2)= imgSize(1:2)./resizeImg;
    labelledImage = imresize3(labelledImage,imgSize,'nearest');
    lumenImage = imresize3(double(lumenImage),imgSize,'nearest');
        
    segmentationPostProcessing(labelledImage,lumenImage,apicalLayer,basalLayer,outputDir,resizeImg,tipValue,glandOrientation,colours)
end