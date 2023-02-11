%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código para efetuar a análise dos resultados dos registros da PCs referente
% ao experimento 01 do LiDAR com Interferômetro.
% Data do experimento: 25/11/2022
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAnalisaRegistros(handles)

close all;

% carrega os dados de referência obtidos nas medições feitas diretamente 
% no interferômetro. Esses dados podem ser lidos de um arquivo *.dat:
pathDadosReferencia= sprintf('%s%s', handles.path.DataFile, handles.name.referenceDataFile);
DadosReferencia= load(pathDadosReferencia);

for (i=1:handles.val.numVariacaoGridSize)
        
    for (ct=1:(handles.numFoldersValidos-1))
        % Converte os valores em mm:
        vetorTransLiDAR(ct,:)= handles.tform{i, ct}.Translation*1000;

        % Calcula o módulo do vetor diferença das translações. Se for zero
        % a translação da transformação de corpo rigido foi ideal:
        normDiffVetorTransl(ct)= norm(vetorTransLiDAR(ct,:));

        % Determina o deslocamento medido pelo interferômetro para cada posição:
        deslocamentoInterferometro(ct)= DadosReferencia.interferometro_exp_01(ct+1) - DadosReferencia.interferometro_exp_01(ct); 

        % Calcula o deslocamento integral do LiDAR ao longo do eixo X:
        if (ct==1)
            integraPosLiDAR_EixoX(ct)= vetorTransLiDAR(1);
        else
            integraPosLiDAR_EixoX(ct)= integraPosLiDAR_EixoX(ct-1) + vetorTransLiDAR(ct,1);
        end
    end

    %dataA= normDiffVetorTransl(1,:);
    transLidarX= vetorTransLiDAR(:,1)';
    transInterfX= deslocamentoInterferometro;
    erro.X= (transInterfX - transLidarX);

    % Calcula o erro médio:
    erro.XMedio= mean(erro.X);
    erro.DP= std(erro.X);
    erro.Max= max(erro.X);
    erro.Min= min(erro.X);
    
    % Exibe os resultados:
    if (handles.show.resultAnalise)
        fExibeDados(vetorTransLiDAR, deslocamentoInterferometro, erro, handles.pcFull{i}, handles);
    end
    erroXMedio(i)= erro.XMedio;
    DP(i)= erro.DP;
    erroMax(i)= erro.Max;
    erroMin(i)= erro.Min;
    num(i)= i; 
    fprintf(' %d= %2.4f\n',i, handles.val.DownSample(i));
    
end
% Montam tabela com os resultados:
vals= handles.val.DownSample(1:i);
t=table(num', vals', erroXMedio', DP', erroMax', erroMin');
t.Properties.VariableNames = {'num', 'gridZise', 'erroMedio', 'DP', 'erroMax', 'erroMin'};
%%
f6= uifigure('Position',[100, 100, 720, 110]);
f6.HandleVisibility= 'on';
uit = uitable(f6);
uit.Position = [10 10 700 100];
uit.Data= t;

% Mensagem de finalização.
msg= msgbox(' Análise dos registro das nuvens de pontos foi concluída.', 'Concluido!');
uiwait(msg);

end