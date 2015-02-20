function [pos_part_patches, neg_part_patches]= get_part_patches(global_model_map, global_fiducials)

    %
    number_of_samples = size(global_model_map,1);
    number_of_parts   = size(global_fiducials{1},1);
    pos_part_patches  = cell(number_of_parts,1);
    neg_part_patches  = cell(number_of_parts,1);
    
    %
    for i=1:number_of_parts
        pos_samples = cell(number_of_samples*6,1);
        pos_part_patches{i,1} = pos_samples;
        neg_samples = cell(number_of_samples*6,1);
        neg_part_patches{i,1} = neg_samples;
    end
    
    %
    for i=1:number_of_samples
        
        im = imread(global_model_map{i,1});
        if(size(im,3) == 3)
            im = rgb2gray(im);
        end
        part_loc = global_fiducials{i,1};
        interocular_distance = part_loc(46,2) - part_loc(37,2);
        
        x_scale = uint32(double((size(im,2))/double(interocular_distance)) * double(55));
        y_scale = uint32((double(x_scale)/double(size(im,2))) * double(size(im,1)));
        
        part_loc(:,1) = uint32( double(part_loc(:,1)) * (double(y_scale)/ double(size(im,1))) );
        part_loc(:,2) = uint32( double(part_loc(:,2)) * (double(x_scale)/ double(size(im,2))) );
        
        im = imresize(im, [y_scale x_scale]);
        
        for j=1:number_of_parts
            pos_samples = pos_part_patches{j,1};
            neg_samples = neg_part_patches{j,1};
            
            get_neg_samples(neg_samples, im, part_loc(j,:), uint32(interocular_distance/4), i);
            
            y1 = part_loc(j,1) - 20;
            x1 = part_loc(j,2) - 20;
            y2 = part_loc(j,1) + 20;
            x2 = part_loc(j,2) + 20;
            
            if( (x1>0) && (y1>0) && (x2<size(im,2)+1) && (y2<size(im,1)+1) )
                part_im = im(y1:y2, x1:x2);
                part_size_y = size(part_im, 1);
                part_size_x = size(part_im, 2);
                for k=1:6
                    if(k~=1)
                        rot_angle = randi([1 15]);
                        part_rot = imrotate(part_im, rot_angle);
                    else
                        part_rot = part_im;
                    end
                    part_f = part_rot( uint32(0.2*part_size_y):uint32(0.8*part_size_y), uint32(0.2*part_size_x):uint32(0.8*part_size_x) );
                    part_f = imresize(part_f, [20 20]);
                    f = (i-1)*6 + k;
                    pos_samples{f,1} = part_f;
                end
            else
                part_f = [];
                for k=1:6
                    f = (i-1)*6 + k;
                    pos_samples{f,1} = part_f;
                end
            end
            
            pos_part_patches{j,1} = pos_samples;
        end
        
    end

end

function neg_samples = get_neg_samples(neg_samples, im, part_loc, apart_dis, i)

    %
    image_size_y = size(im, 1);
    image_size_x = size(im, 2);
    
    %
    x = randi([20 image_size_x-20]);
    y = randi([20 image_size_y-20]);

    while(abs(x-part_loc(1,2))>apart_dis && abs(y-part_loc(1,1))>apart_dis)
        x = randi([20 image_size_x-20]);
        y = randi([20 image_size_y-20]);
    end
    
    y1 = y - 20;
    x1 = x - 20;
    y2 = y + 20;
    x2 = x + 20;

    if( (x1>0) && (y1>0) && (x2<size(im,2)+1) && (y2<size(im,1)+1) )
        part_im = im(y1:y2, x1:x2);
        part_size_y = size(part_im, 1);
        part_size_x = size(part_im, 2);
        for k=1:6
            if(k~=1)
                rot_angle = randi([1 15]);
                part_rot = imrotate(part_im, rot_angle);
            else
                part_rot = part_im;
            end
            part_f = part_rot( uint32(0.2*part_size_y):uint32(0.8*part_size_y), uint32(0.2*part_size_x):uint32(0.8*part_size_x) );
            part_f = imresize(part_f, [20 20]);
            f = (i-1)*6 + k;
            pos_samples{f,1} = part_f;
        end
    else
        part_f = [];
        for k=1:6
            f = (i-1)*6 + k;
            pos_samples{f,1} = part_f;
        end
    end
    
end
