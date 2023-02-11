
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fSegmentaPC(handles)
clc;

% Para usar o close all é necessário mudar o HandleVisibility do
% painelprincial para "off". Assim, quando for finalizado, antes será necessário
% tornar este parametro novamente para "on" e depois executar close all.
close all;

infoFolder= dir(fullfile(handles.pathReadPC, '*.pcd'));
numPCs= length(infoFolder(not([infoFolder.isdir])));

pc= pcread(handles.PcToRead);
% Filtra o ruído da nuvem de pontos de referência.
pcDenoised= pcdenoise(pc);

if (handles.habSegmentaPorThreshold)
    % Efetua um procedimento de filtragem utilizando a distância ecuclidiana
    % entre o ponto XYZ e a origem do LiDAR, usa threshold de distânica mínima
    % e máxima definidas nas viariáveis:
    % - handles.valThresholdMinDistance
    % - handles.valThresholdMaxDistance.
    pcThresholded= fPcFiltraDistancia(pcDenoised, handles);
    
    % Se estiver habilitado salva a PC segmentada:
    if (handles.HabSalvarPcSeg && pcThresholded.Count)
        answer = questdlg('Salvar a PC segmentada?', '', 'Sim', 'Não', 'Redefinir folder para salvar', 'Sim');
        switch answer
            case 'Sim'
                    % Se o path para salvar ainda não foi definido será aberta
                    % uma tela para escolher o folder:
                    if strcmp(handles.pathSavePC, "")
                        handles.pathSavePC= uigetdir(handles.pathSavePC);
                        if ~(handles.pathSavePC)
                            msg= sprintf(' Operação de salvar a PC Segmentada foi cancelada.');
                            figMsg= msgbox(msg);
                            uiwait(figMsg);
                            return; % Sai da função!
                        end;
                    end

                    pathSavePC= fullfile(handles.pathSavePC, handles.nameFolderSavePcSeg);
                    if (isdir(pathSavePC))
                        % Verifica se já tem arquivos .pcds salvos, se sim será
                        % dada continuidade a numeração:
                        fullPath= fullfile(pathSavePC, '*.pcd');
                        result= dir(fullPath);
                        numFilesPCD= length(result);
                        numFile= numFilesPCD + 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    else
                        mkdir(pathSavePC)
                        numFile= 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    end

            case 'Redefinir folder para salvar'   
                    handles.pathSavePC= uigetdir(handles.pathSavePC);
                    if ~(handles.pathSavePC)
                        msg= sprintf(' Operação de redefinição do folder foi cancelada.');
                        figMsg= msgbox(msg);
                        uiwait(figMsg);
                        return; % Sai da função!
                    end
                    
                    pathSavePC= fullfile(handles.pathSavePC, handles.nameFolderSavePcSeg);
                    if (isdir(pathSavePC))
                        % Verifica se já tem arquivos .pcds salvos, se sim será
                        % dada continuidade a numeração:
                        fullPath= fullfile(pathSavePC, '*.pcd');
                        result= dir(fullPath);
                        numFilesPCD= length(result);
                        numFile= numFilesPCD + 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    else
                        mkdir(pathSavePC)
                        numFile= 1;
                        nameFile= sprintf('%0.4d.pcd',numFile);
                        fullPath= fullfile(pathSavePC, nameFile);
                        pcwrite(pcThresholded, fullPath); 
                    end
              
            case 'Não'
                    return;
        end
    end 
else
    % Segmenta a nuvem de pontos em clusters com a função pcsegdist(): 
    [labels, numClusters] = pcsegdist(pcDenoised, handles.valMinDistance, 'NumClusterPoints', [handles.valMinPoints handles.valMaxPoints]);

    % Remove os pontos que não tem valor de label válido, ou seja =0.
    idxValidPoints = find(labels);

    % Guarda o cluster definidos na variável "idxValidPoints" quem contém 
    % os endereços com os pontos válidos:
    labelColorIndex = labels(idxValidPoints);

    % Gera um nuvem de pontos com os valores segmentados:
    pcSegmented = select(pcDenoised, idxValidPoints);
    
    % Gera uma nuvem de pontos para cada cluster:
    for (ctCluster=1:numClusters)
        pcCluster{ctCluster}= select(pcDenoised, labels==ctCluster);
    end
    fprintf(' PC lida contém -> %d clusters.\n', numClusters); 

    % Se estiver habilitado chama função para exibir os resultados da segmentação:
    if (handles.showPcSegmentada && (numClusters>0)) 
        fShowPcSegmentada(pcCluster, pcSegmented, numClusters, labelColorIndex);
    end
end  
end
