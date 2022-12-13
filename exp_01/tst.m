clear;
clc;
close all;

ct=0;
for (i=1:100)
    for j=1:100
        for k=1:100
            ct= ct + 1;
            pX(ct)= i;
            pY(ct)= j;
            pZ(ct)= 1;
        end
    end
end

P= [1 5 10]; % Ponto cuja distância ao plano deseja-se descobrir. 
A= [20 10 1]; % Ponto conhecido pertencente ao plano
n= [0 0 1]; % Vetor normal ao plano, também conhecido.

% equação do plano abaixo 0X + 0Y + Z +d=0
%Determinado o valor de d:
d= -(n(1)*A(1) + n(2)*A(2) + n(3)*A(3));

% achando a equação da reta: (x0,y0,z0)= P + t*n
% Obtendo o valor de t

t= - (n(1)*P(1) + n(2)*P(2) +n(3)*P(3) +d)/((n(1)^2) + (n(2)^2) + (n(3)^2));

Q(1)= P(1) + t*n(1);
Q(2)= P(2) + t*n(2);
Q(3)= P(3) + t*n(3);

QP= [P(1)- Q(1) P(2)- Q(2) P(3)- Q(3)];

D= norm(QP);
plot3(P(1),P(2),P(3),'*g');
hold on;
plot3(pX,pY,pZ,'*r');

quiver3(Q(1),Q(2),Q(3),QP(1),QP(2),QP(3),'off');


mw=0;

