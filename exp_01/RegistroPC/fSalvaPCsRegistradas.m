function fSalvaPCsRegistradas(handles)


% Verifica se folder onde serão salvas as PCs alinhadas existe, se não
% existir o folder será gerado, conforme definido no handles:
pathToSavePCReg= sprintf('%s%s',handles.path.BaseSave, handles.path.PCReg);
if ~isfolder(pathToSavePCReg)
    mkdir(pathToSavePCReg);
end

% Path onde são salvas as PCs totalmente concatenadas, ou seja, a pcFull
% constituida das N PCs.
pathToSavePCRegFull= sprintf('%s%s',handles.path.BaseSave, handles.path.PCFull);
if ~isfolder(pathToSavePCRegFull)
    mkdir(pathToSavePCRegFull);
end

% Path onde são salvas as transformações de corpo rígido 'tform' obtidas
% pelos algoritmos de registro:
pathToSaveTform= sprintf('%s%s',handles.path.BaseSave, handles.path.tform);
if ~isfolder(pathToSaveTform)
    mkdir(pathToSaveTform);
end


for (ctPC=1:length(handles.pc))
   % Salva a PC devidamente alinhada:
   nameFile= sprintf('%0.4d.%s',ctPC, handles.name.extPC);
   fullPath= fullfile(pathToSavePCReg, nameFile);
   pcwrite(handles.pcAligned{1,ctPC}, fullPath);
    
   if (ctPC>1)
       % Salva a transformação de corpo rígido da PC atual:
       nameFile= sprintf('%s%0.4d', handles.name.FileTForm, ctPC-1, '.mat');
       fullPath= fullfile(pathToSaveTform, nameFile);
       R= handles.tform{1,ctPC-1}.Rotation;
       t= handles.tform{1,ctPC-1}.Translation;
       save(fullPath, 'R', 't');
   end
end
   
% Salva todas as PCs concatenadas num único arquivoa:
nameFile= sprintf('pcFull.pcd');
fprintf('\n Salvando as PCs concatenadas no arquivo: %s ...', nameFile);
fullPath= fullfile(pathToSavePCRegFull, nameFile);
pcwrite(handles.pcFull{1}, fullPath);
   
end
