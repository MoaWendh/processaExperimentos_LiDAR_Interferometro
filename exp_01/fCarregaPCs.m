%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Função que carrega as nuvens de pontos que foram convertidas a partir dos 
% arquivos "xls" gerados no experiento com o laser interferométrico
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pc pcDenoised]= fCarregaPCs(handles)

fprintf(' Carregando PCs ');
% Faz a leitura de todas as nuvens de pontos no formato '.pcd'.
for (ctFolder=1:handles.val.numFolders) 
    path= sprintf('%s%s%0.4d\\', handles.path.BaseRead, handles.name.FolderBase, ctFolder*200);
    % Verifica os folders
    infoFolder= dir(fullfile(path, '*.pcd'));
    %¨numFiles= length(infoFolder(not([infoFolder.isdir])));
    ctPos= 0;
    for (ctFile= handles.val.fileIni:handles.val.fileEnd)
        ctPos= ctPos + 1;
        nameFile= sprintf('%0.4d.%s', ctFile, handles.name.extPC);
        fullPath = fullfile(path, nameFile);
        pc{ctFolder,ctPos}= pcread(fullPath);  
        % Filtra o ruído da nuvem de pontos a ser registrada.
        pcDenoised{ctFolder,ctPos} = pcdenoise(pc{ctFolder,ctPos});
    
        % Exiber nuvem de pontos de estiver habilitado:
        if (handles.show.PC)
            if (ctFolder==1) 
                handle= figure;
            end
            pcshow(pcDenoised{ctFolder,ctPos});
            handle.WindowState='maximized';
            hold on;
        end
        fprintf('.');
    end
end
fprintf('\n');
fprintf(' Num PCs carregadas= %d \n', ctFolder*ctPos);
