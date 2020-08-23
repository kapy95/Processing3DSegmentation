function jaccardValue=limeSeg_validation(outputDir,resizeImg,imgSize,zScale,tipValue,realLogicalImage)

jaccardValue=0;

labelledImage = processCells(outputDir, resizeImg, imgSize,zScale,tipValue);%-> anterior funcion para el procesamiento
%labelledImage = edited_processCells(outputDir, resizeImg, imgSize, zScale, tipValue);
%paint3D(labelledImage)
L=logical(labelledImage);
jaccardValue= jaccard(L,realLogicalImage);


end