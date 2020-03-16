%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath('gui'))

close all

[indx,tf] = listdlg('PromptString',{'Select a mode'},'SelectionMode','single','ListString',{'LimeSeg','PlantSeg'});

switch indx
    case 1
        selpath = uigetdir('data');
        if isempty(selpath) == 0
            limeSeg_PostProcessing(selpath);
        end
    case 2
        [fileName, selpath] = uigetfile('*.*');
        if isempty(selpath) == 0
            plantSeg_PostProcessing(selpath, fileName);
        end
end


