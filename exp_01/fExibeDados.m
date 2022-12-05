%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moacir Wendhausen
% 26/11/2022
% Código para exibir os resultados da análise dos dados do experimento
% Data do experimento: 25/11/2022
% Instrumentos: LiDAR PuckLite + Interferômetro.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  fExibeDados(vetorTransLiDAR, deslocamentoInterferometro, erro, pcFull, param)

transLidarX= vetorTransLiDAR(:,1)';
transInterfX= deslocamentoInterferometro;

f1=figure;
f1.Position=[50,100,1200,900];

% Calcula o erro médio:
erro.XMedio= mean(erro.X);
erro.DP= std(erro.X);
erro.Max= max(erro.X);
erro.Min= min(erro.X);

% Top bar graph
ax1 = nexttile;
bar(ax1,transLidarX,'g');
ax1.XLabel.String='Passo LiDAR eixo X';
ax1.YLabel.String='Valor passo (mm)';
texto= ['Deslocamento LiDAR - Eixo X (mm)'];
title(ax1,texto,'Color','k');

% Bottom bar graph
ax2 = nexttile;
bar(ax2,transInterfX,'b');
ax2.XLabel.String='Passo Interferômetro eixo X';
ax2.YLabel.String='Valor passo (mm)';
texto= ['Deslocamento interferômetro- Eixo X (mm)'];
title(ax2,texto,'Color','k');

% Bottom bar graph
ax3 = nexttile;
bar(ax3,erro.X,'r');
ax3.XLabel.String='LiDAR X interferômetro';
ax3.YLabel.String='Erro passo (mm)';
texto= ['Erro Médio= ',num2str(erro.XMedio),'mm' ,'    DP= ', num2str(erro.DP), 'mm'];
title(ax3,texto,'Color','r');

% Bottom bar graph
ax4 = nexttile;
bar(ax4,vetorTransLiDAR);
ax4.XLabel.String='Passos LiDAR para cada eixo - XYZ';
ax4.YLabel.String='Valor passo (mm)';
texto= ['Valor do deslocamento para os eixos X, Y e Z LiDAR (mm) '];
title(ax4,texto,'Color','k');

% Exibe a PC concatenada em uma nova figura.
f2=figure;
pcshow(pcFull);
titulo= ['PCs concatenadas= ', int2str(param.numFolders), '  Algortimo Reg.= ', param.algorithmReg,' Algorithm subAmostr= ', param.algorithmSubAmostra, ' gridSize= ', num2str(param.DownSampleAtual) ]
title(titulo);
f2.Position=[1250,100,1200,900]

end