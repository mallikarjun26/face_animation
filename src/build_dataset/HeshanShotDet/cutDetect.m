% This funtion takes dissimilarity distribution as input, and output the
% shot boundary. It detects the shot cuts with adaptive threshold
% algorithm. Since the model come from Dr. Dugad, we name it Dugad_Detect.

function [cutPosition] = Dugad_Detect(distA)

% model parameter
Td = 5;
w = 20; % the windows size is 2*w

cutPosition = [];
% scan the cuts
i = 1;
while i<size(distA,1)
    mid = i;
    left = mid - w; % left bound of the window 
    if left < 1 
        left = 1;
    end
    
    right = i+w; % right bound of the window
    if right>size(distA,1)
        right = size(distA,1);
    end
    
    % determine whether mid has the max value in the neighbourhood
    maxw = max(distA(left:right,2));
    if  distA(mid,2) < maxw
        maxpos = find(distA(:,2)==maxw);
        if i<maxpos(1)
            i = maxpos(1);
        else
            i = i+1;
        end
        continue;
    end
    
    % determine whether mid is big enough to be a cut
    lmean = mean(distA(left:mid-1,2));
    lstd = std(distA(left:mid-1,2));
    rmean = mean(distA(mid+1:right,2));
    rstd = std(distA(mid+1:right,2));
    if distA(mid,2)>max(lmean+Td*lstd, rmean+Td*rstd)
        cutPosition = [cutPosition;distA(mid,:)];        
    end
    i = right+1;
end

return;