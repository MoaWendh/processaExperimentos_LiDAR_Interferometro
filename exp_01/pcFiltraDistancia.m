%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/12/2022
% Filtra nuvem de pontos considerando a distância euclidiana entre o LiDAR
% e ponto medido, ou seja, a norma do ponto XYZ.
% Os parâmetros de entrada, Threshold, são distância mínima e máxima do LiDAR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pcThresholded= pcFiltraDistancia(pc, handles)

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
pcThreshold= pointCloud(location, 'Intensity', intensity);
end
