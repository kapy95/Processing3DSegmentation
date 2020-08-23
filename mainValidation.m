%% First pipeline to validate the automatic hyperparameter
addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath('gui'))

close all

%originalDataDirectory="E:\TFM\DatosGeneral\Newdata\data\Drosophila embryo\WT\04-10-18";
originalDataDirectory="E:\TFM\3a-2\3a\3a";
%ptCloud = pcread('E:\TFM\3a bien\3a\3a');

[resizeImg,imgSize,zScale,tipValue]=limeSeg_PostProcessing_adapted(originalDataDirectory);
%zScale=3.52;%zscale de embryo
zScale=4.06;
%originalSegmentationDirectory="E:\TFM\DatosGeneral\Newdata\data\Drosophila embryo\WT\04-10-18\Cells\OutputLimeSeg";
originalSegmentationDirectory="E:\TFM\3a-2\3a\3a\Cells\OutputLimeSeg";
originaLabelledImage = processCells(originalSegmentationDirectory, resizeImg, imgSize, zScale, tipValue);

%paint3D(originaLabelledImage)

realLogicalImage=logical(originaLabelledImage);

%directorioSoluciones=dir("E:\TFM\Experimentación\23.06.2020\50 generaciones, 100 individuos, volumen+std");
stringDir="E:\TFM\Experimentación\22.08.2020\Glándula,50 generaciones 100 ind, número de células no nulas por volumen promedio";
directorioSoluciones=dir(stringDir);
soloNombresDirectorios={directorioSoluciones.name};
indicesGeneraciones = startsWith(soloNombresDirectorios,'resultado generacion');
soloDirectoriosGeneraciones=directorioSoluciones(indicesGeneraciones);
contador=1;
%list = ls("E:\TFM\Experimentación\22.06.2020\50 generaciones, 100 individuos, volumen+std 2")

tam=size(soloDirectoriosGeneraciones);
tam=tam(1);
arrayCells=[{}];
contador=0;

[~, reindex] = sort( str2double( regexp( {soloDirectoriosGeneraciones.name}, '\d+', 'match', 'once' )));
soloDirectoriosGeneraciones=soloDirectoriosGeneraciones(reindex);
directoriosPrueba=string();


for indGen=1:50

    dirGen= strcat(strcat(soloDirectoriosGeneraciones(indGen).folder,"\"),soloDirectoriosGeneraciones(indGen).name);
    directorioGeneracion=dir(dirGen);
    directorioGeneracion([1,2])=[];%.,.. son borrados
    nombresDirectoriosGeneracion={directorioGeneracion.name}; %nombres de los archivos de esta generacion
    indicesCSVs = contains(nombresDirectoriosGeneracion,'.csv'); %indices de archivos CSV
    directorioGeneracion(indicesCSVs)=[]; %los archivos CSV son eliminados del método
    tamPob=size(directorioGeneracion);
    tamPob=tamPob(1);
    
     parfor(indPob=1:tamPob,12)
         
         dirSeg= strcat(strcat(directorioGeneracion(indPob).folder,"\"),directorioGeneracion(indPob).name);
         jaccardValue=limeSeg_validation(dirSeg,resizeImg,imgSize,zScale,tipValue,realLogicalImage);
         arrayCells{1,indPob+contador}={jaccardValue,directorioGeneracion(indPob).name};
         %arrayCells{1,contador}={jaccardValue,directorioGeneracion(indPob).name};
         %contador=contador+1;
         
     end
     
     contador=tamPob+contador;
    
end


automaticSegmentationDirectory=stringDir+"\resultado generacion50\mejor individuo gen49";
jaccardValueMejorIndividuo=limeSeg_validation(automaticSegmentationDirectory,resizeImg,imgSize,zScale,tipValue,realLogicalImage);

automaticSegmentationDirectory2=stringDir+"\resultado generacion50\segundo mejor individuo gen49";
jaccardValue2=limeSeg_validation(automaticSegmentationDirectory2,resizeImg,imgSize,zScale,tipValue,realLogicalImage);

numericArray=[];

[nrow,ncol]=size(arrayCells);
for numCell=1:ncol

	numericArray(numCell)=cell2mat(arrayCells{numCell}(1));

end


stringArray=string.empty;
for numCell=1:ncol

	stringArray(numCell)=string(arrayCells{numCell}(2));

end

stringArray=stringArray';
numericArray=numericArray';
T3 = table(stringArray,numericArray);
writetable(T3,'allResultsValidation.txt','Delimiter',',')


pos=find(numericArray>jaccardValueMejorIndividuo);

bestResults=numericArray(pos);
bestStrings=stringArray(pos);

bestStrings(size(bestStrings)+1)="Mejor individuo 50 iter";


bestResults(size(bestResults)+1)=jaccardValueMejorIndividuo;


%%%
T = table(bestStrings,bestResults);

writetable(T,'ValidationBestSolution.txt','Delimiter',',')




pos2=find(jaccardValue2<numericArray);


bestResults=numericArray(pos2);
bestStrings=stringArray(pos2);

bestStrings(size(bestStrings)+1)="Segundo mejor individuo 50 iter";


bestResults(size(bestResults)+1)=jaccardValue2;


T2 = table(bestStrings,bestResults);

writetable(T2,'ValidationSecondBestSolution.txt','Delimiter',',')



%score, jaccard score, F1 score and accuracy (precision) and recall. All values can be handled by matlab with function dice, jaccard, bfscore.
