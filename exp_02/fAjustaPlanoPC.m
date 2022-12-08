
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAjustaPlanoPC(param)
clc;
close all;

pathBase= param.path.Base;
pathToRead= param.path.PCSegmentada;
pathToSave= param.path.PCPlaneAdjusted;

for (i=param.startPC:param.stopPC)
    close all;
    % Especifica a nuvem de pontos de referênica a ser lida. Path completo.  
    nameFile= sprintf('%0.4d.%s',i,param.ext.PC);
    fullPath= fullfile(pathBase,pathToRead,nameFile);
    % Efetua a leitura da nuvem depontos de referência. 
    pc= pcread(fullPath);
    % Filtra o ruído da nuvem de pontos de referência.
    pcDenoised = pcdenoise(pc);   

    [model1,inlierIndices,outlierIndices]= pcfitplane(pc, param.maxDistance);
    pcPlane= select(pc,inlierIndices);
    remainPtCloud= select(pc,outlierIndices);
    
    fullPath= fullfile(pathBase,pathToSave, nameFile);
    pcwrite(pcPlane,fullPath);
end
end
