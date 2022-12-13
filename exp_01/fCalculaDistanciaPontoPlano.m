%**************************************************************************
% Autor: Moacir Wendhausen
% Data: 08/12/2022
% Função: calcula distãncia de cada ponto da PC ao plano ajustada.
% Parãmetros de entrada: Equação do plano e a PC.
%**************************************************************************

function [pontoPlano vetorNormal rangePlaneP M dp]= fCalculaDistanciaPontoPlano(paramsPlane, pc)
 
% Primeiroa definir a equação paramétrica do Plano, que é definida por:
%¨aX + bY + cZ + d =0;
% Os parâmetro (a,b,c) são as coordenadas do vetor normal ao plano.
a= paramsPlane.Parameters(1);
b= paramsPlane.Parameters(2);
c= paramsPlane.Parameters(3);
d= paramsPlane.Parameters(4);

% n é o vetor normal ao plano.
n=[a b c];

% Determinar a reta que passa pelo ponto da PC e é normal ao plano.
% Uma reta "r" fica perfeitmante definida conhecendo-se: um ponto Pk(px, py, pz)
% pertecente a "r" e um vetor v(vx, vy, vz) colinear a reta "r". Este vetor "v"
% tem que ser colinear a o vetor normal n.% Assim, a equação vetorial da reta 
% é dada por P(x,y,z)= Pk(px,py,pz) + tn(vx,vy,vz).
% 1º- Determinar o parâmetro "t".
% 2º- Determinar a equação paramétrica da reta.

for (i=1:length(pc.Location))
    % Pegar um ponto da PC para determinar a reta:
    pontoReta(i,:)= pc.Location(i,:);
    
    % Calcular o parâmetro "t" da equação paramétrica da reta. Para a reta
    % o ponto "t" pertencer ao p plano ele deve satisfazer a equação do plano.
    t= -(n(1)*pontoReta(i,1) + n(2)*pontoReta(i,2) +n(3)*pontoReta(i,3) +d)/((n(1)^2) + (n(2)^2) + (n(3)^2));
    
    % Substituindo-se o parâmetro "t" na equação da reta obtem-se o ponto 
    % da reta, chamado "Pplano", que toca o plano, ele é dado por:
    pontoPlano(i,:)= pontoReta(i,:) + t*n;
    
    % O vetor do ponto P do plano ao ponto Pk é dado por:
    vetorNormal(i,:)= pontoReta(i,:) - pontoPlano(i,:);
    
    % A distância do ponto Pk ao plano é dada pela norma do vetor P.
    % O teste abaixo é feito para facilitar a análise de erro, pois a norma
    % de um vetor tanto antes quato depois do plano são semrpe positivas.
    % Para facilictar a análise atribui-se que o vetor dpois do plano tem
    % uma distãncia negativa com relação ao plano.
    if ( norm(pontoPlano(i,:))> norm(pontoReta(i,:)) )
        % Significa que o ponto da PC está depois do plano.
        rangePlaneP(i)= - norm(vetorNormal(i,:));
    else
        % Significa que o ponto da PC está antes do plano.
        rangePlaneP(i)= norm(vetorNormal(i,:));
    end    
end
M= mean(rangePlaneP(i));
dp= std(rangePlaneP);

