
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Esta função efetua a leitura da PC de apenas 1 canal e segmenta uma 
% determinada linha.
% Ela chama a função fSegmentaPC para segmantar a linha.
% ***Atenção*** 
% O LiDAR VLP-16 ou Puck LITE retorna os pacotes de dados dados a informação 
% dos 16 canais conforme a sequência que segue abaixo:
%  Posição    Canal    Ângulo(Elevação)
%    01        00          -15º
%    02        02          -13º
%    03        04          -11º
%    04        06          -9º
%    05        08          -7º
%    06        10          -5º
%    07        12          -3º
%    08        14          -1º
%    09        01           1º
%    10        03           3º
%    11        05           5º
%    12        07           7º
%    13        09           9º
%    14        11           11º
%    15        13           13º
%    16        15           15º
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fSegmentaPCPorCanal(handles)
close all;

if (~isdir(handles.pathRead))
    msg= sprintf('Folder não existe! Verifique se os canais forma separados.');
    msgbox(msg);
    habSegmentaCanais= 0;
else
    % Identifica os subfolders que contém as PCs com os canais separdos. 
    allSubFolders= genpath(handles.pathRead);
    % Separa os subfolders em uma variável tipo cell:
    handles.subFolders= regexp(allSubFolders, ';', 'split');
    
    % Define uma mensagem a ser exibida:
    msg= sprintf(' - Serão segmentados os canais:\n [ %s ]', num2str(handles.cnSegmenta)) ;
    % Exibe uma menagem solicitando confirmação de execução:
    answer = questdlg(msg, 'Ok para continuar', 'Ok', 'Sair', 'Ok');
    % Handle response
    switch answer
        case 'Ok'
            habSegmentaCanais= 1;
        case 'Sair'
            habSegmentaCanais= 0;
            msg= sprintf('Execução da segmentação foi abortada pelo usuário!!');
    end
    % Verifica se os valors dos parãmetros de threshold estão ok.
    if (handles.valThresholdMinDistance >= handles.valThresholdMaxDistance)
        habSegmentaCanais= 0;
        msg= sprintf(' Valor de threshold min. deve ser maior threshold máx. \n Verifique os valores!!!');
        msgbox(msg, 'Error');
    end
    
    % Verifica se os valors dos parãmetros numero de pontos min e max estão ok:
    if (handles.valMinPoints >= handles.valMaxPoints)
        habSegmentaCanais= 0;
        msg= sprintf(' Número min. de pontos deve ser maior número máx. de pontos \n Verifique os valores!!!');
        msgbox(msg, 'Error');
    end        
end

% Zera o vetor de erros, que identifica erro de segmentação no canal:
handles.errorSegCn(1:length(handles.cnSegmenta))= 0;

if (habSegmentaCanais)
    ctError= 0;
    % Efetua a leitura da PC original com os 16 canais apenas para visualização:
    % Primeiro, descobrir o número da nuvem de pontos:
    numChar= length(handles.pathRead);
    numPC= handles.pathRead(numChar-3:numChar);

    % Gerar o nome do folder para ler a PC original:
    nameFile= sprintf('\\%s.%s',numPC,handles.extPC);
    fullPathToReadPcOriginal= fullfile(handles.pathBase, nameFile);

    % Faz a leitura da PC original com os 16 canais:
    pcCompleta= pcread(fullPathToReadPcOriginal);
    
    for (ctCn=1:length(handles.cnSegmenta))
                  
        % Define o nome da PC referente ao canal que será lido e segmentado:
        nameFile= sprintf('cn%0.2d.%s', handles.cnSegmenta(ctCn), handles.extPC);
        fullPathPcRead= fullfile(handles.pathRead, nameFile);

        % Efetua a leitura da nuvem de pontos com do respectivo canal selecionado:
        pc= pcread(fullPathPcRead);
               
        % Efetua a segmetnação em duas etapas:
        % 1ª) faz a segmentação considerando apenas a distância mínima, usando 
        %     a função "fPcFiltraDistancia";
        % 2ª) Refina a segmentação usando a função do matlaba "pcsegdist()".
        % A 2ª etapa é opcional e executada depois da 1ª etapa.
        % 
        % 1ª Etapa:
        [pcCanalSegmentado handles]= fPcFiltraDistancia(pc, handles, ctCn, pcCompleta);
        
        % Se não retornar erro de segmentação o processo continua: 
        if (~handles.errorSegCn(ctCn))
            % 2ª Etapa, apenas se estiver habilitada::           
            if (handles.habSegmentacaoNatMatlab)
                [labels, numClusters] = pcsegdist(pcCanalSegmentada, handles.valMinDistance, 'NumClusterPoints', [handles.valMinPoints handles.valMaxPoints]);

                % Remove os pontos que não tem valor de label válido, ou seja =0.
                idxValidPoints = find(labels);

                % Guarda o cluster definidos na variável "idxValidPoints" quem contém 
                % os endereços com os pontos válidos:
                labelColorIndex = labels(idxValidPoints);

                % Gera um nuvem de pontos com os valores segmentados:
                pcCanalSegmentado = select(pcCanalSegmentada, idxValidPoints);
            end
                       
            % Salva apenas se "handles.habSavePCSeg" estiver habilitado: 
            if (handles.habSavePCSeg)
                % Define o path onde será salva a pc segmentada:
                % Primeiro, descobrir o número da nuvem de pontos:
                numChar= length(handles.pathRead);
                numPC= handles.pathRead(numChar-3:numChar);

                % Gerar o nome do folder onder a PC segmentada será salva:
                nameFolder= sprintf('\\pc%s',numPC);
                fullPathToSave= fullfile(handles.pathBase, handles.folderToSaveSeg,nameFolder);

                % Verifica se o folder existe, se não existir eles serão criados:                     
                if ~isfolder(fullPathToSave)
                    mkdir(fullPathToSave);
                end
                % Gera o nome da PC a ser salva já com o valor original do
                % canal conforme definido no handle "handles.lookUpTable":
                nameFile= sprintf('%s.%s', handles.lookUpTable{handles.cnSegmenta(ctCn)}, handles.extPC);
                
                fullPathPcSave= fullfile(fullPathToSave, nameFile);
                pcwrite(pcCanalSegmentado, fullPathPcSave);
            end          
        else
            % Incrementador e identificador de canal com erro:
            ctError= ctError+1;
            cnError(ctError)= handles.cnSegmenta(ctCn);            
        end
    end
end

% Se ocoreu erro eles serão informados:
if (ctError>0)
    msg= sprintf(' Foram detectados erros de segmentação nos canais: %s. \n Analise as PCs e reajuste os parâmetros.', num2str(cnError));
    answer= questdlg(msg, 'Erros de segmentação!', 'Ok', 'Ok');
else    
    msg= sprintf('Segmentação dos 16 canais OK!!');
end

% Define mensagem final a ser exibida:
handles.statusProgram= msg;
end
