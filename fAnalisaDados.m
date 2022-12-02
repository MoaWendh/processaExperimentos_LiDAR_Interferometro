%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código para efetuar a análise dos rsultados dos registros da PCs referente
% ao experimento 01 do LiDAR com Interferômetro.
% Data do experimento: 25/11/2022
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fAnalisaDados(tform, medicoes, param)


for (ct=1:(param.numFolders-1))
    % Converte os valores em mm:
    vetorTransl(ct,:)= tform{ct}.Translation*1000;
    
    % Calcula o módulo do vetor diferença das translações. Se for zero
    % a translação da transformação de corpo rigido foi ideal:
    normDiffVetorTransl(ct)= norm(vetorTransl(ct,:));
    
    % Determina o deslocamento medido pelo interferômetro para cada
    % posição:
    posInterferometro(ct)= medicoes.interferometro_exp_01(ct+1) - medicoes.interferometro_exp_01(ct); 
    
    % Calcula o deslocamento integral do LiDAR ao longo do eixo X:
    if (ct==1)
        integraPosLiDAR_EixoX(ct)= vetorTransl(1);
    else
        integraPosLiDAR_EixoX(ct)= integraPosLiDAR_EixoX(ct-1) + vetorTransl(ct,1);
    end
end


dataA= normDiffVetorTransl(1,:); 
dataB= posInterferometro;
erroX= (posInterferometro - normDiffVetorTransl(1,:))

figure;
% Calcula o erro médio:
erroMedio= mean(erroX);
DP= std(erroX);
erroMax= max(erroX);
erroMin= min(erroX);

% Top bar graph
ax1 = nexttile;
bar(ax1,dataA,'g');
ax1.XLabel.String='Passo LiDAR';
ax1.YLabel.String='Valor passo (mm)';

% Bottom bar graph
ax2 = nexttile;
bar(ax2,dataB,'b')
ax2.XLabel.String='Passo Interferômetro';
ax2.YLabel.String='Valor passo (mm)';

% Bottom bar graph
ax3 = nexttile;
bar(ax3,erroX,'r')
ax3.XLabel.String='Erro: LiDAR X interferômetro';
ax3.YLabel.String='Erro passo (mm)';
texto= ['Erro Médio= ',num2str(erroMedio),'mm' ,'    DP= ', num2str(DP), 'mm']
title(ax3,texto,'Color','r')

% Bottom bar graph
ax4 = nexttile;
bar(ax4,vetorTransl)
ax4.XLabel.String='Passos do LiDAR nos eixos X, Y e Z';
ax4.YLabel.String='Valor passo (mm)';

% Analisa desempenho do LiDAR com relação ao eixo "X"
figure;
subplot(2,2,1);
a=bar(vetorTransl);
xlabel('num PC');
ylabel('mm');
title('Deslocamento do LiDAR: Eixos X, Y e Z pelo Algoritmo Matlab');

subplot(2,2,2);
dataX= [normDiffVetorTransl(1,:); posInterferometro];
b=bar(dataX);
xlabel('num PC');
ylabel('mm');
title('Deslocamento: Registro PC x Interferêmetro');

subplot(2,2,3);
erroX= (posInterferometro - normDiffVetorTransl(1,:));
c=bar(erroX);
xlabel('num PC');
ylabel('mm');
title('Erro do deslocamento do LiDAR com relação ao Interferômetro - eixo X ');

subplot(2,2,4);
plot(medicoesInterferometro_exp_01(1:14), integraPosLiDAR_EixoX,'-b');



% Analisa desempenho do LiDAR com relação ao eixo "Y"
maxVal=-999;
minVal= 999;
zeroXYZ= [0 0 0];
figure;
for (ct=1:length(diffVetorTransl))  
    if (max(diffVetorTransl(ct,:)) > maxVal)
        maxVal= max(diffVetorTransl(ct,:));
    end
    if (min(diffVetorTransl(ct,:)) < minVal)
        minVal= min(diffVetorTransl(ct,:));
    end
    
    quiver3(zeroXYZ(1),zeroXYZ(2),zeroXYZ(3),diffVetorTransl(ct,1),diffVetorTransl(ct,2),diffVetorTransl(ct,3));
    hold on;
end

xlim([minVal maxVal]);
ylim([minVal maxVal]);
zlim([minVal maxVal]);

xlim([-maxVal maxVal]);
ylim([-maxVal maxVal]);
zlim([-maxVal maxVal]);

end