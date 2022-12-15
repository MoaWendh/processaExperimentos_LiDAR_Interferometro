%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para concatenar as PCs dos 16 canais separadamente.
% O LiDAR Puck Lite tem 16 canais.
% A partir das PCs geradas no experimento com o laser interferométrico, as
% PCS de cada canal do LiDAR forma separadas e salvos em 16 pastas distintas.
% Isto facilita a análise estatistica das medições do LiDAR por canal, ou seja,
% cada canal pode ser avaliado separadamente.
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fMergePcPorCanal()
clear;
clc;
close all;

pathBase= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01\Reg\';

mergeSize= 0.001;
showPC= 0;
showPCFull= 1;
numCanais= 16;

% Varre os folders para pegar as PCS por canal.
for (ctCanal=1:numCanais)
    close all;
    % Define o path e o nome do folder de onde as PCs serão lidas para cada
    % canal:
    nameFolder= sprintf('cn%0.2d%s',ctCanal);
    pathToRead= fullfile(pathBase, nameFolder);
    
    % Cria o path para salvar as PCs caso ainda não existam:
    namefolderSave= sprintf('full');
    pathToSave= sprintf('%s\\%s',pathToRead, namefolderSave);
    if ~isfolder(pathToSave)
        mkdir(pathToSave);
    end
    
    % Verifica quantas PCS tem no folder do canal:
    infoFolder= dir(fullfile(pathToRead, '*.pcd'));
    numPCs= length(infoFolder(not([infoFolder.isdir])));
    
    % Varre o folder do canal para concatenar as N PCs:
    for (ctPC=1:numPCs)
        nameFile= sprintf('%0.4d%s',ctPC, '.pcd');
        fullPath= fullfile(pathToRead, nameFile);
        if (ctPC==1)
            pcFull= pcread(fullPath);
        else
            pcAux= pcread(fullPath);
            pcFull= pcmerge(pcFull, pcAux, mergeSize);
        end    

       % Exibe o resultado do registro das PCs a cada iteração
       if (showPC)
           if (ctPC==1)
               handle= figure;
           end
           pcshow(pcFull);
           title('PCs concatenadas por canal');
           xlabel('X (m)');
           ylabel('Y (m)');
           zlabel('Z (m)');
           handle.WindowState='maximized';
       end 
    end

    % Salva todas as PCs concatenadas num único arquivoa:
    nameFile= sprintf('pcFull.pcd');
    fullPath= fullfile(pathToSave, nameFile);
    pcwrite(pcFull, fullPath);
    
   % Exibe as PCs dos canais concatenada:
   if (showPCFull)
       handle= figure;
       pcshow(pcFull);
       msg= sprintf('Canal %d do LiDAR com %d PCs concatenadas.', ctCanal, ctPC);
       title(msg);
       xlabel('X (m)');
       ylabel('Y (m)');
       zlabel('Z (m)');
       handle.WindowState='maximized';
   end 
end
    
end

