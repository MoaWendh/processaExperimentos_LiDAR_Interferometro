function fShowAnaliseAjustePlano(pc, pcPlane, plane, P, vet, range, M, dp, handles)

% Exibe os resultados:
f1= figure;
subplot(2,2,1);
pcshow(pc);
msg= sprintf('PC original (%d pontos)',length(pc.Location));
title(msg);

subplot(2,2,2);
pcshow(pcPlane);
msg= sprintf('PC ajustada ao plano (%d pontos - Dist. max= %0.2f m)', length(pcPlane.Location), handles.maxDistance);
title(msg);

subplot(2,2,[3 4]);
pcshow(pcPlane, 'MarkerSize', 18);
hold on;
plot(plane,'Color',[0 1 0]);
% Plota os pontos da reta que interceptam o plano
plot3(P(:,1),P(:,2),P(:,3),'*b');
% Exibe os vetores colineares as reta normais ao plano.
quiver3(P(:,1),P(:,2),P(:,3),vet(:,1), vet(:,2),vet(:,3),'off','r');
msg= sprintf('Plano ajustado à PC com vetores normais (%d pontos)', length(pcPlane.Location));
title(msg);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

f1.Resize= 'on';
%f1.WindowState= 'maximized';
f1.Position= [10 50 1600 1000];

% Plota o histograma com o erro médio e desvio padrão 
f2=figure;

h= histogram(range, handles.numBins);
msg= sprintf('Histograma - distâncias pontos-plano (Média= %0.4fm - DP= %0.4fm)', M,dp);
title(msg);
f2.Resize= 'on';
%f1.WindowState= 'maximized';
f2.Position= [1630 50 900 1000];


% Verifica se o folder onde serão salvas as figuras existe, caso contrário 
% o folder será criado:
if ~(isfolder(handles.pathSave))
    mkdir(handles.pathSave);
end

% Salva as figuras com os resultados da análise:
fullPath= fullfile(handles.pathSave, 'planoajustado.fig');
savefig(f1,fullPath);

fullPath= fullfile(handles.pathSave, 'histograma.fig');
savefig(f2,fullPath);

end