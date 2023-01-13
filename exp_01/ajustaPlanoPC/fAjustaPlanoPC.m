
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/08/2022
% C�digo usado para ajustar um plano a nuvem dep ontos gerada pelo LiDRA
% e tamb�m calcular a dist�ncia de cada p�nto desta nuvem ao plano te�rico 
% ajustado, desta forma � poss�vel calcular o erro de planeza da nuvem de 
% pontos obtida com o Velodyne Puck Lite.
% Experimento executado com o LiDRA e o laser interferom�trico no
% laborat�rio do CERTI.
% Neste c�digo s�o usados conceitos de Geometria Anal�tica, extraidos do
% livro "Geometria Anal�tica", Autor: Alfredo Steinbruch & Paulo Winterle.
% Data do experimento: 25/11/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAjustaPlanoPC(handles)
clc;
close all;

% Se o flag "enableSimulation" estiver ativado, ser� efetuada uma an�lise 
% do princ�pio te�rico da geometria alan�tica aplicada atrav�s da fun��o 
% ajuste de plano.
% Caso esteja desativado ser� efetuada uma an�lise das nuvens de pontos 
% geradas pelo LiDAR.
if (~handles.enableSimulation)
    % Carrega nuvem de pontos gerada pelo LiDAR:
    pc= pcread(handles.pathPC);
    
    % Testa a PC para verificar se h� mais de 1 canal, se houver a an�lise
    % n�o ser� efetuada. Posteriormente poder� ser implementada um c�digo
    % para testar os 16 canais do LiDAR:
    aux= size(pc.Location);
    numCol= length(aux);
    
    % Se numCol for menor que 2 significa que todos os 16 canais estao 
    % representados em um �nico canal. Caso contr�rio a PC est� separada em
    % 16 canais no formato 16xNxM, este formato n�o ser� analisado. Pois ao
    % fazer o merge das PCS, o matlab perde as informa�oes dos canais.
    if (numCol<3) 
        % Filtra o ru�do da nuvem de pontos de refer�ncia.
        pcDenoised = pcdenoise(pc);   

        % Ajusta um plano entre a nuvem de pontos:
        % O par�metro "handles.maxDistance" cotpem o valor da m�xima dist�ncia
        % entre um ponto "inlier" e o plano ajustado. Neste projeto a unidade 
        % � definida em metros. Pontos com dist�ncias maiores que a
        % definida neste par�metro n�o ser�o usados no ajuste do plano.
        [plane, inlierIndices, outlierIndices, error]= pcfitplane(pc, handles.maxDistance);
        pcPlane= select(pc, inlierIndices);
        remainPtCloud= select(pc, outlierIndices);

        % Chama a fun��o para determinar a dist�ncia de cada ponto da PC ao
        % plano ajustado, determinando o erro de planeza da PC gerada pelo LiDAR
        % Esta fun��o retorna:
        % - P= Ponto onde a reta "r" que conecta um ponto da PC ao plano ajustado.
        % - vet= vetor normal ao plano colinear a reta "r".
        % - d= norma do vetor "vet", ou seja, dist�nica absoluta.
        % - dp= desvio padr�o de todas as disTa�cia entre cada ponto da PC e o plano.
        [pontoNoPlano vetorN rangePontoPlano media dp]= fCalculaDistanciaPontoPlano(plane, pcPlane); %pc);

        % Chama fun��o para exibir os resultados:
      %  fShowAnaliseAjustePlano(pc, pcPlane, plane, pontoNoPlano, vetorN, rangePontoPlano, media, dp, handles.maxDistance, handles.numBins);
        fShowAnaliseAjustePlano(pc, pcPlane, plane, pontoNoPlano, vetorN, rangePontoPlano, media, dp, handles);
    else
        msg= sprintf('Erro!!!Numero de canais da PC imcompat�vel!! Escolha outra PC.');
        msgbox(msg);
    end
else
    % Efetua a simula��o de uma nuvem de pontos e de um plano.
   fSimulaAjustePlano(handles);    
end
end
