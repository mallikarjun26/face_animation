function [p,pRT, err_measure, global_fiducials, regModel] = find_rcpr_error_measure(path, number_of_samples)

    %
    load([path '/belhumeur_data/intermediate_results/global_fiducials.mat']);
    load([path '/belhumeur_data/intermediate_results/global_model_map.mat']);
    
    %
    %number_of_samples = size(global_model_map,1);
    %number_of_samples = 25;
    err_measure = Inf * ones(number_of_samples, 1);
    common_parts = get_common_parts(path);
    [IsT, bboxes] = get_test_file(global_fiducials, global_model_map, number_of_samples);

    %% LOAD PRE-TRAINED RCPR model
    load('models/rcpr_COFW.mat','regModel','regPrm','prunePrm');
    nfids=87/3;
    
    %% TEST
    
    %Initialize randomly using RT1 shapes drawn from training
    RT1=5;
    p=shapeGt('initTest',IsT,bboxes,regModel.model,...
        regModel.pStar,regModel.pGtN,RT1);
    %Create test struct
    testPrm = struct('RT1',RT1,'pInit',bboxes,...
        'regPrm',regPrm,'initData',p,'prunePrm',prunePrm,...
        'verbose',1);
    %Test
    t=clock;[p,pRT] = rcprTest(IsT,regModel,testPrm);t=etime(clock,t);


    % Use threshold computed during training to 
    % binarize occlusion
    
    p(:,1:nfids*2)=round(p(:,1:nfids*2));
    occl=p(:,(nfids*2)+1:end);
    occl(occl>=regModel.th)=1;occl(occl<regModel.th)=0;
    p(:,(nfids*2)+1:end)=occl;
    %Compute loss
    fprintf('--------------DONE\n');
    
    
    %% VISUALIZE Example results on a test image
    
    for i=1:number_of_samples
        err_measure(i,1) = get_error(p(i,:), global_fiducials{i,1}, common_parts);
    end

    
end

function err_measure = get_error(br, bt, common_parts)

    %
    num_of_com_parts = size(common_parts,1);
    rcpr_fids = [ br(1,30:58)' br(1,1:29)' ];
    tru_fids  = bt;
    
    t1 = [rcpr_fids(common_parts(:,1),1)' rcpr_fids(common_parts(:,1),2)'];
    t2 = [tru_fids(common_parts(:,2),1)' tru_fids(common_parts(:,2),2)'];
    t = double([t1;t2]);
    
    err_measure = pdist(t) / num_of_com_parts;
    
end

function common_parts = get_common_parts(path)

    %
    fid = fopen([path '/rcpr_data/rcpr_true_common_fids.txt']);
    temp_c = textscan(fid, '%u %u', 'HeaderLines', 1);
    
    common_parts = [];
    common_parts = temp_c{1};
    common_parts = [common_parts temp_c{1,2}];
    
end


function [IsT, bboxes] = get_test_file(global_fiducials, global_model_map, number_of_samples)

    %
    
    %
    %number_of_samples = size(global_model_map,1);
    %number_of_samples = 25;
    
    %
    IsT = cell(number_of_samples,1);
    bboxes = zeros(number_of_samples,4);

    for i=1:number_of_samples

        IsT{i,1}         = imread(global_model_map{i,1});
        true_bbs         = global_fiducials{i,1};
        x1 = min(true_bbs(:,2));
        y1 = min(true_bbs(:,1));
        x2 = max(true_bbs(:,2));
        y2 = max(true_bbs(:,1));
        bboxes(i,:)     = [x1 y1 (x2-x1) (y2-y1)];  
    end
    

end
