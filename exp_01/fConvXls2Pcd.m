function fConvXls2Pcd()
clear;
clc;
close all

% Principais parâmetros.
% N é o número de posições onde o LiDAR gerou as nuvens de pontos.

pathRead= 'C:\Users\mwend\Downloads\2022.11.24 - LiDAR Com Interferômetro\experimento_01\csv';
pathSave= 'C:\Users\mwend\Downloads\2022.11.24 - LiDAR Com Interferômetro\experimento_01\pcd';

nameFolder= '2022_11_25_01_';
nameFileRead= '2022_11_25_01_';
nameFileSave= '2022_11_25_01_';

extRead= 'csv';
extSave= 'pcd';

folderIni= 5;
numFolders= 15;

for (ctFolder= folderIni:numFolders) 
    nameAux= (ctFolder)*200; 
    nameFolderAux= sprintf('%s%0.4d\\', nameFolder, nameAux);
    pathFolderRead= fullfile(pathRead,nameFolderAux);
    pathFolderSave= fullfile(pathSave,nameFolderAux);
    % Se o folder onde será salvo o .pcd não existir ele irá criar.
    if (~isfolder(pathFolderSave))
        mkdir(pathFolderSave);
    end
    % Verifica quantos arquivos tem para serem convertidos
    infoFolder= dir(fullfile(pathFolderRead, '*.csv'));
    numFiles= length(infoFolder(not([infoFolder.isdir])));
    for (ctFile=1:numFiles)                
        nameFile= sprintf('%s%0.3d_%0.10d.%s', nameFileRead, nameAux, ctFile, extRead);
        fullPathFile = fullfile(pathFolderRead,nameFile);
        data= load(fullPathFile);
        % Organiza os dados por canal:
        ctCh(1:16)=0;
        for (i=1:length(data))
            channel= data(i,5)+1; % Não existe index '0' no Matlab; 
            ctCh(channel)= ctCh(channel)+1;
            dataAux(channel,ctCh(channel),:)= data(i,1:4);        
        end

        % Gera PC a partir dos dados do arquivo ".csv" com os dados separados por canal
        % no forma NxMx3. Sendo N= nº do canal e M o nº da dados:
        pc= pointCloud(dataAux(:,:,1:3),'Intensity',uint8(dataAux(:,:,4)));    
        % Salva a nuvem de pontos no formato .pcd.
        nameFile= sprintf('%0.4d.%s', ctFile, extSave);
        fullPathFile = fullfile(pathFolderSave,nameFile);
        % Grava PC:
        pcwrite(pc,fullPathFile); %', Encoding','ascii')
    end
end  

a=0;

 
 


