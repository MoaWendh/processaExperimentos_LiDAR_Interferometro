function fSimulaAjustePlano(handles)

% Simula um plano onde o vetor normal "n" é dado pelas coordenadas
% (a,b,c). O ponto "A" pertencente ao palno també pe dado por (xA,Ya,Za),
% possibilitando calcular o parâmetro "d".
% Definição dos coeficientes do vetor normal ao plano, n:
n= handles.vetorNormal;

% Definição das coordenadas do ponto "A" pertencete ao plano
A= handles.pontoNoPlano;

% Equação do plano -> a*x + b*y + c*z + d= 0" ou -> dot(A,n) + d= 0.
% Logo, d= -(a*x + b*y + c*z):
d= -dot(A,n);

% Equação paramétrica do plano do plano:
paramEq= [n(1) n(2) n(3) d];

% Define um modelo de plano conforme o Matlab:
plane= planeModel(paramEq);

% Gera uma PC para testar o princípio.
% Gera pontos com as cordenadas X, Y e Z com a função randi do Matlab:
numPoints= handles.numPointsSim;
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

% Concatena as coordenadas numa única nuvem de pontos: 
pc(:,1)= pcX';
pc(:,2)= pcY';
pc(:,3)= pcZ';

% Coverte a nuvem de pontos com a função pointCloud() do Matlab:
pc= pointCloud(pc);

% Chama a função para calular a distância dos pontos da PC ao plano simulado:
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

% Plota o histograma com o erro médio e desvio padrão 
figure;
h=histogram(range,26);

end