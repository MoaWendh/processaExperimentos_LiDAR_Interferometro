%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código para efetuar a análise dos resultados dos registros da PCs referente
% ao experimento 01 do LiDAR com Interferômetro.
% Data do experimento: 25/11/2022
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vetorTransLiDAR deslocamentoInterferometro erro]= fAnalisaDados(tform, medicoes, pcFull, handles)

for (ct=1:(handles.val.numFolders-1))
    % Converte os valores em mm:
    vetorTransLiDAR(ct,:)= tform{ct}.Translation*1000;
    
    % Calcula o módulo do vetor diferença das translações. Se for zero
    % a translação da transformação de corpo rigido foi ideal:
    normDiffVetorTransl(ct)= norm(vetorTransLiDAR(ct,:));
    
    % Determina o deslocamento medido pelo interferômetro para cada
    % posição:
    deslocamentoInterferometro(ct)= medicoes.interferometro_exp_01(ct+1) - medicoes.interferometro_exp_01(ct); 
    
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

end