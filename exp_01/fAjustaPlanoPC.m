
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
function fAjustaPlanoPC()
clc;
close all;
clear;

% Flag simulaPlano usado para verificar se as equa��es do plano e
% princ�pios te�ricos est�o ok. Se este flag estiver desativado, ser�
% efetuada a an�lise das nuvend de pontos geradas pelo LiDAR.
simulaPlano= 0;

if (~simulaPlano)
    param.val.maxDistance= 0.01;
    % Carrega nuvem de pontos gerada pelo LiDAR:
    pathToRead='D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01\Pln\0001.pcd';
    pc= pcread(pathToRead);
    % Filtra o ru�do da nuvem de pontos de refer�ncia.
    pcDenoised = pcdenoise(pc);   
    
    % Ajusta um plano entre a nuvem de pontos:
    [plane, inlierIndices, outlierIndices, error]= pcfitplane(pc, param.val.maxDistance);
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
    % Simula um plano onde o vetor normal "n" � dado pelas coordenadas
    % (a,b,c). O ponto "A" pertencente ao palno tamb� pe dado por (xA,Ya,Za),
    % possibilitando calcular o par�metro "d".
    % Defini��o dos coeficientes do vetor normal ao plano, n:
    a= 1;
    b= 1;
    c= 0;
    n= [a b c];
    
    % Defini��o das coordenadas do ponto "A" pertencete ao plano
    xA= 5;
    yA= 5;
    zA= 5;   
    A= [xA yA zA];
    
    % Equa��o do plano -> a*x + b*y + c*z + d= 0" ou -> dot(A,n) + d= 0.
    % Logo, d= -(a*x + b*y + c*z):
    d= -dot(A,n);
    
    % Equa��o param�trica do plano do plano:
    paramEq= [a b c d];
    
    % Define um modelo de plano conforme o Matlab:
    plane= planeModel(paramEq);
        
    % Gera uma PC para testar o princ�pio.
    % Gera pontos com as cordenadas X, Y e Z com a fun��o randi do Matlab:
    numPoints=1000;
    iniRand= 0;  
    fimRand= 10;
    pcXBefore= randi([iniRand fimRand], 1, numPoints);
    pcYBefore= randi([iniRand fimRand], 1, numPoints);
    pcZBefore= randi([iniRand fimRand], 1, numPoints);
    
    pcXAfter= randi([iniRand fimRand], 1, numPoints); 
    pcYAfter= randi([iniRand fimRand], 1, numPoints); 
    pcZAfter= randi([iniRand fimRand], 1, numPoints);
    
    pcX=[pcXBefore, pcXAfter]; 
    pcY=[pcYBefore, pcYAfter];
    pcZ=[pcZBefore, pcZAfter];
    
    % Concatena as coordenadas numa �nica nuvem de pontos: 
    pc(:,1)= pcX';
    pc(:,2)= pcY';
    pc(:,3)= pcZ';
    
    % Coverte a nuvem de pontos com a fun��o pointCloud() do Matlab:
    pc= pointCloud(pc);
    
    % Chama a fun��o para calular a dist�ncia dos pontos da PC ao plano simulado:
    [P vet range M dp]= fCalculaDistanciaPontoPlano(plane, pc);
    
    % Exibe os resultados:
    % Plota a PC
    handle= figure;
    pcshow(pc, 'MarkerSize', 100);
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
    % Plota os vetores colineares a reta
    quiver3(P(:,1),P(:,2),P(:,3),vet(:,1), vet(:,2),vet(:,3),'off','r');
    
    % Plota o histograma com o erro m�dio e desvio padr�o 
    figure;
    h=histogram(range,26);
    title
end
end
