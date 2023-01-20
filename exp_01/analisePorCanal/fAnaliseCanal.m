function [handles media dp]= fAnaliseCanal(pc, handles)

    numPts= length(pc.Location);
    
    for (ctPt=1:numPts)
        range(ctPt)= norm(pc.Location(ctPt,:));   
    end
    media= mean(range);
    dp= std(range);  
end
