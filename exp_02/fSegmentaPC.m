
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utilização da função "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fSegmentaPC(param)
clc;
close all;

pathBase= param.path.Base;
pathToRead= param.path.PCRotacionada; 
pathToSave= param.path.PCSegmentada;

for (i=param.startPC:param.stopPC)
    close all;
    % Especifica a nuvem de pontos de referênica a ser lida. Path completo.  
    nameFile= sprintf('%0.4d.%s',i,param.ext.PC);
    fullPath= fullfile(pathBase,pathToRead,nameFile);
    % Efetua a leitura da nuvem depontos de referência. 
    pc= pcread(fullPath);
    % Filtra o ruído da nuvem de pontos de referência.
    pcDenoised = pcdenoise(pc);
    
    % Segmenta a nuvem de pontos em clusters com a função pcsegdist(): 
    [labels, numClusters] = pcsegdist(pcDenoised, param.minDistance,'NumClusterPoints',param.minPoints);
    % Remove os pontos que não tem valor de label válido, ou seja =0.
    idxValidPoints = find(labels);
    % Guarda o cluster definidos na variável "idxValidPoints" quem contém 
    % os endereços com os pontos válidos:
    labelColorIndex = labels(idxValidPoints);
    % Gera um nuvem de pontos com os valores segmentados:
    pcSegmented = select(pcDenoised,idxValidPoints);
    for (ctCluster=1:numClusters)
        %Gera uma nuvem de pontos para cada cluster:
        pcCluster{ctCluster}= select(pcDenoised,labels==ctCluster);
    end    
    all =1; 
    if (param.show.ResultSegmented) 
        % Cria um novo mapa de cores para os clusters
        if (all==1 || i==5 || i==14)
            colormap(hsv(numClusters));
            % Exibe a nuvem de pontos segmentada inteira:
            pcshow(pcSegmented.Location,labelColorIndex);
            title('Full Segmented Point Cloud Clusters ');
            xlabel('X (m)');
            ylabel('Y (m)');
            zlabel('Z (m)');
            for (ctCluster=1:numClusters)
                figure;
                % Exibe o cluster da nuvem de pontos segemntada:
                pcshow(pcCluster{ctCluster}.Location);
                titulo= sprintf('Segmented Point Cloud Clusters= %d ',ctCluster);
                title(titulo);
                xlabel('X (m)');
                ylabel('Y (m)');
                zlabel('Z (m)');
            end
            a=0;    
        end
    end  
    
    % Seleciona nuvem de pontos de interesse para salvar
    if (i==2)
        pcNum= 2;        
    else
        pcNum= 2;
    end

    if (pcNum<=numClusters)
        fullPath= fullfile(pathBase, pathToSave, nameFile);
        pcwrite(pcCluster{pcNum},fullPath); 
    else
        fprintf('Erro!!! Pooint cloud nº: %d contém: %d clusters, não existe o cluster nº: %d. \n', i, numClusters, pcNum);
        msg='Digite qualquer tecla para continuar:';
        key= input(msg, 's');
    end    
end
end
