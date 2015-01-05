function [o_tensor_1, o_tensor_2] = tensor_merger(tensor_1, tensor_2)

    %% Input check
    if(size(tensor_1) ~= size(tensor_2))
        disp('tensor_merger: input tensors size are not same');
        return;
    end
    
    % Size of 3D tensor
    [d1, d2, d3] = size(tensor_1);
    
    o_tensor_1 = uint8(zeros(d1,d2,d3));
    o_tensor_2 = uint8(zeros(d1,d2,d3));
    
    %%
    for i=1:d2
        
        matrix_1 = tensor_1(:,i,:);
        matrix_1 = reshape(matrix_1, d1, d3);
        matrix_2 = tensor_2(:,i,:);
        matrix_2 = reshape(matrix_2, d1, d3);
        
        [matrix_1, matrix_2] = matrix_merger(matrix_1, matrix_2);
        
        o_tensor_1(:,i,:) = uint8(matrix_1);
        o_tensor_2(:,i,:) = uint8(matrix_2);
    end
    
end

function [o_matrix_1, o_matrix_2] = matrix_merger(matrix_1, matrix_2)

    [m,n] = size(matrix_1);
    
    mean_1 = mean(matrix_1(:));
    mean_2 = mean(matrix_2(:));
    
    matrix_1 = matrix_1 - mean_1;
    matrix_2 = matrix_2 - mean_2;
    
    sd_1 = std(matrix_1(:));
    sd_2 = std(matrix_2(:));
    
    matrix_1 = matrix_1 / sd_1;
    matrix_2 = matrix_2 / sd_2;
    
    [U_1, S_1, V_1] = svd(matrix_1);
    [U_2, S_2, V_2] = svd(matrix_2);
    
    if(m>n) 
        
%         if(mod(n,2) == 0)
%             mid = n/2;
%         else
%             mid = (n+1)/2;
%         end

        mid = round(n*0.05);
        
    else
        
%         if(mod(m,2) == 0)
%             mid = m/2;
%         else
%             mid = (m+1)/2;
%         end

        mid = round(m*0.05);

    end

    % Swap U orthonormals
    temp                      =    U_1(:, mid:m);
    U_1(:, mid:m)      =    U_2(:, mid:m);
    U_2(:, mid:m)      =    temp;

     % Swap S contents
    temp                      =     S_1(mid:m, :);
    S_1(mid:m, :)       =     S_2(mid:m, :);
    S_2(mid:m, :)       =     temp;

    % Swap V orthonormals
    temp                    =    V_1(:, mid:n);
    V_1(:, mid:n)      =    V_2(:, mid:n);
    V_2(:, mid:n)      =    temp;

    o_matrix_1 = ((U_1 * S_1 * V_1')  *  sd_1)  +  mean_1;
    o_matrix_2 = ((U_2 * S_2 * V_2')  *  sd_2)  +  mean_2;

end