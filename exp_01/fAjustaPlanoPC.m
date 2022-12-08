
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAjustaPlanoPC(param)
clc;
close all;

pathToRead= sprintf('%s%s',param.path.Base, param.path.PCSeg); 
pathToSave= sprintf('%s%s',param.path.Base, param.path.PCPlaneAdjuste);

% Se a pasta onde ser�o salvas as PCs segmentadas n�o existir ela ser� criada:
if ~isfolder(pathToSave)
    mkdir(pathToSave);
end

infoFolder= dir(fullfile(pathToRead, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

for (i=1:numPCs)
    close all;
    % Especifica a nuvem de pontos de refer�nica a ser lida. Path completo.  
    nameFile= sprintf('%0.4d.%s', i, param.name.extPC);
    fullPath= fullfile(pathToRead, nameFile);
    % Efetua a leitura da nuvem depontos de refer�ncia. 
    pc= pcread(fullPath);
    % Filtra o ru�do da nuvem de pontos de refer�ncia.
    pcDenoised = pcdenoise(pc);   

    [model1,inlierIndices,outlierIndices]= pcfitplane(pc, param.val.maxDistance);
    pcPlane= select(pc,inlierIndices);
    remainPtCloud= select(pc,outlierIndices);
    
    fullPath= fullfile(pathToSave, nameFile);
    pcwrite(pcPlane,fullPath);
end
end
