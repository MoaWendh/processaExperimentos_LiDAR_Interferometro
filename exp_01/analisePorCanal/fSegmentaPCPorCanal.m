
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Esta fun��o efetua a leitura da PC de apenas 1 canal e segmenta uma 
% determinada linha.
% Ela chama a fun��o fSegmentaPC para segmantar a linha.
% ***Aten��o*** 
% O LiDAR VLP-16 ou Puck LITE retorna os pacotes de dados dados a informa��o 
% dos 16 canais conforme a sequ�ncia que segue abaixo:
%  Posi��o    Canal    �ngulo(Eleva��o)
%    01        00          -15�
%    02        02          -13�
%    03        04          -11�
%    04        06          -9�
%    05        08          -7�
%    06        10          -5�
%    07        12          -3�
%    08        14          -1�
%    09        01           1�
%    10        03           3�
%    11        05           5�
%    12        07           7�
%    13        09           9�
%    14        11           11�
%    15        13           13�
%    16        15           15�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles= fSegmentaPCPorCanal(handles)
close all;

if (~isdir(handles.pathRead))
    msg= sprintf('Folder n�o existe! Verifique se os canais forma separados.');
    msgbox(msg);
    habSegmentaCanais= 0;
else
    % Identifica os subfolders que cont�m as PCs com os canais separdos. 
    allSubFolders= genpath(handles.pathRead);
    % Separa os subfolders em uma vari�vel tipo cell:
    handles.subFolders= regexp(allSubFolders, ';', 'split');
    
    % Define uma mensagem a ser exibida:
    msg= sprintf(' - Ser�o segmentados os canais:\n [ %s ]', num2str(handles.cnSegmenta)) ;
    % Exibe uma menagem solicitando confirma��o de execu��o:
    answer = questdlg(msg, 'Ok para continuar', 'Ok', 'Sair', 'Ok');
    % Handle response
    switch answer
        case 'Ok'
            habSegmentaCanais= 1;
        case 'Sair'
            habSegmentaCanais= 0;
            msg= sprintf('Execu��o da segmenta��o foi abortada pelo usu�rio!!');
    end
    % Verifica se os valors dos par�metros de threshold est�o ok.
    if (handles.valThresholdMinDistance >= handles.valThresholdMaxDistance)
        habSegmentaCanais= 0;
        msg= sprintf(' Valor de threshold min. deve ser maior threshold m�x. \n Verifique os valores!!!');
        msgbox(msg, 'Error');
    end
    
    % Verifica se os valors dos par�metros numero de pontos min e max est�o ok:
    if (handles.valMinPoints >= handles.valMaxPoints)
        habSegmentaCanais= 0;
        msg= sprintf(' N�mero min. de pontos deve ser maior n�mero m�x. de pontos \n Verifique os valores!!!');
        msgbox(msg, 'Error');
    end        
end

% Zera o vetor de erros, que identifica erro de segmenta��o no canal:
handles.errorSegCn(1:length(handles.cnSegmenta))= 0;

if (habSegmentaCanais)
    ctError= 0;
    % Efetua a leitura da PC original com os 16 canais apenas para visualiza��o:
    % Primeiro, descobrir o n�mero da nuvem de pontos:
    numChar= length(handles.pathRead);
    numPC= handles.pathRead(numChar-3:numChar);

    % Gerar o nome do folder para ler a PC original:
    nameFile= sprintf('\\%s.%s',numPC,handles.extPC);
    fullPathToReadPcOriginal= fullfile(handles.pathBase, nameFile);

    % Faz a leitura da PC original com os 16 canais:
    pcCompleta= pcread(fullPathToReadPcOriginal);
    
    for (ctCn=1:length(handles.cnSegmenta))
                  
        % Define o nome da PC referente ao canal que ser� lido e segmentado:
        nameFile= sprintf('cn%0.2d.%s', handles.cnSegmenta(ctCn), handles.extPC);
        fullPathPcRead= fullfile(handles.pathRead, nameFile);

        % Efetua a leitura da nuvem de pontos com do respectivo canal selecionado:
        pc= pcread(fullPathPcRead);
               
        % Efetua a segmetna��o em duas etapas:
        % 1�) faz a segmenta��o considerando apenas a dist�ncia m�nima, usando 
        %     a fun��o "fPcFiltraDistancia";
        % 2�) Refina a segmenta��o usando a fun��o do matlaba "pcsegdist()".
        % A 2� etapa � opcional e executada depois da 1� etapa.
        % 
        % 1� Etapa:
        [pcCanalSegmentado handles]= fPcFiltraDistancia(pc, handles, ctCn, pcCompleta);
        
        % Se n�o retornar erro de segmenta��o o processo continua: 
        if (~handles.errorSegCn(ctCn))
            % 2� Etapa, apenas se estiver habilitada::           
            if (handles.habSegmentacaoNatMatlab)
                [labels, numClusters] = pcsegdist(pcCanalSegmentada, handles.valMinDistance, 'NumClusterPoints', [handles.valMinPoints handles.valMaxPoints]);

                % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
                idxValidPoints = find(labels);

                % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
                % os endere�os com os pontos v�lidos:
                labelColorIndex = labels(idxValidPoints);

                % Gera um nuvem de pontos com os valores segmentados:
                pcCanalSegmentado = select(pcCanalSegmentada, idxValidPoints);
            end
                       
            % Salva apenas se "handles.habSavePCSeg" estiver habilitado: 
            if (handles.habSavePCSeg)
                % Define o path onde ser� salva a pc segmentada:
                % Primeiro, descobrir o n�mero da nuvem de pontos:
                numChar= length(handles.pathRead);
                numPC= handles.pathRead(numChar-3:numChar);

                % Gerar o nome do folder onder a PC segmentada ser� salva:
                nameFolder= sprintf('\\pc%s',numPC);
                fullPathToSave= fullfile(handles.pathBase, handles.folderToSaveSeg,nameFolder);

                % Verifica se o folder existe, se n�o existir eles ser�o criados:                     
                if ~isfolder(fullPathToSave)
                    mkdir(fullPathToSave);
                end
                % Gera o nome da PC a ser salva j� com o valor original do
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

% Se ocoreu erro eles ser�o informados:
if (ctError>0)
    msg= sprintf(' Foram detectados erros de segmenta��o nos canais: %s. \n Analise as PCs e reajuste os par�metros.', num2str(cnError));
    answer= questdlg(msg, 'Erros de segmenta��o!', 'Ok', 'Ok');
else    
    msg= sprintf('Segmenta��o dos 16 canais OK!!');
end

% Define mensagem final a ser exibida:
handles.statusProgram= msg;
end
