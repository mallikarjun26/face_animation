function [unary_weights, pairwise_weights] = generate_unary_and_pairwise(dataset, face_number)

    %%
    clc; close all;

    %%
    nodes  = 80; % p1m1 p2m1 p3m1 p4m1 ... p20m1 p1m2 p2m2 p3m2 ... p20m4
    labels = 21; % p1 p2 .. p20 pn
    % face_number = 1020;

    %%
    disp('Getting unary weights .. ');
    [unary_weights, part_near_exemplar] = get_unary_weights(dataset, face_number);
    disp('Getting pairwise weights .. ');
    pairwise_weights = get_pairwise_weights(dataset, part_near_exemplar);

    %%
    save('unary_weights.mat', 'unary_weights');
    save('pairwise_weights.mat', 'pairwise_weights');

end
