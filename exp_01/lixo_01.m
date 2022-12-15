clear;
clc;
close all;

% Gera nuvem aleatoria.
numPoints=1000;
iniRand= 0;  
fimRand= 10;

pcxCn1= 10*randn(1, numPoints); 
pcyCn1= 10*randn(1, numPoints); 
pczCn1= 10*randn(1, numPoints); 

pcxCn2= 10*randn(1, numPoints); 
pcyCn2= 10*randn(1, numPoints); 
pczCn2= 10*randn(1, numPoints); 

pc(1,:,:)= [pcxCn1' pcyCn1' pczCn1'];
pc(2,:,:)= [pcxCn2' pcyCn2' pczCn2'];

% Coverte a nuvem de pontos com a função pointCloud() do Matlab:
pc1= pointCloud(pc);

pcxCn1= 10*randn(1, numPoints); 
pcyCn1= 10*randn(1, numPoints); 
pczCn1= 10*randn(1, numPoints); 

pcxCn2= 10*randn(1, numPoints); 
pcyCn2= 10*randn(1, numPoints); 
pczCn2= 10*randn(1, numPoints); 

pc(1,:,:)= [pcxCn1' pcyCn1' pczCn1'];
pc(2,:,:)= [pcxCn2' pcyCn2' pczCn2'];

% Coverte a nuvem de pontos com a função pointCloud() do Matlab:
pc2= pointCloud(pc);


pcHandle1= pcshow(pc1);
hold on;

pcHandle2= pcshow(pc2);

pc=pcmerge(pc1,pc2,0.001).Location(:,:,:);
pc3= pccat(pc1);

a=0;





