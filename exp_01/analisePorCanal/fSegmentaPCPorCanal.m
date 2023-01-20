
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
    msg= sprintf('Folder n�o existe! Verifique se os canais foram separados.');
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
% Zera o contador de erro:
ctError= 0;

if (habSegmentaCanais)
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
        pcCanalSeparado= pcread(fullPathPcRead);
               
        % Se "handles.habSegmentacaoNatMatlab" estiver habilitado ser� efetuada
        % a segmetna��o em duas etapas:
        % 1�) faz a segmenta��o considerando apenas a dist�ncia m�nima, usando 
        %     a fun��o "fPcFiltraDistancia";
        % 2�) Refina a segmenta��o usando a fun��o do matlaba "pcsegdist()".
        % A 2� etapa � opcional e executada e depende do desempenho da 1� etapa.
       
        % Se n�o retornar erro de segmenta��o o processo continua: 
        if (~handles.errorSegCn(ctCn))          
            if (handles.habSegmentacaoNatMatlab)
                % 1� Etapa:
                [pcCanalSegmentado01 handles]= fPcFiltraDistancia(pcCanalSeparado, handles, ctCn, pcCompleta); 

                % O par�metro "handles.valMinDistance" define a dist�ncia
                % m�nima que deve existir entre 2 ou mais cluster:
                % 2� Etapa: 
                [labels, handles.numClusters] = pcsegdist(pcCanalSegmentado01, handles.valMinDistance, 'NumClusterPoints', [handles.valMinPoints handles.valMaxPoints]);
                                
                % Remove os pontos que n�o tem valor de label v�lido, ou seja =0.
                idxValidPoints = find(labels);

                % Guarda o cluster definidos na vari�vel "idxValidPoints" quem cont�m 
                % os endere�os com os pontos v�lidos:
                labelColorIndex = labels(idxValidPoints);

                % Gera um nuvem de pontos com os valores segmentados:
                pcCanalSegmentado = select(pcCanalSegmentado01, idxValidPoints);
            
            else
                % 1� Etapa:
                [pcCanalSegmentado handles]= fPcFiltraDistancia(pcCanalSeparado, handles, ctCn, pcCompleta); 
                handles.numClusters= 1;
            end
                        
            % Exibe as PCs apenas se o par�metro "handles.habShowPC" estiver ativo:
            if (handles.habShowPC)
                if (handles.habSegmentacaoNatMatlab)
                    fShowPcFiltradaPorDistancia(pcCompleta, pcCanalSeparado, pcCanalSegmentado, pcCanalSegmentado01, handles, ctCn);
                else
                    fShowPcFiltradaPorDistancia(pcCompleta, pcCanalSeparado, pcCanalSegmentado, 0, handles, ctCn);
                end
                
                % Sinaliza ao usu�rio se n�o for detectado cluster ou se o n�mero de clusters for maior que 1:
                if (handles.numClusters==0) || (handles.numClusters>1) 
                    msg= sprintf(' Aten��o!! \n Foram detectados %d clusters usando a fun��o pcsegdist().', handles.numClusters);                    
                    figMsgBox= msgbox(msg, 'Warn', 'warn');
                else
                    msg= sprintf(' Segmenta��o do canal %d concluida!\n Ok para continuar.', handles.cnSegmenta(ctCn));                       
                    figMsgBox= msgbox(msg);
                end
                % Aten��o!!!!
                % Neste caso onde deseja-se manipular a figura, n�o pode-se usar a
                % fun��o "questdlg()" para di�logo, pois ela tem o par�metro modal,
                % e isto trava todas as figuras. Ent�o deve-se usar a fun��o
                % "msgbox()" seguida da fun��o "uiwait()" que � modo "normal" e n�o
                % "modal", isto possibilita manipular a figura exibida, tal como
                % zoom, rota��o deslocamento, etc.
                uiwait(figMsgBox);
            end
                      
            % Salva apenas se "handles.habSavePCSeg" estiver habilitado: 
            if (handles.habSavePCSeg) && (handles.numClusters==1)
                % Define o path onde ser� salva a pc segmentada:
                % Primeiro, descobrir o n�mero da nuvem de pontos:
                numChar= length(handles.pathRead);
                numPC= handles.pathRead(numChar-3:numChar);

                % Gera o nome da PC a ser salva j� com o valor original do
                % canal conforme definido no handle "handles.lookUpTable":
                nameFile= sprintf('\\pc%s_%s.%s', numPC, handles.lookUpTable{handles.cnSegmenta(ctCn)}, handles.extPC);
                fullPathToSave= fullfile(handles.pathBase, handles.folderToSaveSeg);
                
                % Verifica se o folder existe, se n�o existir eles ser�o criados:                     
                if ~isfolder(fullPathToSave)
                    mkdir(fullPathToSave);
                end
                
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
if (habSegmentaCanais==1)    
    if (ctError>0)
        msg= sprintf(' Foram detectados erros de segmenta��o nos canais: %s. \n Analise as PCs e reajuste os par�metros.', num2str(cnError));
        answer= questdlg(msg, 'Erros de segmenta��o!', 'Ok', 'Ok');
    else  
        if (handles.numClusters==1)
            msg= sprintf('Segmenta��o dos 16 canais OK!!');
        end
    end
end

% Define mensagem final a ser exibida:
handles.statusProgram= msg;
end
