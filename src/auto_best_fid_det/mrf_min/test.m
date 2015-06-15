test_list = [812:1035]';
dataset = 'lfpw';

num_of_samples = size(test_list, 1);
our_fids = cell(num_of_samples, 1);

for i=1:num_of_samples

    sample = test_list(i);
    [unary_weights, pairwise_weights] = generate_unary_and_pairwise(dataset, sample);
    cdir = main();
    our_fids{i} = show_comparision(dataset, sample, cdir);
    % pause;

end

save('our_fids.mat', 'our_fids');
