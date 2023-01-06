%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Função que carrega as nuvens de pontos que foram convertidas a partir dos 
% arquivos "xls" gerados no experiento com o laser interferométrico
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pc pcDenoised]= fCarregaPCs(handles)

fprintf(' Carregando PCs ');
% Faz a leitura de todas as nuvens de pontos no formato '.pcd'.
% "O handle.val.numFolders" identifica quantos distâncias serão testadas. 
for (ctFolder=1:handles.val.numFolders) 
    path= sprintf('%s%s%0.4d\\', handles.path.BaseRead, handles.name.FolderBase, ctFolder*200);
    % Verifica os folders
    infoFolder= dir(fullfile(path, '*.pcd'));
    %¨numFiles= length(infoFolder(not([infoFolder.isdir])));
    ctPos= 0;
    for (ctFile= handles.val.PcIni:handles.val.PcFim)
        ctPos= ctPos + 1;
        % Define o path para leitura da nuvem de pontos
        nameFile= sprintf('%0.4d.%s', ctFile, handles.name.extPC);
        fullPath = fullfile(path, nameFile);
        % Carrega a nuvem de pontos a ser registrada: 
        pc{ctFolder,ctPos}= pcread(fullPath);  
        % Filtra o ruído da nuvem de pontos a ser registrada.
        pcDenoised{ctFolder,ctPos} = pcdenoise(pc{ctFolder,ctPos});
        fprintf('.');
    end
end
fprintf('\n');
fprintf(' Num PCs carregadas= %d \n', ctFolder*ctPos);
