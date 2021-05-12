nombreEscritorio="C:\Users\Carlo\Documents\Artículo\datos\Datos gráficas mejores individuos"
directorioDatos=dir(nombreEscritorio);
nombresFicheros={directorioDatos.name};
indicesSoloFicherosDatos=contains(nombresFicheros,'gen');
soloFicherosDeDatos=nombresFicheros(indicesSoloFicherosDatos);

hold on
for k=1:length(soloFicherosDeDatos)
filename=soloFicherosDeDatos{k};
tissueName=strsplit(filename,'_');
route= strcat(strcat(nombreEscritorio,"\"),filename);
%columna 1: fila
%columna 2: gen 
%columna 3: índice de Jaccard de los verdaderos mejores individuos
%columna 4: Score verdaderos mejores individuos
%columna 5: índice de Jaccard  de los supuestos mejores individuos
%columna 6: score supuestos mejores individuos
hold on
num = xlsread(route);

gen = num(:,1);
jaccardIndexRealBestIndividual=num(:,3);
jaccardIndexSelectedAsBestIndividual=num(:,5);

%plot(gen,jaccardIndexRealBestIndividual,gen,jaccardIndexSelectedAsBestIndividual)
%plot(gen,jaccardIndexRealBestIndividual,colorsRealBestIndividuals(k));
%plot(gen,jaccardIndexSelectedAsBestIndividual,'DisplayName',tissueName{2})
plot(gen,jaccardIndexSelectedAsBestIndividual,'DisplayName',tissueName{2},'LineWidth',2,'Color','b')


xlabel('Generation number','fontweight','bold','fontsize',16) 
ylabel('Jaccard index','fontweight','bold','fontsize',16)
yticks(0.00:0.05:2.10)
xticks(0:10:100)
ylim([0.00 1.0])
xlim([0,100])
    if tissueName{2}=="salivary"
        tissueName{2}="salivary gland";
    end
lgd=legend(append('Evolution of Jaccard index of the best individuals in ',tissueName{2}));
lgd.TextColor = 'black';
lgd.Location='southeast';

savefig(append(append("BestIndividuals",tissueName{2}),'.fig'));
saveas(gcf,append(append("BestIndividuals",tissueName{2}),'.jpg'));
close(gcf);

end
%hold off



nombreEscritorio="C:\Users\Carlo\Documents\Artículo\datos\Datos gráficas evolución general"
directorioDatos=dir(nombreEscritorio);
nombresFicheros={directorioDatos.name};
indicesSoloFicherosDatos=contains(nombresFicheros,'gen');
soloFicherosDeDatos2=nombresFicheros(indicesSoloFicherosDatos);
close all

hold on
for k=1:length(soloFicherosDeDatos2)%lo mismo pero para la evolución general
filename=soloFicherosDeDatos2{k};
tissueName=strsplit(filename,'_');
route= strcat(strcat(nombreEscritorio,"\"),filename);
%columna 1: fila
%columna 2: gen 
%columna 3: índice de Jaccard promedio
%columna 4: Score verdaderos mejores individuos

hold on
num = xlsread(route);

gen = num(:,1);
averageJaccardIndex=num(:,3);

%plot(gen,jaccardIndexRealBestIndividual,gen,jaccardIndexSelectedAsBestIndividual)
%plot(gen,jaccardIndexRealBestIndividual,colorsRealBestIndividuals(k));
plot(gen,averageJaccardIndex,'LineWidth',2,'Color','b')


xlabel('Generation number','fontweight','bold','fontsize',16) 
ylabel('Average Jaccard index','fontweight','bold','fontsize',16)
yticks(0.00:0.05:2.05)
xticks(0:10:100)
ylim([0.00 1.0])
xlim([0,100])




    if k==1
        text="eggchamber";
    elseif k==2
        text="embryo";
    elseif k==3
        text="salivary gland";
    end
    
lgd=legend(append('Evolution of average Jaccard index in ',text));
lgd.Location='southeast';


savefig(append(append("Evolution of average Jaccard index in ",text),'.fig'));
saveas(gcf,append(append("Evolution of average Jaccard index in ",text),'.jpg'));
close(gcf);

end



%title('Combined')

    

% filename="C:\Users\Carlo\Documents\Máster ISCDG\TFM\TFM - Carlos Capitán Agudo\Datos\Glándula, 100 generaciones, 50 Individuos\comparativaMejoresIndividuos_glandula_100gen50ind.xlsx";
% columna 1: fila
% columna 2: gen 
% columna 3: índice de Jaccard de los verdaderos mejores individuos
% columna 4: Score verdaderos mejores individuos
% columna 5: índice de Jaccard  de los supuestos mejores individuos
% columna 6: score supuestos mejores individuos
% hold on
% num = xlsread(filename);
% 
% gen = num(:,1);
% jaccardIndexRealBestIndividual=num(:,3);
% jaccardIndexSelectedAsBestIndividual=num(:,5);
% 
% plot(gen,jaccardIndexRealBestIndividual,gen,jaccardIndexSelectedAsBestIndividual)
% plot(gen,jaccardIndexSelectedAsBestIndividual,'-o')
% 
% 
% hold off
% xlabel('Generation number') 
% ylabel('Jaccard index')
% yticks(0.25:0.05:2.05)
% xticks(0:10:100)
% ylim([0.25 1.0])