function cdir = main()

    % 
    clc; close all;

    %%
    load('unary_weights.mat'); 
    load('pairwise_weights.mat'); 

    %
    disp('Getting f ..');
    % f = zeros(3120,1);      % 3040 (pairwise) + 80 (unary + l1 norm) 
    f = get_f(unary_weights, pairwise_weights);

    disp('Getting A and b ..');
    % A = zeros(9120, 3120);  % 9120 (pairwise*3)
    % b = zeros(9120,1);      %
    [A, b] = get_A_and_b();

    disp('Getting Aeq and Beq ..');
    % Aeq = zeros(20, 3120);  % withing part.
    % Beq = zeros(20, 1);
    [Aeq, Beq] = get_Aeq_and_Beq();

    lb = zeros(3120, 1);
    ub = ones(3120, 1);

    %
    disp('Running LP ..');
    x = linprog(f,A,b,Aeq,Beq,lb,ub);

    %
    [cdir] = get_best(x(1:80));

end

function [cdir] = get_best(x)

    %
    cdir = reshape(x,20,4);
    [~, cdir] = max(cdir');
    
end

function [Aeq, Beq] = get_Aeq_and_Beq()

    %
    Aeq = zeros(20, 3120);  % withing part.
    Beq = ones(20, 1);

    %
    for i=1:20
        Aeq(i,i)    = 1;
        Aeq(i,i+20) = 1;
        Aeq(i,i+40) = 1;
        Aeq(i,i+60) = 1;
    end

end

function [A, b] = get_A_and_b()

    %
    nodes = 80;
    A = zeros(9120, 3120);
    b = zeros(9120,1);

    %
    count = 1;
    for pix1=1:nodes
        for pix2=pix1:nodes

            method1 = ceil(pix1/20);
            method2 = ceil(pix2/20);
            part1 = mod(pix1-1,20) + 1;
            part2 = mod(pix2-1,20) + 1;

            if(part1 ~= part2)
                r1 = (count-1)*3 + 1;
                r2 = r1 + 1;
                r3 = r2 + 1;

                A(r1, pix1) = 1;
                A(r1, pix2) = 1;
                A(r1, 80+count) = -1; 
                b(r1) = 1;
                
                A(r2, pix1)  = -1;
                A(r2, 80+count) = 1;
                b(r2) = 0;

                A(r3, pix2)  = -1;
                A(r3, 80+count) = 1;
                b(r3) = 0;

                count = count + 1;
            end

        end
    end

end


function f = get_f(unary_weights, pairwise_weights)
    
    %
    f = zeros(3120, 1);

    %
    f(1:80) = unary_weights + 1;
    f(81:3120) = pairwise_weights + 1;

end
