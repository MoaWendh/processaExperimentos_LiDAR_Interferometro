
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAjustaPlanoPC()
clc;
close all;
clear;

param.val.maxDistance= 0.001;
pathToRead='D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01\Pln\0001.pcd';

pc= pcread(pathToRead);
% Filtra o ru�do da nuvem de pontos de refer�ncia.
pcDenoised = pcdenoise(pc);   

[model, inlierIndices, outlierIndices, error]= pcfitplane(pc, param.val.maxDistance);
pcPlane= select(pc, inlierIndices);
remainPtCloud= select(pc,outlierIndices);

 figure;
 subplot(2,2,1);
 pcshow(pc);
 subplot(2,2,2);
 pcshow(remainPtCloud);
 subplot(2,2,[3 4]);
 pcshow(pc);
 hold on;
 plot(model,'Color',[0 1 0]);

end
