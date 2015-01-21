function [rankScore] = tensor_3D_analysis(i_tensor)

    rankScore = 0;
    
    % Size of 3D tensor
    [d1, d2, d3] = size(i_tensor);
    
    %% Normalize tensor across each frame
    for i=1:d3
        temp_2D_tensor  =     i_tensor(:,:,i);
        temp_2D_tensor  =     temp_2D_tensor - mean(temp_2D_tensor(:));
        temp_2D_tensor  =     temp_2D_tensor / std(temp_2D_tensor(:));
        i_tensor(:,:,i)            =     temp_2D_tensor;
    end
    
    %% Find the rankScore for the tensor
    for i=1:d2
        % Find eigen values for each of the 2D tensor
        tempMat = i_tensor(:,i,:);
        tempMat = reshape(tempMat, d1, d3);
        S = svd(tempMat);
        
        S = sort(S, 'descend');
        
        S = S - mean(S);
        S = S / std(S);
        rankScore = rankScore + (nnz(S>0) / min(d1, d2));
      
    end
    
    rankScore = rankScore / d2;
        
end