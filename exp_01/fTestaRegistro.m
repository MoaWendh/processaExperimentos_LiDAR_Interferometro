%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código usado para avaliar o desempenho dos algoritmos de registros  de 
% nuvens de pontos do Matlab.
% Data do experimento: 25/11/2022
% Padrões: pirâmede com esfereas,simulacro riser PVC e plano. 
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fTestaRegistro(param)
% Carrega os resultados de medição feitas diretamente no interferômetro
% que foram obtidos no experimento realizado no lab. do CERTI:
pathDataInterferomtero= sprintf('%s%s', param.path.BaseRead, param.name.FileDataInterferometro);
medicoes= load(pathDataInterferomtero);

if (param.hab.TesteRegistro)
    % Nesta seção é avaliado o desempenho dos registros considerando a
    % variação do "gridSize" usado para subamostrar as PCs.
    fprintf(' Testando %d parâmetros para os algoritmos: \n',param.val.VariacaoGridSize);
    fprintf(' - Registro: %s \n', param.algorithm.Reg)
    fprintf(' - Subamostrage: %s\n',param.algorithm.SubSample);
    fprintf('Val. parâm. sub-amostragem: \n ');
    
    % Carrega as PCs originais geradas no experimento:
    [pc pcDenoised]= fCarregaPCs(param);
    
    % Escolhe o parâmetros em função do algoritmo de sub amostragem
    % selecionado anteriormente:
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
