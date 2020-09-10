%% First pipeline to validate the automatic hyperparameter
addpath(genpath('src'))
addpath(genpath('lib'))
addpath(genpath('gui'))

close all

%originalDataDirectory="E:\TFM\DatosGeneral\Newdata\data\Drosophila embryo\WT\04-10-18";
originalDataDirectory="E:\TFM\3a-2\3a\3a";
%ptCloud = pcread('E:\TFM\3a bien\3a\3a');

[resizeImg,imgSize,zScale,tipValue]=limeSeg_PostProcessing_adapted(originalDataDirectory);
%originalSegmentationDirectory="E:\TFM\DatosGeneral\Newdata\data\Drosophila embryo\WT\04-10-18\Cells\OutputLimeSeg";
originalSegmentationDirectory="E:\TFM\3a-2\3a\3a\Cells\OutputLimeSeg";

directorioCelulasSegmentadasOriginales=dir(originalSegmentationDirectory);
directorioCelulasSegmentadasOriginales([1,2])=[];%.,.. son borrados
%indiceXML = contains(directorioCelulasSegmentadasOriginales,'.xml'); %indices de archivos XML
%directorioCelulasSegmentadasOriginales(indiceXML)=[];
tamPob=size(directorioCelulasSegmentadasOriginales);
originicalCellMatrices=cell(tamPob(1,1),1);%tamPob(1,1)-> number of cells
[~, reindex] = sort( str2double( regexp( {directorioCelulasSegmentadasOriginales.name}, '\d+', 'match', 'once' )));
directorioCelulasSegmentadasOriginales=directorioCelulasSegmentadasOriginales(reindex);
directoriosPrueba=string();

