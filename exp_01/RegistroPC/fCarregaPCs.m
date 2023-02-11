%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Função que carrega as nuvens de pontos que foram convertidas a partir dos 
% arquivos "xls" gerados no experiento com o laser interferométrico
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles= fCarregaPCs(handles)
close all;

msg= sprintf('Carregando PCs no buffer.');
handles.editMsgs.String= msg; 

% Se "handles.multiplosFolders" estiver habilitado serão carregadas as PCs 
% contidas nos múltiplos folders. Se não serão carregadas as PCs
% selecionadas manualmente
handles.numPCsValidas= 0;

if (handles.multiplosFolders)     
    % Detecta o nome dos folders dentro do path selecionado:
    infoPath= dir(handles.path.BaseRead);
    handles.numFolders= length(infoPath);

    % Inicializa os contadores:  
    ctFolderValido= 0;
    ctPC= 0;
    
    % Verifica multiplos folders. Só entra quando o folder tyiver um nome
    % válido, quando detecta "." e ".." ele pula a contagem do folder
    % válido. Parâmetro "handles.numFolders" contém o nº de folders dentro do path 
    % selecionado, nem todos tem arquivos de PCs.
    for (ctFolder=1:handles.numFolders)
        if (infoPath(ctFolder).name~= ".") && (infoPath(ctFolder).name~= "..")
            ctFolderValido= ctFolderValido + 1; 
            % Define o path para letura da PC:
            path= sprintf('%s\\%s\\', handles.path.BaseRead, infoPath(ctFolder).name);

            % Varre o folder procurando as PCs para serem caregadas no buffer:
            % Primeiro verifica se existem arquivos no formato .pcd no path atual:
            pcdPath= fullfile(path,'*.pcd');
            infoFiles= dir(pcdPath);
            if (length(infoFiles))
                ctPC= 0;
                for (ctFile= handles.val.PcIni:handles.val.PcFim)
                    ctPC= ctPC + 1;
                    
                    % Define o path para leitura da nuvem de pontos
                    nameFile= sprintf('%0.4d.%s', ctFile, handles.name.extPC);
                    fullPath = fullfile(path, nameFile);

                    % Carrega a nuvem de pontos a ser registrada: 
                    handles.pc{ctFolderValido, ctPC}= pcread(fullPath);  

                    % Filtra o ruído da nuvem de pontos a ser registrada.
                    handles.pcDenoised{ctFolderValido, ctPC} = pcdenoise(handles.pc{ctFolderValido, ctPC}); 
                end
            end
        end
        % "handles.numPCsValidas" acumula a contagem das PCs carregadas:
        handles.numPCsValidas= handles.numPCsValidas + ctPC;
    end
    % Conta o número de folders que contém arquivos .pcd:
    handles.numFoldersValidos= ctFolderValido;
       
    % Verifica se não achou nenhum arquivo tipo .pcd:
    if (ctPC<1)
        msg= sprintf(' Não foram detectados arquivos no formato .pcd\n. Verifique o path indicado.');
        handles.editMsgs.String= msg;    
    end
else
    % Carrega as PCs selecionadas manualmente:
    numPCs= length(handles.name.PCsFiles);
    for (ctPC= 1:numPCs)
        % Busca o arquivo .pcd no folder atual:

        % Define o path para leitura da nuvem de pontos
        fullPath = fullfile(handles.path.BaseRead, handles.name.PCsFiles{ctPC});

        % Carrega a nuvem de pontos a ser registrada: 
        handles.pc{1, ctPC}= pcread(fullPath);  

        % Filtra o ruído da nuvem de pontos a ser registrada.
        handles.pcDenoised{1, ctPC} = pcdenoise(handles.pc{1, ctPC});
    end
    handles.numPCsValidas= handles.numPCsValidas + ctPC;
    handles.numFoldersValidos= 1;
end
end
