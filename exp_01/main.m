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

% Definição de alguns paths:
param.path.Base= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01';
% O único path que precisa ser definido é o param.path.Base, os outros são
% criados ao longo do código.
param.path.PC= '\original';
param.path.PCReg= '\Reg'; % Folder onde serão salvas as PCs registradas
param.path.PCSeg= '\Seg'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
param.path.PCPlaneAdjuste= '\Pln'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
param.path.PCCanais= '\Reg\cn'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
param.path.PCFull= '\Reg\full'; % Folder onde serão salvas as PCs full, ou seja, concatenadas após o resgistro.

% Captura o número de folder contendo as PCs:
pathAux= sprintf('%s%s',param.path.Base,param.path.PC);
infoFolder= dir(pathAux);
param.val.numFolders= nnz([infoFolder.isdir]) - 2;

% Definição de alguns nomes de arquivos:
param.name.FolderBase= '\2022_11_25_01_';
param.name.FileBase  = '\2022_11_25_01_';
param.name.FileTForm = 'tform';
param.name.FileDataInterferometro = '\interferometro_exp_01.mat';

% definição da extensão de alguns arquivos:
param.name.extPC= 'pcd';

% Parametros que definem quantas PCs serão lidas por folder:
param.val.fileIni= 3;
param.val.fileEnd= 3;

% Parâmetros para segemtação das PCs para definir o ROI do plano:
param.val.minDistance= 0.05; 
param.val.minPoints= 800;

%Parâmetros para ajustar plano:
param.val.maxDistance= 0.02;

% Parâmetros com flags para habilitar a exibição de dados:
param.show.PC= 0;
param.show.PCReg= 0;
param.show.Data= 1;
param.show.PCSegmented= 0;

% Flags que habilitam algumas funções: 
param.hab.TesteRegistro= 1; % Habilita a variação dos parâmetros para teste de registro.
param.hab.Registra     = 0; % Se 1 Habilita o registro das PCs.
param.hab.Segmenta     = 0; % Se 1 Habilita a segmentação das PCs.
param.hab.AjustaPlano  = 0; % Se 1 Habilita a segmentação das PCs.
param.hab.VariacaoMetricaRegistro= 0;

% Parametros para definição do algoritmo usado para o registro das PCS
param.algorithm.Reg= 'ICP';
%param.algoritmo.Reg= 'CPD';
%param.algoritmo.Reg= 'NDT';

% Parametros para definição do algoritmo usado para subamostrar as PCS
%param.algorithm.SubAmostra= 'Random';
param.algorithm.SubSample= 'gridAverage';
%param.algorithm.SubAmostra= 'nonUniformGrid';

% Parametro usado para fazer o merge das PCs
param.val.mergeSize= 0.001;

% Parâmetros para avaliação dos algoritmos de registro:
param.val.VariacaoGridSize= 10;
param.val.VariacaoMetrica= 2;

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
param.val.percentage= 0.2;  % Usado no método 1- Percentual de redução da PC entre 0 e 1; 
param.val.gridSizeIni= 0.1; % Usado no método 2- Define o grid do volume cúbico, 3D Box, em metros.
param.val.maxNumPoints= 6;  % Usado no método 3- max. quantidadde de pontos para 3D Box, o mínimo é 6.

switch (param.algorithm.SubSample)
    case 'Random'
        param.val.registerMetric='pointToPoint'; 
        param.val.DownSampleIni= param.val.percentage; 
    case 'gridAverage'
        param.val.registerMetric='pointToPlane';
        param.val.DownSampleIni= param.val.gridSizeIni;
    case 'nonUniformGrid'
        param.val.registerMetric='pointToPlane';
        param.val.DownSampleIni= param.val.maxNumPoints;
    otherwise 
        warning('Unexpected plot type. No plot created.');
end

% Carrega os resultados de medição feitas diretamente no interferômetro:
pathDataInterferomtero= sprintf('%s%s', param.path.Base, param.name.FileDataInterferometro);
medicoes= load(pathDataInterferomtero);

% Se "param.hab.Registro" estiver habilitado será chamada a função fRegistraPC
% para registrar as PCs do experimento. Esta função retorno a transformação 
% de corpo rígido para cada PC gerada. Ela também salva todas as PCs registradas 
% numa único folder, bem como uma nuvem de pontos concatenda, full.
% Obs.: Esta função deve ser habilitada depois de todos os ensaios serem
% efetuados e definido o melhor algoritmo e melhor parâmetro para o registro.
if (param.hab.Registra)
    % Carrega as PCs geradas no experimento:
    [pc pcDenoised]= fCarregaPCs(param);
    
    param.val.DownSampleAtual= param.val.DownSampleIni;
    
    % Chama a função fRegistraPC para registrar as PCs do experimento.
    [tform pcFull]= fRegistraPC(pc, pcDenoised, param);   
end

if (param.hab.TesteRegistro)
    % Nesta seção é avaliado o desempenho dos registros considerando a
    % variação do "gridSize" usado para subamostrar as PCs.
    fprintf(' Testando %d parâmetros para os algoritmos: \n',param.val.VariacaoGridSize);
    fprintf(' - Registro: %s \n', param.algorithm.Reg)
    fprintf(' - Subamostrage: %s\n',param.algorithm.SubSample);
    fprintf('Val. parâm. sub-amostragem: \n ');
    
    % Carrega as PCs geradas no experimento:
    [pc pcDenoised]= fCarregaPCs(param);
    
    for (i=1:param.val.VariacaoGridSize)
        switch (param.algorithm.SubSample)
            case 'Random'
                param.val.DownSample(i)= (i/100)*param.val.DownSampleIni;
            case 'gridAverage'
                param.val.DownSample(i)= i*param.val.DownSampleIni;
            case 'nonUniformGrid'
                param.val.DownSample(i)= param.val.DownSampleIni + i;
            otherwise 
                warning('Escolha um dos três algoritmos de subamostragem.');
        end
        param.val.DownSampleAtual= param.val.DownSample(i);
        
        % Chama a função fRegistraPC para registrar as PCs do experimento.
        % Esta função retorno a transformação de corpo rígido para cada PC gerada.       
        [tform{i} pcFull{i}]= fRegistraPC(pc, pcDenoised, param); 
        
        % Efetua a análise do desempenho do registro das PCs
        [vetorTransLiDAR{i} deslocamentoInterferometro{i} erro{i}]= fAnalisaDados(tform{i}, medicoes, pcFull{i}, param);
        if (param.show.Data)
            fExibeDados(vetorTransLiDAR{i}, deslocamentoInterferometro{i}, erro{i}, pcFull{i}, param);
        end
        erroXMedio(i)= erro{i}.XMedio;
        DP(i)= erro{i}.DP;
        erroMax(i)= erro{i}.Max;
        erroMin(i)= erro{i}.Min;
        num(i)= i; 
        fprintf(' %d= %2.4f\n',i, param.val.DownSample(i));
    end
    % Montam tabela com os resultados:
    t=table(num',param.val.DownSample',erroXMedio', DP', erroMax',erroMin');
    t.Properties.VariableNames = {'num.', 'gridZise', 'erroMedio', 'DP', 'erroMax', 'erroMin'}
end

% Efetua a segmentação das PCs para extrair ROI que é o plano de referencia
if (param.hab.Segmenta)
   fSegmentaPC(param);
end

if (param.hab.AjustaPlano)
    fAjustaPlanoPC(param);
end

a=0;
