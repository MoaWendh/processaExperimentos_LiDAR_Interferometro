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

%Passado pelo Vinicius
%profile clear       % clean profile history
%profile -memory on  % Bring memory info

% Principais parâmetros.
% N é o número de posições onde o LiDAR gerou as nuvens de pontos.

path.Base= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\experimento_01\pcd';
path.ValInterferometro= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\experimento_01\interferometro_exp_01.mat';

% Parâmetros gerais:
name.FileBase= '\2022_11_25_01_';
name.FolderBase= '\2022_11_25_01_';
name.extPC= 'pcd';
param.numFolders= 15;
param.fileIni= 2;
param.fileEnd= 2;

% Parâmetros para exibição de dados:
param.showPC= 0;
param.showPCReg= 0;
param.showData= 1;

% Parametros para definição do algoritmo usado para o registro das PCS
param.algorithmReg= 'ICP';
%param.algoritmo= 'CPD';
%param.algoritmo= 'NDT';

% Parametros para definição do algoritmo usado para subamostrar as PCS
%param.algorithmSubAmostra= 'Random';
param.algorithmSubAmostra= 'gridAverage';
%param.algorithmSubAmostra= 'nonUniformGrid';

% Parametro usado para fazer o merge das PCs
param.mergeSize= 0.001;

% Parâmetros para avaliação dos algoritmos:
param.testaVariacaoGridSize= 0;
param.testaVariacaoMetricaRegistro= 0;
param.NumVariacaoGridSize= 50;
param.NumVariacaoMetrica= 2;

% Parâmetros para efetuar o downSample da PC. No Matalab tem 3 métodos:
% 1) "pcdownsample(ptCloudIn,'random',percentage)", onde a escolha dos pontos
% segue um creitério aleatório. Usada apenas para pointo-a-ponto.
% 2) "pcdownsample(ptCloudIn,'gridAverage',gridStep)", faz uma subamostragem
% baseada num filtro especificado pelo grid de um 3D box, ou volume cúbico.
% Esta é usada tanto para ponto-a-ponto quanto ponto-a-plano.  
% 3) "pcdownsample(ptCloudIn,'nonuniformGridSample',maxNumPoints)", a
% filtragem é baseada num volume cubico também, porém o grid não é definido, 
% apenas a quantiade de pontos contida no volume.
% Também define a métrica do registro em função do algoritmo de
% subamostragem, se é ponto-a-ponto ou ponto-a-plano.
param.percentage= 0.2; % Usado no método 1 -Percentual de redução da PC entre 0 e 1; 
param.gridSizeIni= 0.1; % Usado no método 2- Define o grid do volume cúbico, 3D Box, em metros.
param.maxNumPoints= 6; % Usado no método 3- max. quantidadde de pontos para 3D Box, o mínimo é 6.

switch (param.algorithmSubAmostra)
    case 'Random'
        param.registerMetric='pointToPoint'; 
        param.DownSampleIni= param.percentage; 
    case 'gridAverage'
        param.registerMetric='pointToPlane';
        param.DownSampleIni= param.gridSizeIni;
    case 'nonUniformGrid'
        param.registerMetric='pointToPlane';
        param.DownSampleIni= param.maxNumPoints;
    otherwise 
        warning('Unexpected plot type. No plot created.');
end

% Carrega os resultados de medição do interferômetro:
medicoes= load(path.ValInterferometro);

% Faz a leitura de todas as nuvens de pontos no formato '.pcd'. chamando a 
% função fCarregaPCs, qeu retorn a nuvemde pontos bruta e filtrada:
[pc pcDenoised]= fCarregaPCs(path, name, param);

%%
if (param.testaVariacaoGridSize)
    % Nesta seção é avaliado o desempenho dos registros considerando a
    % variação do "gridSize" usado para subamostrar as PCs.
    for (i=1:param.NumVariacaoGridSize)
        switch (param.algorithmSubAmostra)
            case 'Random'
                param.DownSample(i)= (i/100)*param.DownSampleIni;
            case 'gridAverage'
                param.DownSample(i)= i*param.DownSampleIni;
            case 'nonUniformGrid'
                param.DownSample(i)= param.DownSampleIni + i;
            otherwise 
                warning('Escolha um dos três algoritmos de subamostragem.');
        end
        param.DownSampleAtual= param.DownSample(i);
        
        % Chama a função fRegistraPC_ICP para registrar as PCs do experimento.
        % Esta função retorno a transformação de corpo rígido para cada PC gerada.
        [tform{i} pcFull{i}]= fRegistraPC_ICP(pc, pcDenoised, param);       
        % Efetua a análise do desempenho do registro das PCs
        [vetorTransLiDAR{i} deslocamentoInterferometro{i} erro{i}]= fAnalisaDados(tform{i}, medicoes, pcFull{i}, param);
        if (param.showData)
            fExibeDados(vetorTransLiDAR{i}, deslocamentoInterferometro{i}, erro{i}, pcFull{i}, param);
        end
        erroXMedio(i)= erro{i}.XMedio;
        DP(i)= erro{i}.DP;
        erroMax(i)= erro{i}.Max;
        erroMin(i)= erro{i}.Min;
        num(i)= i;     
    end
    % Montam tabela com os resultados:
    t=table(num',param.DownSample',erroXMedio', DP', erroMax',erroMin')
    t.Properties.VariableNames = {'num.','gridZise','erroMedio','DP','erroMax','erroMin'}
else
    param.DownSampleAtual= param.DownSampleIni;
    % Faz a leitura de todas as nuvens de pontos no formato '.pcd'. chamando a
    % função fCarregaPCs, qeu retorn a nuvemde pontos bruta e filtrada:
    [pc pcDenoised]= fCarregaPCs(path, name, param);

    % Chama a função para registrar apenas 1 vez:
    [tform pcFull]= fRegistraPC_ICP(pc, pcDenoised, param);
    
    % Efetua a análise do desempenho do registro das PCs
    [vetorTransLiDAR deslocamentoInterferometro erro]= fAnalisaDados(tform, medicoes, pcFull, param);
    
    %%
    % chama a função para exibir os resulatdos da análise dos dados:
    if (param.showData)
        fExibeDados(vetorTransLiDAR, deslocamentoInterferometro, erro, pcFull, param);
    end
    num= 1;
    t=table(num', param.DownSampleAtual', erro.XMedio', erro.DP', erro.Max', erro.Min');
    t.Properties.VariableNames = {'num.','gridZise','erroMedio','DP','erroMax','erroMin'}
end

a=0;
