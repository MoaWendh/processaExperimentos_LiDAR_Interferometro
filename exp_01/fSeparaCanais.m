function fSeparaCanais(pc, param, ctPC)
    
    fprintf(' \n Salvando a PC por canal do LiDAR (PC nº=%0.2d )', ctPC);
    % Determina o n~umero de canais da PC:
    [numCanais numPts eixos]= size(pc.Location);
    
    for (cn=1:numCanais)
        % Verifica se os folders onde serão salvas as PCs por canal existem,
        % se não existir eles serão gerados, conforme definido no param:
        pathToSavePCReg= sprintf('%s%s%0.2d',param.path.BaseSave, param.path.PCCanais,cn);
        if ~isfolder(pathToSavePCReg)
            mkdir(pathToSavePCReg);
        end
        % Monta o nome de arquivo a ser salvo:
        nameFile= sprintf('%0.4d.%s', ctPC, param.name.extPC);
        fullPath= fullfile(pathToSavePCReg, nameFile);
        
        % Gera a PC por canal:
        pcAux= pointCloud(pc.Location(cn,:,:), 'Intensity',pc.Intensity(cn,:));
        
        % Salva a PC do canal no respectivo folder:
        pcwrite(pcAux,fullPath);
        fprintf(' cn=%0.2d', cn);
    end
end
