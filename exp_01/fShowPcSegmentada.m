function fShowPcSegmentada(pcCluster, pcSegmented, numClusters, labelColorIndex)
    
% Cria um novo mapa de cores para os clusters
colormap(hsv(numClusters));
figure;
% Exibe a nuvem de pontos segmentada inteira:
pcshow(pcSegmented.Location,labelColorIndex);
title(' Full Segmented Point Cloud Clusters ');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
for (ctCluster=1:numClusters)
    figure;
    % Exibe o cluster da nuvem de pontos segemntada:
    pcshow(pcCluster{ctCluster}.Location);
    titulo= sprintf(' Segmented Point Cloud Clusters= %d ',ctCluster);
    title(titulo);
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

end