function [resizeImg,imgSize,tipValue]=limeSeg_PostProcessing_adapted(outputDir)
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here

    %zScale=4.06;
    
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

    %colours = [];
        
    
end 