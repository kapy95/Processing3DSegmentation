%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath('gui'))

close all

[indx,tf] = listdlg('PromptString',{'Select a mode'},'SelectionMode','single','ListString',{'LimeSeg','PlantSeg'});
data="E:\TFM";
%%ptCloud = pcread('E:\TFM\3a bien\3a\3a\Cells\OutputLimeSeg\cell_912\T_1.ply');
%%pcshow(ptCloud);

switch indx
    case 1
        selpath = uigetdir(data);
        if isempty(selpath) == 0
            limeSeg_PostProcessing(selpath);
        end
    case 2
        [fileName, selpath] = uigetfile('*.*');
        if isempty(selpath) == 0
            plantSeg_PostProcessing(selpath, fileName);
        end
    otherwise
        
end


