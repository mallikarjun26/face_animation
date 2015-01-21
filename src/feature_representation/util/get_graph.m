function [graph] = get_graph(edge_weights_file)

    edge_weights_fileID = fopen(edge_weights_file);
    edge_weights_contents = textscan(edge_weights_fileID, '%u-%u=%f','HeaderLines', 1);
    edge_weights_fileID = fopen(edge_weights_file);
    number_of_nodes = str2num(fgetl(edge_weights_fileID));
    graph = zeros(number_of_nodes, number_of_nodes);
    
    vertex_1 = edge_weights_contents{1} + 1;
    vertex_2 = edge_weights_contents{2} + 1;
    edge_weights = edge_weights_contents{3};
    
    idx = sub2ind(size(graph), vertex_1, vertex_2);
    graph(idx) = edge_weights; 
    
    idx = sub2ind(size(graph), vertex_2, vertex_1);
    graph(idx) = edge_weights; 
    
end