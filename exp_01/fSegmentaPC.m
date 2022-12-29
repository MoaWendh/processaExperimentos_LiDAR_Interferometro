
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fSegmentaPC(handles)
clc;

infoFolder= dir(fullfile(handles.pathReadPC, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

pc= pcread(handles.PcToRead);
% Filtra o ru�do da nuvem de pontos de refer�ncia.
pcDenoised= pcdenoise(pc);

pcThresholded= pcFiltraDistancia(pcDenoised, handles);

% Segmenta a nuvem de pontos em clusters com a fun��o pcsegdist(): 
if (handles.habFunction_SegmentaLidarData)
    [labels, numClusters] = segmentLidarData(pc, handles.valMinDistance, [handles.valMimPoints handles.valMaxPoints]);
    % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
    idxValidPoints = find(labels);

    % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
    % os endere�os com os pontos v�lidos:
    labelColorIndex = labels(idxValidPoints);

    % Gera um nuvem de pontos com os valores segmentados:
    pcSegmented = select(pc,idxValidPoints);
else
    [labels, numClusters] = pcsegdist(pcDenoised, handles.valMinDistance, 'NumClusterPoints', [handles.valMinPoints handles.valMaxPoints]);
    
    % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
    idxValidPoints = find(labels);

    % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
    % os endere�os com os pontos v�lidos:
    labelColorIndex = labels(idxValidPoints);

    % Gera um nuvem de pontos com os valores segmentados:
    pcSegmented = select(pcDenoised, idxValidPoints);
end    


% Gera uma nuvem de pontos para cada cluster:
for (ctCluster=1:numClusters)
    pcCluster{ctCluster}= select(pcDenoised, labels==ctCluster);
end
fprintf(' PC lida cont�m -> %d clusters.\n', numClusters); 

% Se estiver habilitado chama fun��o para exibir os resultados da segmenta��o:
if (handles.showPcSegmentada && (numClusters>0)) 
    fShowPcSegmentada(pcCluster, pcSegmented, numClusters, labelColorIndex);
end

% Se estiver habilitado salva a PC segmentada:
if (handles.habSavePcSeg) 
    if (numClusters>0) 
        fullPath= fullfile(pathToSave, nameFile);
        pcwrite(pcCluster{pcNum},fullPath); 
    else
        fprintf(' Aten��o!!! N�o foram detectados clusters em: "%s"\n', handles.PcToRead);
        msg=' Digite qualquer tecla para continuar:';
        key= input(msg, 's');
    end
end    
end
