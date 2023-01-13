
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% Código usado para ajustar um plano a nuvem dep ontos gerada pelo LiDRA
% e também calcular a distãncia de cada pónto desta nuvem ao plano teórico 
% ajustado, desta forma é possível calcular o erro de planeza da nuvem de 
% pontos obtida com o Velodyne Puck Lite.
% Experimento executado com o LiDRA e o laser interferométrico no
% laboratório do CERTI.
% Neste código são usados conceitos de Geometria Analítica, extraidos do
% livro "Geometria Analítica", Autor: Alfredo Steinbruch & Paulo Winterle.
% Data do experimento: 25/11/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAjustaPlanoPC(handles)
clc;
close all;

% Se o flag "enableSimulation" estiver ativado, será efetuada uma análise 
% do princípio teórico da geometria alanítica aplicada através da função 
% ajuste de plano.
% Caso esteja desativado será efetuada uma análise das nuvens de pontos 
% geradas pelo LiDAR.
if (~handles.enableSimulation)
    % Carrega nuvem de pontos gerada pelo LiDAR:
    pc= pcread(handles.pathPC);
    
    % Testa a PC para verificar se há mais de 1 canal, se houver a análise
    % não será efetuada. Posteriormente poderá ser implementada um código
    % para testar os 16 canais do LiDAR:
    aux= size(pc.Location);
    numCol= length(aux);
    
    % Se numCol for menor que 2 significa que todos os 16 canais estao 
    % representados em um único canal. Caso contrário a PC está separada em
    % 16 canais no formato 16xNxM, este formato não será analisado. Pois ao
    % fazer o merge das PCS, o matlab perde as informaçoes dos canais.
    if (numCol<3) 
        % Filtra o ruído da nuvem de pontos de referência.
        pcDenoised = pcdenoise(pc);   

        % Ajusta um plano entre a nuvem de pontos:
        % O parâmetro "handles.maxDistance" cotpem o valor da máxima distância
        % entre um ponto "inlier" e o plano ajustado. Neste projeto a unidade 
        % é definida em metros. Pontos com distâncias maiores que a
        % definida neste parâmetro não serão usados no ajuste do plano.
        [plane, inlierIndices, outlierIndices, error]= pcfitplane(pc, handles.maxDistance);
        pcPlane= select(pc, inlierIndices);
        remainPtCloud= select(pc, outlierIndices);

        % Chama a função para determinar a distância de cada ponto da PC ao
        % plano ajustado, determinando o erro de planeza da PC gerada pelo LiDAR
        % Esta função retorna:
        % - P= Ponto onde a reta "r" que conecta um ponto da PC ao plano ajustado.
        % - vet= vetor normal ao plano colinear a reta "r".
        % - d= norma do vetor "vet", ou seja, distânica absoluta.
        % - dp= desvio padrão de todas as disTañcia entre cada ponto da PC e o plano.
        [pontoNoPlano vetorN rangePontoPlano media dp]= fCalculaDistanciaPontoPlano(plane, pcPlane); %pc);

        % Chama função para exibir os resultados:
      %  fShowAnaliseAjustePlano(pc, pcPlane, plane, pontoNoPlano, vetorN, rangePontoPlano, media, dp, handles.maxDistance, handles.numBins);
        fShowAnaliseAjustePlano(pc, pcPlane, plane, pontoNoPlano, vetorN, rangePontoPlano, media, dp, handles);
    else
        msg= sprintf('Erro!!!Numero de canais da PC imcompatível!! Escolha outra PC.');
        msgbox(msg);
    end
else
    % Efetua a simulação de uma nuvem de pontos e de um plano.
   fSimulaAjustePlano(handles);    
end
end
