%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/12/2022
% Filtra nuvem de pontos considerando a distância euclidiana entre o LiDAR
% e ponto medido, ou seja, a norma do ponto XYZ.
% Os parâmetros de entrada, Threshold, são distância mínima e máxima do LiDAR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pcThresholded= fPcFiltraDistancia(pc, handles)

ct= 0;
for (i=1:length(pc.Location))
    distEuclidiana= norm(pc.Location(i,:));
    if (distEuclidiana> handles.valThresholdMinDistance) && ...
                           (distEuclidiana< handles.valThresholdMaxDistance)
        ct= ct+1;
        location(ct,:)= pc.Location(i,:);
        intensity(ct,:)= pc.Intensity(i,:);
    end    
end

if (ct>0)   
    pcThresholded= pointCloud(location, 'Intensity', intensity);
    fShowPcFiltradaPorDistancia(pc, pcThresholded, handles);
else
    msg= sprintf('Não foram detectados pontos com esses parâmetro: \n Verifica os thresholds máx. e mín.');
    figMsg= msgbox(msg);
    uiwait(figMsg);
    pcThresholded.Count= 0;
end
end
