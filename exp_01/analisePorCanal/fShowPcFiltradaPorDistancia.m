function fShowPcFiltradaPorDistancia(pcOriginal, pcThreshold, handles, ctCanal, pcCompleta)
    
% Cria um novo mapa de cores para os clusters
fig= figure;

% Exibe a nuvem de pontos completa com os 16 canais:
subplot(2,2,1);
pcshow(pcCompleta.Location);
numPontos= length(pcCompleta.Location); 
msg= sprintf('PC completa - 16 Canais e %d pontos', numPontos);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

% Exibe a nuvem de pontos original como o canal separado:
subplot(2,2,3);
pcshow(pcOriginal.Location);
numPontos= length(pcOriginal.Location); 
msg= sprintf('PC original - Canal %d com %d pontos', handles.cnSegmenta(ctCanal), numPontos);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

subplot(2,2,[2 4]);
pcshow(pcThreshold.Location);
numPontos= length(pcThreshold.Location); 
msg= sprintf('PC Segmentada - Canal %d com %d pontos - Threshold: Min= %0.2fm e Max= %0.2fm', handles.cnSegmenta(ctCanal), numPontos, handles.valThresholdMinDistance, handles.valThresholdMaxDistance);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
fig.Position= [10, 40, 1600, 950];

fig.WindowState='maximized'
end