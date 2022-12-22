
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
% Flag simulaPlano usado para verificar se as equa��es do plano e
% princ�pios te�ricos est�o ok. Se este flag estiver desativado, ser�
% efetuada a an�lise das nuvend de pontos geradas pelo LiDAR.

if (~handles.enableSimulation)
    % Carrega nuvem de pontos gerada pelo LiDAR:
    pc= pcread(handles.pathFull);
    
    % Testa a PC para verificar se h� mais de 1 canal, se houver a an�lise
    % n�o ser� efetuada. Posteriormente poder� ser implementada um c�digo
    % para testar os 16 canais do LiDAR:
    aux= size(pc.Location);
    numCol= length(aux);
    
    if (numCol<3) % Significa que todos os 16 canais estao rpresentados em um �nico canal.
        % Filtra o ru�do da nuvem de pontos de refer�ncia.
        pcDenoised = pcdenoise(pc);   

        % Ajusta um plano entre a nuvem de pontos:
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
        [P vet range M dp]= fCalculaDistanciaPontoPlano(plane, pc); %pcPlane);

        % Exibe os resultados:
        figure(1);
        subplot(2,2,1);
        pcshow(pc);
        subplot(2,2,2);
        pcshow(pcPlane);
        subplot(2,2,[3 4]);
        pcshow(pc);
        hold on;
        plot(plane,'Color',[0 1 0]);

        figure(2);
        pcshow(pcPlane, 'MarkerSize', 18);
        hold on;
        title('PCs ');
        xlabel('X (m)');
        ylabel('Y (m)');
        zlabel('Z (m)');
        handle.WindowState='maximized';

        % Plota o plano
        plot(plane,'Color',[0 1 0]);

        % Plotta os pontos da reta que interceptam o plano
        plot3(P(:,1),P(:,2),P(:,3),'*b');

        % Exibe os vetores colineares a reta e normais ao plano.
        quiver3(P(:,1),P(:,2),P(:,3),vet(:,1), vet(:,2),vet(:,3),'off','r');

        % Plota o histograma com o erro m�dio e desvio padr�o 
        figure;
        h= histogram(range,25);
        msg= sprintf('Histograma distancia pontos PC-plano. M�dia= %0.4fm  DP= %0.4fm', M,dp);
        title(msg);
    else
        msg= sprintF('Erro!!!Numero de canais da PC imcompat�vel!! Escolha outra PC.');
        msgbox(msg);
    end
else
    % Efetua a simula��o de uma nuvem de pontos e de um plano.
   fSimulaAjustePlano(handles);    
end
end
