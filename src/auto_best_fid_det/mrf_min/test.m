test_list = [1346:1546]';
dataset = 'cofw';

num_of_samples = size(test_list, 1);


for i=1:num_of_samples

    sample = test_list(i);
    [unary_weights, pairwise_weights] = generate_unary_and_pairwise(dataset, sample);
    cdir = main();
    show_comparision(dataset, sample, cdir);
    % pause;

end
