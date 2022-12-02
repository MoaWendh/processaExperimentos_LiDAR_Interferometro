%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para abrir e registra as nuven de pontos do experimento
% feito no lab do CERTI.
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tform = fRegistraPC_ICP(pc, pcDenoised, param)
clc;
close all

% Toma a primeira PC como referência.
pcFull= pcDenoised{1,1};

% Faz uma subamostragem.
% pcDownSampleRef= pcdownsample(pcFull, 'gridAverage', gridSize); 
pcDownSampleRef= pcdownsample(pcFull, 'nonuniformGridSample', param.maxNumPoints);

% Cria uma tranformação neutra
tformAccum= affine3d;

for (ctPC=2:param.numFolders)
   pcAux= pc{ctPC,1};
   
   % Faz uma sub-amostragem no PC, este procedimento melhora o desempenho
   % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
   % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
   % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
   % 'planeToPlane'. 
   pcDownSample= pcdownsample(pcAux, 'gridAverage', param.gridSize);
   
   % O parâmetro 'nonuniformGridSample' tem melhor desempenho quando a
   % métrica usada no registro das PC é 'pointToPlane'.
   % pcDownSample= pcdownsample(pcAux, 'nonuniformGridSample', maxNumPoints);
   
   % Calcula a tranformação de corpo rígido, podem ser usados 3 tipos de
   % algoritmos, ICP, CPD e NDT
   if (param.useICP)
        tformAux = pcregistericp(pcDownSample, pcDownSampleRef, 'Metric','pointToPlane','Extrapolate', true);
   elseif (param.useCPD)
        tformAux = pcregistericp(pcDownSample, pcDownSampleRef, 'Metric','pointToPlane','Extrapolate', true);   
   elseif (param.useNDT)
        tformAux = pcregistericp(pcDownSample, pcDownSampleRef, 'Metric','pointToPlane','Extrapolate', true);
   end
   
   % Acumula a transformação a cada iteração. 
   tformAccum = affine3d(tformAux.T * tformAccum.T);
   
   % Executa o registro, alinhamento das PCs.
   pcAligned = pctransform(pcAux, tformAccum);
   
   % Faz a fusão das PC a cada iteração.
   pcFull = pcmerge(pcFull, pcAligned, param.mergeSize);
   
   % Armazena o PC atual na variável "pcDownSampleRef" para a próxima
   % iteração.
   pcDownSampleRef= pcDownSample;
   
   % Guarda algumas variáveis para análise posterior:
   tform{ctPC-1}= tformAux; 
   translation(ctPC-1,:)= tformAux.Translation(1,:);
   
   % Exibe o resultado do registro das PCs a cada iteração
   if (param.showPCReg)
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
end