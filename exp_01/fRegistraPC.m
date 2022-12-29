%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para abrir e registra as nuven de pontos do experimento
% feito no lab do CERTI.
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tform pcFull]= fRegistraPC(pc, pcDenoised, handles)

fprintf(' Registrando e salvando as PCs e as Tranformações de corpo rígido');

% Toma a primeira PC como referência.
pcFull= pc{1,1};

% Faz uma sub-amostragem na PC, este procedimento melhora o desempenho
% da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
% 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
% pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
% 'planeToPlane'. 

switch (handles.algorithm.SubSample)
    case 'Random'
        pcDownSampleRef= pcdownsample(pc{1,1},'random',handles.val.DownSampleAtual); 
    case 'gridAverage'
        pcDownSampleRef= pcdownsample(pc{1,1}, 'gridAverage', handles.val.DownSampleAtual);
    case 'nonUniformGrid'
        pcDownSampleRef= pcdownsample(pc{1,1}, 'nonuniformGridSample',handles.val.DownSampleAtual);
    otherwise 
        warning('Unexpected plot type. No plot created.');
end
    
% Cria uma tranformação neutra
tformAccum= affine3d;

% Verifica se folder onde serão salvas as PCs alinhadas existe, se não
% existir o folder será gerado, conforme definido no handles:
pathToSavePCReg= sprintf('%s%s',handles.path.BaseSave, handles.path.PCReg);
if ~isfolder(pathToSavePCReg)
    mkdir(pathToSavePCReg);
end

% Path onde são salvas as PCs totalmente concatenadas, ou seja, a pcFull
% constituida das N PCs.
pathToSavePCRegFull= sprintf('%s%s',handles.path.BaseSave, handles.path.PCFull);
if ~isfolder(pathToSavePCRegFull)
    mkdir(pathToSavePCRegFull);
end

% Path onde são salvas as transformações de coirpo rígodo 'tform' obtidas
% pelos algoritmos de registro:
pathToSaveTform= sprintf('%s%s',handles.path.BaseSave, handles.path.tform);
if ~isfolder(pathToSaveTform)
    mkdir(pathToSaveTform);
end

% Salva a primeira PC que será a referência:
nameFile= sprintf('%0.4d.%s',1, handles.name.extPC);
fullPath= fullfile(pathToSavePCReg, nameFile);
pcwrite(pc{1,1}, fullPath);

% Chama função para separar os 16 canais da PC de referênicia LiDAR.
fSeparaCanais(pc{1,1}, handles, 1);

for (ctPC=2:length(pc))
   pcAux= pc{ctPC,1};
   
   % Faz uma sub-amostragem no PC, este procedimento melhora o desempenho
   % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
   % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
   % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
   % 'planeToPlane'. 
    switch (handles.algorithm.SubSample)
        case 'Random'
            pcDownSample= pcdownsample(pcAux,'random',handles.val.DownSampleAtual); 
        case 'gridAverage'
            pcDownSample= pcdownsample(pcAux, 'gridAverage',handles.val.DownSampleAtual);
        case 'nonUniformGrid'
            pcDownSample= pcdownsample(pcAux, 'nonuniformGridSample',handles.val.DownSampleAtual);
        otherwise 
            warning('Escolha um dos três algoritmos de subamostragem.');
    end
   
   % Calcula a tranformação de corpo rígido, podem ser usados 3 tipos de
   % algoritmos, ICP, CPD e NDT  
   switch (handles.algorithm.Reg)
        case 'ICP'
            tformAux = pcregistericp(pcDownSample, pcDownSampleRef, 'Metric', handles.val.registerMetric, 'Extrapolate', true); 
        case 'CPD'
            tformAux = pcregistercpd(pcDownSample, pcDownSampleRef); 
        case 'NDT'
            tformAux = pcregisterndt(pcDownSample, pcDownSampleRef);
        otherwise 
            warning('Escolha um dos três algoritmos de registro: ICP, CPD ou NDT.');
    end
   
   % Acumula a transformação a cada iteração. 
   tformAccum= affine3d(tformAux.T * tformAccum.T);
   
   % Executa o registro, alinhamento das PCs.
   pcAligned(ctPC-1)= pctransform(pcAux, tformAccum);
   
   % Chama função para separar os 16 canais do LiDAR.
   fSeparaCanais(pcAligned(ctPC-1), handles, ctPC);
   
   % Salva a transformação de corpo rígido da PC atual:
   nameFile= sprintf('%s%0.4d',handles.name.FileTForm, ctPC-1, '.mat');
   fullPath= fullfile(pathToSaveTform, nameFile);
   R=tformAux.Rotation;
   t=tformAux.Translation;
   save(fullPath, 'R', 't');
   
   % Salva a PC devidamente alinhada:
   nameFile= sprintf('%0.4d.%s',ctPC, handles.name.extPC);
   fullPath= fullfile(pathToSavePCReg, nameFile);
   pcwrite(pcAligned(ctPC-1), fullPath);
   
   % Faz a fusão das PC a cada iteração.
   pcFull= pcmerge(pcFull, pcAligned(ctPC-1), handles.val.mergeSize);
   
   % Armazena o PC atual na variável "pcDownSampleRef" para a próxima
   % iteração.
   pcDownSampleRef= pcDownSample;
   
   % Guarda algumas variáveis para análise posterior:
   tform{ctPC-1}= tformAux; 
   translation(ctPC-1,:)= tformAux.Translation(1,:);
   
   % Exibe o resultado do registro das PCs a cada iteração
   if (handles.show.PCReg)
       if (ctPC==2)
           handle= figure;
       end
       pcshow(pcFull);
       title('PCs concatenadas');
       xlabel('X (m)');
       ylabel('Y (m)');
       zlabel('Z (m)');
       handle.WindowState='maximized';
   end 
end

% Salva todas as PCs concatenadas num único arquivoa:
nameFile= sprintf('pcFull.pcd');
fprintf('\n Salvando as PCs concatenadas no arquivo: %s ...', nameFile);
fullPath= fullfile(pathToSavePCRegFull, nameFile);
pcwrite(pcFull, fullPath);
end


