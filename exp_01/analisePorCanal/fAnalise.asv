function handles= fAnalise(handles)
    close all;
    
    % Extrai a quantidade de PC e canais a serem anaisados:
    numPCs= length(handles.PcAnalise);
    numCanais= length(handles.cnAnalise);
    
    % Executa iteração:
    for (ctPc=1:numPCs)
        % Define o nome da PC a ser lida:
        namePC= sprintf('pc%0.4d', ctPc);
        for (ctCn=1:numCanais)
            nameFile= sprintf('\\%s_%s.%s', namePC, handles.lookUpTable{handles.cnAnalise(ctCn)}, handles.extPC)
            fullPath= fullfile(handles.pathRead, nameFile)
            pc{ctPc,ctCn}= pcread(fullPath);
            [handles media(ctPc,ctCn) dp(ctPc,ctCn)]= fAnaliseCanal(pc{ctPc,ctCn}, handles);
        end
    end
    
    figure;
    plot(media(:,1),'*r');
    
end
