%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Função que carrega as nuvens de pontos que foram convertidas a partir dos 
% arquivos "xls" gerados no experiento com o laser interferométrico
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pc pcDenoised]= fCarregaPCs(path, name, param)
close all

% Faz a leitura de todas as nuvens de pontos no formato '.pcd'.
for (ctFolder=1:param.numFolders) 
    pathFolder= sprintf('%s%s%0.4d\\', path.Base, name.FolderBase, ctFolder*200);
    % Verifica os folders
    infoFolder= dir(fullfile(pathFolder, '*.pcd'));
    %¨numFiles= length(infoFolder(not([infoFolder.isdir])));
    for (ctFile= param.fileIni:param.fileEnd)
        ctPos= (ctFile - param.fileIni+1);
        nameFile= sprintf('%0.4d.%s', ctFile, name.extPC);
        fullPathFile = fullfile(pathFolder, nameFile);
        pc{ctFolder,ctPos}= pcread(fullPathFile);  
        % Filtra o ruído da nuvem de pontos a ser registrada.
        pcDenoised{ctFolder,ctPos} = pcdenoise(pc{ctFolder,ctPos});
    
        % Exiber nuvem de pontos de estiver habilitado:
        if (param.showPC)
            if (ctFolder==1) 
                handle= figure;
            end
            pcshow(pcDenoised{ctFolder,ctPos});
            handle.WindowState='maximized';
            hold on;
        end
    end
end

