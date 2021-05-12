function createFigureSegmentations(labelledImage,colours,S,type)


showingCells = (1:max(labelledImage(:)))';
seeds=unique(showingCells);

% Create figure
figure('Color',[1 1 1])%,'OuterPosition',[672 550 576 493]);

% Create axes
axes1 = axes;
axis off
hold(axes1,'on');

% Create scatter3
for k = 1:length(seeds)
    [x,y,z] = ind2sub(size(labelledImage),find(labelledImage == seeds(k)));
    scatter3(x,y,z,S,colours(k,:),'Tag','pcviewer','Marker','.');
end

grid(axes1,'on');
axis(axes1,'tight');
hold(axes1,'off');
% Set the remaining axes properties

if type=="gland"
    view(axes1,[-26.8576048182767 17.9907531768049]);
    
    set(axes1,'CameraUpVector',[0 0 1],'CameraViewAngle',5.33473465929509,...
    'Color',[0 0 0],'DataAspectRatio',[1 1 1],'XColor',[0.8 0.8 0.8],'YColor',...
    [0.8 0.8 0.8],'ZColor',[0.8 0.8 0.8]);

elseif type=="embryo"
    set(axes1,'CameraPosition',...
    [-440.16995538786 -672.254997724941 469.465452867177],'CameraTarget',...
    [68.6946059882919 68.7662175761473 50.3062746912043],'CameraUpVector',...
    [0.258852302209034 0.334208359345851 0.906256176908294],'CameraViewAngle',...
    7.73567490890827,'Color',[0 0 0],'DataAspectRatio',[1 1 1],'XColor',...
    [0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],'ZColor',[0.8 0.8 0.8]);
elseif type=="eggchamber"
    set(axes1,'CameraPosition',...
    [-376.29066333152 -448.725321561924 323.638463067322],'CameraTarget',...
    [60.4882085427898 80.9331069221846 46.2647688929271],'CameraUpVector',...
    [0.283374575002631 0.341832059841636 0.896018801759485],'CameraViewAngle',...
    9.43115424592114,'Color',[0 0 0],'DataAspectRatio',[1 1 1],'XColor',...
    [0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],'ZColor',[0.8 0.8 0.8]);
end
