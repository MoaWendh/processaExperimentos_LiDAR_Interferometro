
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
function fSegmentaPCPorCanal()
clear;
clc;
close all;

% Definição de alguns paths:
param.path.Base= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01\Reg';
param.name.extPC= 'pcd';
% Define alguns parâmetros adicionais:
param.path.numCanais= 16;
param.val.minDistance= 0.05;
param.val.minPoints= 300;
param.show.PCSegmented= 1;

% Para cada canal da PC é efetuada a segmentação de uma linha.
for (cn=1:param.path.numCanais)
    % Especifica o path de onde a PC será lida.
    nameFolder= sprintf('\\cn%0.2d',cn);
    param.path.PCFull= fullfile(nameFolder);
    
    % Especifica o path onde a PC segmentada será salva.
    % Caso o folder não exista ele será criado:
    nameFolder= sprintf('Seg',cn);
    param.path.PCSeg= fullfile(param.path.PCFull, nameFolder);
    
    pathToSave= fullfile(param.path.Base, param.path.PCSeg);

    % Se a pasta onde serão salvas as PCs segmentadas não existir ela será criada:
    if ~isfolder(pathToSave)
        mkdir(pathToSave);
    end   
    
    % Chama a função que faz a segmentação da PC:
    fSegmentaPC(param);
end
end
