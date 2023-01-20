%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Moacir Wendhausen
% Data: 08/12/2022
% Filtra nuvem de pontos considerando a distância euclidiana entre o LiDAR
% e ponto medido, ou seja, a norma do ponto XYZ.
% Os parâmetros de entrada, Threshold, são distância mínima e máxima do LiDAR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pcThresholded handles]= fPcFiltraDistancia(pc, handles, ctCanal, pcCompleta)

close all;
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

% Testa se foi detectado algum ponto segmentado, caso contrário informar
% que não foi possível segmentar o canal. Se ao final da iteração acima
% ct=0, significa qua não ocorreu segmentação, nenhum ponto correspondeu
% aos parãmetros de segmentação
if (ct>0)
    pcThresholded= pointCloud(location, 'Intensity', intensity);
    msg=sprintf('Segmetnando canal-> %d', ctCanal);
    handles.staticShowStatusSegmenta.String= msg;
else
    pcThresholded= 0;
    handles.errorSegCn(ctCanal)= 1;
end
