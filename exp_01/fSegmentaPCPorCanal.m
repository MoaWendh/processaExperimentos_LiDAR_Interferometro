
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
function fSegmentaPCPorCanal()
clear;
clc;
close all;

% Defini��o de alguns paths:
param.path.Base= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01\Reg';
param.name.extPC= 'pcd';
% Define alguns par�metros adicionais:
param.path.numCanais= 16;
param.val.minDistance= 0.05;
param.val.minPoints= 300;
param.show.PCSegmented= 1;

% Para cada canal da PC � efetuada a segmenta��o de uma linha.
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
