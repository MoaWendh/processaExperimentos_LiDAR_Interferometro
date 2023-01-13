
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

% Para evitar erro, se for escolhida apenas um arquivo, nuvem de pontos,
% a vari�vel "handles.fileSegmentar" n�o ser� cell e a fun��o length() ir� determinar o
% n�mero de caracteres contido na vari�vel "handles.fileSegmentar", isto n�o �
% desej�vel. Por isso � feito o teste abaixo:
if iscell(handles.fileSegmentar)
    numPCs= length(handles.fileSegmentar);
else
    numPCs= 1;
end

% Define uma mensagem a ser exibida:
msg= sprintf(' -Total de nuvens de pontos: %d \n -Ser�o separados os canais:\n [ %s ]', numPCs, num2str(handles.cnSegmenta)) ;
% Exibe uma menagem solicitando confirma��o de execu��o:
answer = questdlg(msg, 'Ok para continuar', 'Ok', 'Sair', 'Ok');
% Handle response
switch answer
    case 'Ok'
        habSegmentaCanais= 1;
    case 'Sair'
        habSegmentaCanais= 0;
end

if (habSegmentaCanais)
    for (ctPC=1:numPCs)
        % Faz leitura da nuvem de pontos:
        if (numPCs==1)
            handles.PcToRead= fullfile(handles.path, handles.fileSegmentar);
        else
            handles.PcToRead= fullfile(handles.path, handles.fileSegmentar{ctPC});
        end
        
        % ATEN��O!!!!!!!!!!
        % PAREI AQUII ELABORANDO O PATH PARA SEGMENTA�O!!!!
        
        % Efetua a leitura da nuvem de pontos com do respectivo canal
        % selecionado:
        pc= pcread(handles.PcToRead);
        
        for (ctCn=1:length(handles.cn))
        
        end
    end
end


% Defini��o de alguns paths:
param.path.Base= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01\out\pcReg';
param.name.extPC= 'pcd';
% Define alguns par�metros adicionais:
param.path.numCanais= 16;
param.val.minDistance= 0.05;
param.val.minPoints= 300;
param.show.PCSegmented= 1;

% Efetua a segmenta��o para o(s) canal(is) especificados:
for (cn=1:param.path.numCanais)
    % Especifica o path de onde a PC ser� lida.
    nameFolder= sprintf('\\cn%0.2d',cn);
    param.path.PCFull= fullfile(nameFolder);
    
    % Especifica o path onde a PC segmentada ser� salva.
    % Caso o folder n�o exista ele ser� criado:
    nameFolder= sprintf('Seg',cn);
    param.path.PCSeg= fullfile(param.path.PCFull, nameFolder);
    
    pathToSave= fullfile(param.path.Base, param.path.PCSeg);

    % Se a pasta onde ser�o salvas as PCs segmentadas n�o existir ela ser� criada:
    if ~isfolder(pathToSave)
        mkdir(pathToSave);
    end   
    
    % Chama a fun��o que faz a segmenta��o da PC:
    fSegmentaPC(param);
end
end
