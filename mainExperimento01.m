%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para abrir, processar e registraa as nuven de pontos do experimento
% feito no lab do CERTI.
% Data do experimento: 25/11/2022
% Padrões: pirâmede com esfereas,simulacro riser PVC e plano. 
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
clc;
close all

% Principais parâmetros.
% N é o número de posições onde o LiDAR gerou as nuvens de pontos.

path.Base= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\experimento_01\pcd';
path.ValInterferometro= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\experimento_01\interferometro_exp_01.mat';

name.FileBase= '\2022_11_25_01_';
name.FolderBase= '\2022_11_25_01_';
name.extPC= 'pcd';

param.numFolders= 15;
param.fileIni= 2;
param.fileEnd= 2;
param.showPC= 0;
param.showPCReg= 1;

%Algoritmos para registros das PCS
param.useICP= 1;
param.useCPD= 0;
param.useNDT= 0; 

% Parâmetros para efetuar o downSample da PC
param.maxNumPoints= 12;
param.mergeSize   = 0.001;
param.gridSize    = 2;

% Carrega os resultados de medição do interferômetro:
medicoes= load(path.ValInterferometro);

% Faz a leitura de todas as nuvens de pontos no formato '.pcd'. chamando a 
% função fCarregaPCs, qeu retorn a nuvemde pontos bruta e filtrada:
[pc pcDenoised]= fCarregaPCs(path, name, param);

% Chama a função fRegistraPC_ICP para registrar as PCs do experimento.
% Esta função retorno a transformação de corpo rígido para cada PC gerada.
tform = fRegistraPC_ICP(pc, pcDenoised, param);

% Efetua a análise do desempenho do registro das PCs
fAnalisaDados(tform,medicoes, param);



