function edge_weight_histogram(output_path)

    edge_weights_file = [output_path '/edgeWeights.txt'];
    plot_hist(edge_weights_file);
    edge_weights_file = [output_path '/preTransformEdgeWeights.txt'];
    plot_hist(edge_weights_file);
    
end

function plot_hist(edge_weights_file)
    
    edge_weights_fileID = fopen(edge_weights_file);
    edge_weights_contents = textscan(edge_weights_fileID, '%u-%u=%f','HeaderLines', 1);
    
    edge_weights = edge_weights_contents{3};
    clear edge_weights_contents;
    
    figure;
    hist(edge_weights, 100);
end