
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Utiliza��o da fun��o "pcsegdist()" para segmentar uma nuvem de pontos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fSegmentaPC(param)
close all;

pathToRead= sprintf('%s%s',param.path.Base, param.path.PCReg); 
pathToSave= sprintf('%s%s',param.path.Base, param.path.PCSeg);

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
    
    % Segmenta a nuvem de pontos em clusters com a fun��o pcsegdist(): 
    [labels, numClusters] = pcsegdist(pcDenoised, param.val.minDistance,'NumClusterPoints',param.val.minPoints);
    
    % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
    idxValidPoints = find(labels);
    % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
    % os endere�os com os pontos v�lidos:
    labelColorIndex = labels(idxValidPoints);
    % Gera um nuvem de pontos com os valores segmentados:
    pcSegmented = select(pcDenoised,idxValidPoints);
    for (ctCluster=1:numClusters)
        %Gera uma nuvem de pontos para cada cluster:
        pcCluster{ctCluster}= select(pcDenoised,labels==ctCluster);
    end    
    all =1; 
    if (param.show.PCSegmented) 
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
        pcNum= 4;        
    else
        pcNum= 4;
    end

    if (pcNum<=numClusters)
        fullPath= fullfile(pathToSave, nameFile);
        pcwrite(pcCluster{pcNum},fullPath); 
    else
        fprintf('Erro!!! Pooint cloud n�: %d cont�m: %d clusters, n�o existe o cluster n�: %d. \n', i, numClusters, pcNum);
        msg='Digite qualquer tecla para continuar:';
        key= input(msg, 's');
    end    
end
end
