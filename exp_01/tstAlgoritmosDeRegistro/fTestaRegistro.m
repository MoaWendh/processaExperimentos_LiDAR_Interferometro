%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para avaliar o desempenho dos algoritmos de registros  de 
% nuvens de pontos do Matlab.
% Data do experimento: 25/11/2022
% Padrões: pirâmede com esfereas,simulacro riser PVC e plano. 
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fTestaRegistro(handles)
% Carrega os resultados de medição feitas diretamente no interferômetro
% que foram obtidos no experimento realizado no lab. do CERTI:
pathDataInterferomtero= sprintf('%s%s', handles.path.BaseRead, handles.name.FileDataInterferometro);
medicoes= load(pathDataInterferomtero);

% Nesta seção é avaliado o desempenho dos registros considerando a
% variação do "gridSize" usado para subamostrar as PCs.
fprintf(' Testando %d parâmetros para os algoritmos: \n',handles.val.VariacaoGridSize);
fprintf(' - Registro: %s \n', handles.algorithm.Reg);
fprintf(' - Subamostrage: %s\n',handles.algorithm.SubSample);
fprintf('Val. parâm. sub-amostragem: \n ');

% Carrega as PCs originais geradas no experimento:
[pc pcDenoised]= fCarregaPCs(handles);

% Escolhe o parâmetros em função do algoritmo de sub amostragem selecionado anteriormente:
for (i=1:handles.val.VariacaoGridSize)
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

    % Chama a função fRegistraPC para registrar as PCs do experimento.
    % Esta função retorno a transformação de corpo rígido para cada PC gerada.       
    [tform{i} pcFull{i}]= fRegistraPC(pc, pcDenoised, handles); 

    % Efetua a análise do desempenho do registro das PCs
    [vetorTransLiDAR{i} deslocamentoInterferometro{i} erro{i}]= fAnalisaDados(tform{i}, medicoes, pcFull{i}, handles);
    % Exibe o resultado da análise se esta função estiver habilitada:
    if (handles.show.resultAnalise)
        fExibeDados(vetorTransLiDAR{i}, deslocamentoInterferometro{i}, erro{i}, pcFull{i}, handles);
    end
    erroXMedio(i)= erro{i}.XMedio;
    DP(i)= erro{i}.DP;
    erroMax(i)= erro{i}.Max;
    erroMin(i)= erro{i}.Min;
    num(i)= i; 
    fprintf(' %d= %2.4f\n',i, handles.val.DownSample(i));
end

% Montam tabela com os resultados:
t=table(num',handles.val.DownSample',erroXMedio', DP', erroMax',erroMin');
t.Properties.VariableNames = {'num.', 'gridZise', 'erroMedio', 'DP', 'erroMax', 'erroMin'}

% Mensagem de finalização.
msg= msgbox(' Análise de registro das nuvens de pontos concluída. ', 'Concluido!');
uiwait(msg);
end
