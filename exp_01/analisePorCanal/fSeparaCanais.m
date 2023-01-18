function handles= fSeparaCanais(handles)
close all;

% Para evitar erro, se for escolhida apenas um arquivo, nuvem de pontos,
% a variável "handles.fileSeparar" não será cell e a função length() irá determinar o
% número de caracteres contido na variável "handles.fileSeparar", isto não é
% desejável. Por isso é feito o teste abaixo:
if iscell(handles.fileSeparar)
    handles.numPCs= length(handles.fileSeparar);
else
    handles.numPCs= 1;
end

% Define uma mensagem a ser exibida:
msg= sprintf(' -Total de nuvens de pontos: %d \n -Serão separados os canais:\n [ %s ]', handles.numPCs, num2str(handles.cnSepara)) ;
% Exibe uma menagem solicitando confirmação de execução:
answer = questdlg(msg, 'Ok para continuar', 'Ok', 'Sair', 'Ok');
% Handle response
switch answer
    case 'Ok'
        habSeparaCanais= 1;
    case 'Sair'
        habSeparaCanais= 0;
end

% Faz a varredura nas "handles.numPCs" nuvens de pontos:

if (habSeparaCanais)
    for (ctPC=1:handles.numPCs)
        % Faz leitura da nuvem de pontos:
        if (handles.numPCs==1)
            handles.PcToRead= fullfile(handles.path, handles.fileSeparar);
            % Gera o nome do folder onde será salva a PC com canais
            % separados em função do nome da numvem de pontos:
            nameFolderToSave=strsplit(handles.fileSeparar,'.');
        else
            handles.PcToRead= fullfile(handles.path, handles.fileSeparar{ctPC});
            nameFolderToSave=strsplit(handles.fileSeparar{ctPC},'.');
        end
               
        % Le a respectiva nuvem de pontos:
        pc= pcread(handles.PcToRead);
        
        % Gera folder onde a PC com os canais separados serão salvos 
        fullPathToSave= sprintf('%s%s\\pc%s', handles.path, handles.folderToSaveSep, nameFolderToSave{1});
        
        % Verifica se o folder existe, se não existir eles serão criados:                     
        if ~isfolder(fullPathToSave)
            mkdir(fullPathToSave);
        end
        
        % Separa os canais para cada nuvem de pontos:        
        for (ctCn=1:length(handles.cnSepara))
            canal= handles.cnSepara(ctCn);

            % Gera a PC por canal:
            pcAux= pointCloud(pc.Location(canal,:,:), 'Intensity',pc.Intensity(canal,:));

            % Salva a PC do canal no respectivo folder:
            pathToSave= sprintf('%s\\cn%0.2d.%s', fullPathToSave, ctCn, handles.extPC);
            pcwrite(pcAux, pathToSave);
            if (ctCn==length(handles.cnSepara))
                fprintf(' Canal: %0.2d \n', canal);
            else
                if (ctCn==1)
                    fprintf(' PC nº-> %d\n', ctPC);
                    fprintf(' Canal: %0.2d', canal);
                else
                    fprintf(' Canal: %0.2d', canal);                        
                end
            end
        end
    end
end

% Define uma mensagem a ser exibida:
pathAux= sprintf('%s%s', handles.path, handles.folderToSaveSep);
msg= sprintf(' As PCs com os canais separados foram salvas em: \n " %s\\pcxxxx "', pathAux);
% Exibe uma menagem informando onde forma salvas as PCs com canis separados:
answer = msgbox(msg, 'Ok', 'Success');
msg= sprintf('Separação de canais concluída! Foram separadas os canais de %d PCs.', handles.numPCs);
handles.statusProgram= msg;
end
