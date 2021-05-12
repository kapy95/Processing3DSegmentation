%%se añaden primero los directorios de src, lib,gui
addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath('gui'))
%se cierra todo
close all

%se introduce el directorio de datos original para leer una serie de datos
originalDataDirectory="E:\TFM\DatosGeneral\Newdata\data\Egg chamber\Stage 4\4_9";
%originalDataDirectory="E:\TFM\3a-2\3a\3a";
%ptCloud = pcread('E:\TFM\3a bien\3a\3a');

[resizeImg,imgSize,zScale,tipValue]=limeSeg_PostProcessing_adapted(originalDataDirectory);
zScale=5.59;%valor del zScale
%introducimos el directorio con los PLYs de la segmentación original
originalSegmentationDirectory="E:\TFM\DatosGeneral\Newdata\data\Egg chamber\Stage 4\4_9\Cells\OutputLimeSeg";

%obtenemos la  union de los plys en formato de matriz
originaLabelledImage = processCells(originalSegmentationDirectory, resizeImg, imgSize, zScale, tipValue);

%paint3D(originaLabelledImage)

%se pasa a binario esa matriz
realLogicalImage=logical(originaLabelledImage);

%directorioSoluciones=dir("E:\TFM\Experimentación\23.06.2020\50 generaciones, 100 individuos, volumen+std");

%se leen únicamente los directorios de los resultados 
stringDir="E:\TFM\Experimentación\12.09.2020\Eggchamber, 100 generaciones 50 individuos";
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
%se reordenan los directorios de las generaciones por orden:
[~, reindex] = sort( str2double( regexp( {soloDirectoriosGeneraciones.name}, '\d+', 'match', 'once' )));
soloDirectoriosGeneraciones=soloDirectoriosGeneraciones(reindex);



for indGen=1:101 %desde la generación 1 hasta X (en este caso 51)
    %se leen los archivos de un directorio
    dirGen= strcat(strcat(soloDirectoriosGeneraciones(indGen).folder,"\"),soloDirectoriosGeneraciones(indGen).name);
    directorioGeneracion=dir(dirGen);
    %se eliminan dos archivos
    directorioGeneracion([1,2])=[];%.,.. son borrados
    nombresDirectoriosGeneracion={directorioGeneracion.name}; %nombres de los archivos de esta generacion
    indicesCSVs = contains(nombresDirectoriosGeneracion,'.csv'); %indices de archivos CSV
    directorioGeneracion(indicesCSVs)=[]; %los archivos CSV son eliminados del método
    tamPob=size(directorioGeneracion);
    tamPob=tamPob(1);
    
     parfor(indPob=1:tamPob,12)%se inicia un for en paralelo con 12 hilos para realizar la siguiente operación:
         %se lee una solución
         dirSeg= strcat(strcat(directorioGeneracion(indPob).folder,"\"),directorioGeneracion(indPob).name);
         
         %se llama a la función limeSeg_validation en la que se genera la
         %matriz de la solución y se mide el indice de jaccard:
         jaccardValue=limeSeg_validation(dirSeg,resizeImg,imgSize,zScale,tipValue,realLogicalImage);
         
         %se añaden esos valores a una estructura donde se almacena el
         %nombre de una solución y su índice de Jaccard:
         arrayCells{1,indPob+contador}={jaccardValue,directorioGeneracion(indPob).name};
     end
     
     contador=tamPob+contador;
    
end

%se leen los directorios de los mejores individuos y se generan sus índices
%de Jaccard:
automaticSegmentationDirectory=stringDir+"\resultado generacion100\mejor individuo gen99";
jaccardValueMejorIndividuo=limeSeg_validation(automaticSegmentationDirectory,resizeImg,imgSize,zScale,tipValue,realLogicalImage);

automaticSegmentationDirectory2=stringDir+"\resultado generacion100\segundo mejor individuo gen99";
jaccardValue2=limeSeg_validation(automaticSegmentationDirectory2,resizeImg,imgSize,zScale,tipValue,realLogicalImage);

numericArray=[];

%se pasan a dos arrays los datos y se generan tablas con los datos:
[nrow,ncol]=size(arrayCells);
for numCell=1:ncol

    
	numericArray(numCell)=cell2mat(arrayCells{numCell}(1));

end


stringArray=string.empty;
for numCell=1:ncol

	stringArray(numCell)=string(arrayCells{numCell}(2));

end

stringArray=stringArray';%se invierte el array para que se genere la matriz correctamente
numericArray=numericArray';
T3 = table(stringArray,numericArray);
writetable(T3,'allResultsValidationGen12-50.txt','Delimiter',',')

pos=find(numericArray>jaccardValueMejorIndividuo);

bestResults=numericArray(pos);
bestStrings=stringArray(pos);

bestStrings(size(bestStrings)+1)="Mejor individuo 100 iter";


bestResults(size(bestResults)+1)=jaccardValueMejorIndividuo;


%%%
T = table(bestStrings,bestResults);

writetable(T,'ValidationBestSolution12iter.txt','Delimiter',',')

pos2=find(jaccardValue2<numericArray);


bestResults=numericArray(pos2);
bestStrings=stringArray(pos2);

bestStrings(size(bestStrings)+1)="Segundo mejor individuo 100 iter";


bestResults(size(bestResults)+1)=jaccardValue2;


T2 = table(bestStrings,bestResults);

writetable(T2,'ValidationSecondBestSolution50iter.txt','Delimiter',',')



%score, jaccard score, F1 score and accuracy (precision) and recall. All values can be handled by matlab with function dice, jaccard, bfscore.
