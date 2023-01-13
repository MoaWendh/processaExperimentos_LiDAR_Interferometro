function handles= fSeparaCanais(handles)
close all;

% Para evitar erro, se for escolhida apenas um arquivo, nuvem de pontos,
% a variável "handles.fileSeparar" não será cell e a função length() irá determinar o
% número de caracteres contido na variável "handles.fileSeparar", isto não é
% desejável. Por isso é feito o teste abaixo:
if iscell(handles.fileSeparar)
    numPCs= length(handles.fileSeparar);
else
    numPCs= 1;
end

% Define uma mensagem a ser exibida:
msg= sprintf(' -Total de nuvens de pontos: %d \n -Serão separados os canais:\n [ %s ]', numPCs, num2str(handles.cnSepara)) ;
% Exibe uma menagem solicitando confirmação de execução:
answer = questdlg(msg, 'Ok para continuar', 'Ok', 'Sair', 'Ok');
% Handle response
switch answer
    case 'Ok'
        habSeparaCanais= 1;
    case 'Sair'
        habSeparaCanais= 0;
end

% Faz a varredura nas "numPCs" nuvens de pontos:

if (habSeparaCanais)
    for (ctPC=1:numPCs)
        % Faz leitura da nuvem de pontos:
        if (numPCs==1)
            handles.PcToRead= fullfile(handles.path, handles.fileSeparar);
        else
            handles.PcToRead= fullfile(handles.path, handles.fileSeparar{ctPC});
        end
        pc= pcread(handles.PcToRead);

        % Separa os canais para cada nuvem de pontos:        
        for (ctCn=1:length(handles.cnSepara))
            canal= handles.cnSepara(ctCn);
            % Verifica se os folders onde serão salvas as PCs por canal existem,
            % se não existir eles serão gerados, conforme definido no param:                     
            pathToSave= sprintf('%s%s%0.2d', handles.path, handles.nameFolderToSaveCn, canal);
            if ~isfolder(pathToSave)
                mkdir(pathToSave);
            end

            % Monta o nome de arquivo a ser salvo:
            if (numPCs==1)
                fullPath= fullfile(pathToSave, handles.fileSeparar);
            else
                fullPath= fullfile(pathToSave, handles.fileSeparar{ctPC});
            end

            % Gera a PC por canal:
            pcAux= pointCloud(pc.Location(canal,:,:), 'Intensity',pc.Intensity(canal,:));

            % Salva a PC do canal no respectivo folder:
            pcwrite(pcAux, fullPath);
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
pathAux= sprintf('%s%s', handles.path, handles.nameFolderToSaveCn);
msg= sprintf(' As PCs com os canais separados foram salvas em: \n " %s(numcanal) "', pathAux);
% Exibe uma menagem informando os dorma salvas as PCs com canis separados:
answer = msgbox(msg, 'Ok', 'Success');
handles.statusProgram= 'Separação de canais concluída.';
end
