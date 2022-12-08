%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para abrir e registra as nuven de pontos do experimento
% feito no lab do CERTI.
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tform pcFull]= fRegistraPC(pc, pcDenoised, param)
% Toma a primeira PC como referência.
pcFull= pc{1,1};

% Faz uma sub-amostragem na PC, este procedimento melhora o desempenho
% da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
% 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
% pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
% 'planeToPlane'. 

switch (param.algorithm.SubSample)
    case 'Random'
        pcDownSampleRef= pcdownsample(pc{1,1},'random',param.val.DownSampleAtual); 
    case 'gridAverage'
        pcDownSampleRef= pcdownsample(pc{1,1}, 'gridAverage', param.val.DownSampleAtual);
    case 'nonUniformGrid'
        pcDownSampleRef= pcdownsample(pc{1,1}, 'nonuniformGridSample',param.val.DownSampleAtual);
    otherwise 
        warning('Unexpected plot type. No plot created.');
end
    
% Cria uma tranformação neutra
tformAccum= affine3d;

for (ctPC=2:param.val.numFolders)
   pcAux= pc{ctPC,1};
   
   % Faz uma sub-amostragem no PC, este procedimento melhora o desempenho
   % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
   % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
   % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
   % 'planeToPlane'. 
    switch (param.algorithm.SubSample)
        case 'Random'
            pcDownSample= pcdownsample(pcAux,'random',param.val.DownSampleAtual); 
        case 'gridAverage'
            pcDownSample= pcdownsample(pcAux, 'gridAverage',param.val.DownSampleAtual);
        case 'nonUniformGrid'
            pcDownSample= pcdownsample(pcAux, 'nonuniformGridSample',param.val.DownSampleAtual);
        otherwise 
            warning('Escolha um dos três algoritmos de subamostragem.');
    end
   
   % Calcula a tranformação de corpo rígido, podem ser usados 3 tipos de
   % algoritmos, ICP, CPD e NDT  
   switch (param.algorithm.Reg)
        case 'ICP'
            tformAux = pcregistericp(pcDownSample, pcDownSampleRef, 'Metric', param.val.registerMetric, 'Extrapolate', true); 
        case 'CPD'
            tformAux = pcregistercpd(pcDownSample, pcDownSampleRef); 
        case 'NDT'
            tformAux = pcregisterndt(pcDownSample, pcDownSampleRef);
        otherwise 
            warning('Escolha um dos três algoritmos de registro: ICP, CPD ou NDT.');
    end
   
   % Acumula a transformação a cada iteração. 
   tformAccum = affine3d(tformAux.T * tformAccum.T);
   
   % Executa o registro, alinhamento das PCs.
   pcAligned = pctransform(pcAux, tformAccum);
   
   % Faz a fusão das PC a cada iteração.
   pcFull = pcmerge(pcFull, pcAligned, param.val.mergeSize);
   
   % Armazena o PC atual na variável "pcDownSampleRef" para a próxima
   % iteração.
   pcDownSampleRef= pcDownSample;
   
   % Guarda algumas variáveis para análise posterior:
   tform{ctPC-1}= tformAux; 
   translation(ctPC-1,:)= tformAux.Translation(1,:);
   
   % Exibe o resultado do registro das PCs a cada iteração
   if (param.show.PCReg)
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