function fShowAnaliseAjustePlano(pc, pcPlane, plane, P, vet, M, dp)

% Exibe os resultados:
figure(1);
subplot(2,2,1);
pcshow(pc);
subplot(2,2,2);
pcshow(pcPlane);
subplot(2,2,[3 4]);
pcshow(pc);
hold on;
plot(plane,'Color',[0 1 0]);

figure(2);
pcshow(pcPlane, 'MarkerSize', 18);
hold on;
title('PCs ');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
handle.WindowState='maximized';

% Plota o plano
plot(plane,'Color',[0 1 0]);

% Plota os pontos da reta que interceptam o plano
plot3(P(:,1),P(:,2),P(:,3),'*b');

% Exibe os vetores colineares a reta e normais ao plano.
quiver3(P(:,1),P(:,2),P(:,3),vet(:,1), vet(:,2),vet(:,3),'off','r');

% Plota o histograma com o erro médio e desvio padrão 
figure;
h= histogram(range,25);
msg= sprintf('Histograma distancia pontos PC-plano. Média= %0.4fm  DP= %0.4fm', M,dp);
title(msg);

end