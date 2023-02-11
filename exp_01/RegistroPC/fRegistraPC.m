%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para abrir e registra as nuven de pontos do experimento
% feito no lab do CERTI.
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles= fRegistraPC(handles)

if (handles.multiplosFolders)
    % Escolhe o parâmetros em função do algoritmo de sub amostragem selecionado anteriormente:
    for (i=1:handles.val.numVariacaoGridSize)
        switch (handles.algorithm.SubSample)
            case 'Random'
                handles.val.DownSample(i)= (i/100)*handles.val.DownSampleIni;
            case 'gridAverage'
                handles.val.DownSample(i)= i*handles.val.DownSampleIni;
            case 'nonUniformGrid'
                handles.val.DownSample(i)= handles.val.DownSampleIni + i;
            otherwise 
                warning('Escolha um dos três algoritmos de subamostragem.');
        end
        handles.val.DownSampleAtual= handles.val.DownSample(i);

        % Toma a primeira PC como referência.
        handles.pcAligned{i,1}= handles.pc{1,1}; 

        % Define a primeira pcFull com a pc de referênica.
        pcFull= handles.pcAligned{i,1};

        % Faz uma sub-amostragem na PC, este procedimento melhora o desempenho
        % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
        % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
        % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
        % 'planeToPlane'. 

        switch (handles.algorithm.SubSample)
            case 'Random'
                pcDownSampleRef= pcdownsample(handles.pcAligned{i,1},'random',handles.val.DownSampleAtual); 
            case 'gridAverage'
                pcDownSampleRef= pcdownsample(handles.pcAligned{i,1}, 'gridAverage', handles.val.DownSampleAtual);
            case 'nonUniformGrid'
                pcDownSampleRef= pcdownsample(handles.pcAligned{i,1}, 'nonuniformGridSample',handles.val.DownSampleAtual);
            otherwise 
                warning('Unexpected plot type. No plot created.');
        end

        % Cria uma transformação neutra:
        tformAccum= affine3d;

        % Faz uma varredura em todas as PCS para efetuar os registros
        for (ctPC=2:length(handles.pc))
           pcAux= handles.pc{ctPC,1};

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
           handles.pcAligned{i,ctPC}= pctransform(pcAux, tformAccum);

           % Faz a fusão das PCs a cada iteração.
           pcFull= pcmerge(pcFull, handles.pcAligned{i,ctPC}, handles.val.mergeSize);

           % Armazena o PC atual na variável "pcDownSampleRef" para a próxima
           % iteração.
           pcDownSampleRef= pcDownSample;

           % Guarda algumas variáveis para análise posterior:
           handles.tform{i,ctPC-1}= tformAux; 
           translation(ctPC-1,:)= tformAux.Translation(1,:);

           % Exibe o resultado do registro das PCs a cada iteração
           if (handles.show.PCReg)
               handle= figure;
               pcshow(pcFull);
               title('PCs concatenadas');
               xlabel('X (m)');
               ylabel('Y (m)');
               zlabel('Z (m)');
               handle.WindowState='maximized';
               msg= msgbox(' Click OK para continuar. ', 'Registro!');
               uiwait(msg);
               close all;
           end 
        end
        % Para cada iteração do algoritmo será registrada uma pcFull: 
        handles.pcFull{i}= pcFull;
    end
    
    % Exibe mensagem:
    msg= sprintf(' Registro de %d PCs com %d variações do Grid Size para cada registro.', ... 
                   handles.numPCsValidas, handles.val.numVariacaoGridSize);
    handles.editMsgs.String= msg; 
else
       
    % Efetua o resgistro sem variação do grid Size.
    
    handles.val.DownSample= handles.val.DownSampleIni;

    % Toma a primeira PC como referência.
    handles.pcAligned{1}= handles.pc{1}; 

    % Define a primeira pcFull com a pc de referênica.
    handles.pcFull{1}= handles.pcAligned{1};

    % Faz uma sub-amostragem na PC, este procedimento melhora o desempenho
    % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
    % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
    % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
    % 'planeToPlane'. 

    switch (handles.algorithm.SubSample)
        case 'Random'
            pcDownSampleRef= pcdownsample(handles.pcAligned{1},'random',handles.val.DownSample); 
        case 'gridAverage'
            pcDownSampleRef= pcdownsample(handles.pcAligned{1}, 'gridAverage', handles.val.DownSample);
        case 'nonUniformGrid'
            pcDownSampleRef= pcdownsample(handles.pcAligned{1}, 'nonuniformGridSample',handles.val.DownSample);
        otherwise 
            warning('Unexpected plot type. No plot created.');
    end

    % Cria uma transformação neutra:
    tformAccum= affine3d;

    % Faz uma varredura em todas as PCS para efetuar os registros
    for (ctPC=2:length(handles.pc))
       pcAux= handles.pc{ctPC};

       % Faz uma sub-amostragem no PC, este procedimento melhora o desempenho
       % da função pcregistericp(). Usando o 'gridAverage' com oparâmetro 
       % 'gridSize' define a aresta de um cubo 3D, em metros. O 'gridAverage' 
       % pode ser adotado em métricas para registro tanto 'pointToPlane' quanto
       % 'planeToPlane'. 
        switch (handles.algorithm.SubSample)
            case 'Random'
                pcDownSample= pcdownsample(pcAux,'random',handles.val.DownSample); 
            case 'gridAverage'
                pcDownSample= pcdownsample(pcAux, 'gridAverage',handles.val.DownSample);
            case 'nonUniformGrid'
                pcDownSample= pcdownsample(pcAux, 'nonuniformGridSample',handles.val.DownSample);
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
       handles.pcAligned{ctPC}= pctransform(pcAux, tformAccum);

       % Faz a fusão das PCs a cada iteração.
       handles.pcFull{1}= pcmerge(handles.pcFull{1}, handles.pcAligned{ctPC}, handles.val.mergeSize);

       % Armazena o PC atual na variável "pcDownSampleRef" para a próxima
       % iteração.
       pcDownSampleRef= pcDownSample;

       % Guarda algumas variáveis para análise posterior:
       handles.tform{ctPC-1}= tformAux; 
       translation(ctPC-1,:)= tformAux.Translation(1,:);

       % Exibe o resultado do registro das PCs a cada iteração
       if (handles.show.PCReg)
           handle= figure;
           pcshow(handles.pcFull{1});
           title('PCs concatenadas');
           xlabel('X (m)');
           ylabel('Y (m)');
           zlabel('Z (m)');
           handle.WindowState='maximized';
           msg= sprintf(' Registro da PC nº %d \n Click OK para exibir o próximo registro. ', ctPC);
           retMsg= msgbox(msg, "");
           uiwait(retMsg);
           close all;
       end 
    end   
end

handles.registroFinalizado= 1;

% Mensagem de finalização.
msg= sprintf('Foram registradas %d PCs.', ctPC);
retMsg= msgbox(msg, "");
uiwait(retMsg);
end