parfor (indtam=1:tamPob(1,1),10)
    
    directorioCell=strcat(strcat(directorioCelulasSegmentadasOriginales(indtam).folder,"\"),directorioCelulasSegmentadasOriginales(indtam).name);
    originaLabelledImageCell = edited_processCells(directorioCell, resizeImg, imgSize, zScale, tipValue);
    realLogicalImage=logical(originaLabelledImageCell);
    originicalCellMatrices{indtam,1}=realLogicalImage;
    directoriosPrueba(indtam)=directorioCell;
    
end
%paint3D(originaLabelledImage)

%realLogicalImage=logical(originaLabelledImage);

%directorioSoluciones=dir("E:\TFM\Experimentación\23.06.2020\50 generaciones, 100 individuos, volumen+std");
directorioSoluciones=dir("E:\TFM\Experimentación\03.08.2020\Glándula,50 gen, volume+percentil 90 std vertex");
soloNombresDirectorios={directorioSoluciones.name};
indicesGeneraciones = startsWith(soloNombresDirectorios,'resultado generacion');
soloDirectoriosGeneraciones=directorioSoluciones(indicesGeneraciones);
contador=1;
%list = ls("E:\TFM\Experimentación\22.06.2020\50 generaciones, 100 individuos, volumen+std 2")

tam=size(soloDirectoriosGeneraciones);
tam=tam(1);
arrayCells=[{}];

for indGen=1:10
    
    dirGen= strcat(strcat(soloDirectoriosGeneraciones(indGen).folder,"\"),soloDirectoriosGeneraciones(indGen).name);
    directorioGeneracion=dir(dirGen);
    directorioGeneracion([1,2])=[];%.,.. son borrados
    nombresDirectoriosGeneracion={directorioGeneracion.name}; %nombres de los archivos de esta generacion
    indicesCSVs = contains(nombresDirectoriosGeneracion,'.csv'); %indices de archivos CSV
    directorioGeneracion(indicesCSVs)=[]; %los archivos CSV son eliminados del método
    tamPob=size(directorioGeneracion);
    tamPob=tamPob(1);

    
     for indPob=1:tamPob
         
         dirSeg = strcat(strcat(directorioGeneracion(indPob).folder,"\"),directorioGeneracion(indPob).name);
         dirSolucion=dir(dirSeg);
         nombresDirectoriosSolucion={dirSolucion.name};
         indiceXML = contains(nombresDirectoriosSolucion,'.xml'); %indices de archivos XML
         dirSolucion(indiceXML)=[]; %los archivos CSV son eliminados del método
         dirSolucion(([1,2]))=[];
         tamCells=size(dirSolucion);
         jaccardValues=[];
         
         %some directories are not detected in the correct order ('cell_0','cell_10','cell_11'...etc) 
         %therefore it is necessary to tidy up again the structure with all the information
         %because each cell must be compared with his corresponding cell and not other.
         
         [~, reindex] = sort( str2double( regexp( {dirSolucion.name}, '\d+', 'match', 'once' )));
         dirSolucion=dirSolucion(reindex);
         
        parfor (indSol=1:tamCells(1,1),10)
             
             directorioCell=strcat(strcat(dirSolucion(indSol).folder,"\"),dirSolucion(indSol).name);
             realLogicalImage=originicalCellMatrices{indSol,1};
             jaccardValue=limeSeg_validation(directorioCell,resizeImg,imgSize,zScale,tipValue,realLogicalImage);
             jaccardValues(indSol)=jaccardValue;
             
        end
         
         jaccardAverageValue=mean(jaccardValues);
         arrayCells{1,contador}={jaccardAverageValue,directorioGeneracion(indPob).name};
         contador=contador+1;
         
     end
    
end


automaticSegmentationDirectory="E:\TFM\Experimentación\03.08.2020\Glándula,50 gen, volume+percentil 90 std vertex\resultado generacion50\mejor individuo gen49";
%jaccardValueMejorIndividuo=limeSeg_validation(automaticSegmentationDirectory,resizeImg,imgSize,zScale,tipValue,realLogicalImage);

dirMejorSolucion=dir(automaticSegmentationDirectory);
nombresDirectoriosSolucion={dirMejorSolucion.name};
indiceXML = contains(nombresDirectoriosSolucion,'.xml'); %indices de archivos XML
dirMejorSolucion(indiceXML)=[]; %los archivos CSV son eliminados del método
dirMejorSolucion(([1,2]))=[];
tamCells=size(dirMejorSolucion);
jaccardValues=[];
        
[~, reindex] = sort( str2double( regexp( {dirMejorSolucion.name}, '\d+', 'match', 'once' )));
dirMejorSolucion=dirMejorSolucion(reindex);

parfor (indSol=1:tamCells(1,1),10)

     directorioCell=strcat(strcat(dirMejorSolucion(indSol).folder,"\"),dirMejorSolucion(indSol).name);
     %originaLabelledImageCell = edited_processCells(directorioCell, resizeImg, imgSize, zScale, tipValue);
     realLogicalImage=originicalCellMatrices{indSol,1};
     jaccardValue=limeSeg_validation(directorioCell,resizeImg,imgSize,zScale,tipValue,realLogicalImage);
     jaccardValues(indSol)=jaccardValue;
end

jaccardValueMejorIndividuo=mean(jaccardValues);


automaticSegmentationDirectory2="E:\TFM\Experimentación\03.08.2020\Glándula,50 gen, volume+percentil 90 std vertex\resultado generacion50\segundo mejor individuo gen49";

dirSegundaMejorSolucion=dir(automaticSegmentationDirectory2);
nombresDirectoriosSolucion={dirSegundaMejorSolucion.name};
indiceXML = contains(nombresDirectoriosSolucion,'.xml'); %indices de archivos CSV
dirSegundaMejorSolucion(indiceXML)=[]; %los archivos CSV son eliminados del método
dirSegundaMejorSolucion(([1,2]))=[];
tamCells=size(dirSegundaMejorSolucion);
jaccardValues=[];
         
[~, reindex] = sort( str2double( regexp( {dirSegundaMejorSolucion.name}, '\d+', 'match', 'once' )));
dirSegundaMejorSolucion=dirSegundaMejorSolucion(reindex);

parfor (indSol=1:tamCells(1,1),10)

     directorioCell=strcat(strcat(dirSegundaMejorSolucion(indSol).folder,"\"),dirSegundaMejorSolucion(indSol).name);
     realLogicalImage=originicalCellMatrices{indSol,1};
     jaccardValue=limeSeg_validation(directorioCell,resizeImg,imgSize,zScale,tipValue,realLogicalImage);
     jaccardValues(indSol)=jaccardValue;
     
end

jaccardValueSegundoMejorIndividuo=mean(jaccardValues);

numericArray=[];
diceArray=[];

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
writetable(T3,'allResultsValidation2.txt','Delimiter',',')


pos=find(numericArray>jaccardValueMejorIndividuo);

bestResults=numericArray(pos);
bestStrings=stringArray(pos);

bestStrings(size(bestStrings)+1)="Mejor individuo 50 iter";
bestResults(size(bestResults)+1)=jaccardValueMejorIndividuo;


%%%
T = table(bestStrings,bestResults);

writetable(T,'ValidationBestSolution2.txt','Delimiter',',')




pos2=find(jaccardValueSegundoMejorIndividuo<numericArray);


bestResults=numericArray(pos2);

bestStrings=stringArray(pos2);

bestStrings(size(bestStrings)+1)="Segundo mejor individuo 50 iter";
bestResults(size(bestResults)+1)=jaccardValueSegundoMejorIndividuo;


T2 = table(bestStrings,bestResults);

writetable(T2,'ValidationSecondBestSolution2.txt','Delimiter',',')



%score, jaccard score, F1 score and accuracy (precision) and recall. All values can be handled by matlab with function dice, jaccard, bfscore.
