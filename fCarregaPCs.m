%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Função que carrega as nuvens de pontos que foram convertidas a partir dos 
% arquivos "xls" gerados no experiento com o laser interferométrico
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pc pcDenoised]= fCarregaPCs(path, name, param)
clc;
close all

% Faz a leitura de todas as nuvens de pontos no formato '.pcd'.
ctPos= 0;
for (ctFolder=1:param.numFolders) 
    pathFolder= sprintf('%s%s%0.4d\\', path.Base, name.FolderBase, ctFolder*200);
    % Verifica os folders
    infoFolder= dir(fullfile(pathFolder, '*.pcd'));
    %¨numFiles= length(infoFolder(not([infoFolder.isdir])));
    for (ctFile= param.fileIni:param.fileEnd)
        ctPos= ctPos+1;
        nameFile= sprintf('%s%d_%0.4d.%s', name.FileBase, ctFolder*200, ctFile, name.extPC);
        fullPathFile = fullfile(pathFolder, nameFile);
        pc{ctFolder,ctFile - param.fileIni+1}= pcread(fullPathFile);  
        % Filtra o ruído da nuvem de pontos a ser registrada.
        pcDenoised{ctFolder,ctFile - param.fileIni+1} = pcdenoise(pc{ctFolder,ctFile - param.fileIni+1});
    end
    if (param.showPC)
        close all;
        handle= figure;
        subplot(1,2,1);
        pcshow(pc{ctFolder,ctFile});
        subplot(1,2,2);
        pcshow(pcDenoised{ctFolder,ctFile});
        handle.WindowState='maximized';
    end
end

