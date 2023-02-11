function fShowPcFiltradaPorDistancia(pcOriginal, pcThreshold, handles)
    
% Cria um novo mapa de cores para os clusters
fig= figure;

% Exibe a nuvem de pontos segmentada inteira:
subplot(1,2,1);
pcshow(pcOriginal.Location);
numPontos= length(pcOriginal.Location); 
msg= sprintf('PC original com %d pontos', numPontos);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

subplot(1,2,2);
pcshow(pcThreshold.Location);
numPontos= length(pcThreshold.Location); 
msg= sprintf('PC com %d pontos foi filtrada usando threshold: Min= %0.2fm e Max= %0.2fm', numPontos, handles.valThresholdMinDistance, handles.valThresholdMaxDistance);
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
fig.Position= [10, 50, 1500, 700];

end