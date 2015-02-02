function [appearance_weights_graph_500, shape_weights_graph_500] = get_shape_weights(input_path)

  load([input_path '/intermediate_results/appearance_weights_graph.mat']);
  load([input_path '/intermediate_results/bounding_boxes.mat']);
  load('../feature_representation/featureVector_edgeWeight_extraction/face_p99.mat');
  
  p_fid_row_map = get_fid_row_map(model);
  common_parts_map = get_common_parts(model);
  
  appearance_weights_graph_500 = appearance_weights_graph(1:500, 1:500);
  clear appearance_weights_graph;
  
  shape_weights_graph_500 = -1 * ones(500,500);
  
  parfor i=1:500
    s_node_1 = bounding_boxes{1,i};
    disp(['outer loop in node ' num2str(i) '\n']);
    for j=i:500
      t_shape_weights_graph_500 = -1 * (ones(1,500));
      if(appearance_weights_graph_500(i,j) == -1)
        t_shape_weights_graph_500(1,j) = -1;
        %shape_weights_graph_500(j,i) = -1;
        continue;
      end
      if(i==j)
        t_shape_weights_graph_500(1,j) = 0;
      end
      s_node_2 = bounding_boxes{1,j};
      t_shape_weights_graph_500(1,j) = get_shape_distance(s_node_1, s_node_2, p_fid_row_map, common_parts_map);
      %shape_weights_graph_500(j,i) = shape_weights_graph_500(i,j);
    end
    shape_weights_graph_500(i,:) = t_shape_weights_graph_500;
  end
  
  for i=1:500
    for j=(i+1):500
      shape_weights_graph_500(j,i) = shape_weights_graph_500(j,i);
    end
  end
  
end


function min_dist = get_shape_distance(s_node_1, s_node_2, p_fid_row_map, common_parts_map)

  xy_node_1 = s_node_1.xy;
  xy_node_2 = s_node_2.xy;

  if(s_node_1.c < s_node_1.c)
    index = [num2str(s_node_1.c) '-' num2str(s_node_2.c)];
  else
    index = [num2str(s_node_2.c) '-' num2str(s_node_1.c)];
  end

  temp_common_parts = common_parts_map(index);
  number_of_common_parts = size(temp_common_parts,2);
  fid_row_map_1 = p_fid_row_map(s_node_1.c);
  fid_row_map_2 = p_fid_row_map(s_node_2.c);
  
  min_dist = flintmax;
  for x=-4:4
    for y=-4:4
      shape_dist = 0;
      for i=1:number_of_common_parts
        row_number_1 = fid_row_map_1(temp_common_parts(1,i));
        row_number_2 = fid_row_map_2(temp_common_parts(1,i));
        
        xy_1 = [(xy_node_1(row_number_1,1)+((xy_node_1(row_number_1,3))/2)) (xy_node_1(row_number_1,2)+((xy_node_1(row_number_1,4))/2))];
        xy_2 = [(xy_node_2(row_number_2,1)+((xy_node_2(row_number_2,3))/2)) (xy_node_2(row_number_2,2)+((xy_node_2(row_number_2,4))/2))];
        
        temp_mat = [xy_1; xy_2];
        temp_dist = pdist(temp_mat);
        shape_dist = shape_dist + temp_dist;
      end
      shape_dist = shape_dist/number_of_common_parts;
      if(shape_dist < min_dist)
        min_dist = shape_dist;
      end
    end
  end
  
end

function p_fid_row_map = get_fid_row_map(model)
  
  p_fid_row_map = containers.Map('KeyType', 'single', 'ValueType', 'any');
  number_of_poses = size(model.components, 2);

  for i=1:number_of_poses
    fid_row_map   = containers.Map('KeyType', 'single', 'ValueType', 'single');
    temp_component = model.components{i};
    number_of_parts = size(temp_component, 2);
    for j=1:number_of_parts
      fid_row_map(temp_component(1,j).filterid) = j;
    end
    p_fid_row_map(i) = fid_row_map; 
  end
  
end

function commonPartsMap = get_common_parts(model)

   %% Initialization
    numberOfComponents     = length(model.components);
    filtersList                                   = cell(numberOfComponents,1);
    commonPartsMap                = containers.Map;
    
    %% Get the part filter ids for each components(pose)
    for i=1:numberOfComponents
        tempStruct = model.components{i};
        filtersList(i,1) = { reshape([tempStruct.filterid], size(tempStruct)) };
    end
    

    for i=1:numberOfComponents-1
        tempArray = intersect(filtersList{i}, filtersList{i});
        tempKey     = strcat(num2str(i), '-', num2str(i));
        commonPartsMap(tempKey) = tempArray;
        j=i+1;
        tempArray = intersect(filtersList{i}, filtersList{j});
        tempKey     = strcat(num2str(i), '-', num2str(j));
        commonPartsMap(tempKey) = tempArray;
        
        if(i==numberOfComponents-1)
           
        elseif(i==numberOfComponents-2)
            j=i+2;
            tempArray = intersect(filtersList{i}, filtersList{j});
            tempKey     = strcat(num2str(i), '-', num2str(j));
            commonPartsMap(tempKey) = tempArray;
            
        else
            j=i+2;
            tempArray = intersect(filtersList{i}, filtersList{j});
            tempKey     = strcat(num2str(i), '-', num2str(j));
            commonPartsMap(tempKey) = tempArray;
             j=i+3;
            tempArray = intersect(filtersList{i}, filtersList{j});
            tempKey     = strcat(num2str(i), '-', num2str(j));
            commonPartsMap(tempKey) = tempArray;
           
        end
    end
end

