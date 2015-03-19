function dump_aflw_rcpr_fids(path)

    %
    facemap = [];
    addpath(genpath('/home/mallikarjun/src/piotr_toolbox/toolbox'));
    addpath(genpath('./../'));
    load([path '/aflw_data/facemap.mat']);
    
    % LOAD PRE-TRAINED RCPR model
    load('../models/rcpr_COFW.mat','regModel','regPrm','prunePrm');
    nfids=87/3;
    regModel = regModel;
    regPrm =regPrm;
    prunePrm=prunePrm;
    %
    number_of_faces = size(facemap,2);
    
    %
    
    parfor i=1:number_of_faces
        
        if(mod(i,20)==0)
            disp([num2str(i) '/' num2str(number_of_faces) 'done']);
        end
        
        IsT = cell(1,1);
        IsT{1,1} = imread(facemap{1,i});
        bboxes = get_bboxes(IsT{1,1});
        
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
    
        rcpr_fids{i,1} = get_formatted_fids(p);
    end
    
    %
    save([path '/aflw_data/rcpr_fids.mat'], 'rcpr_fids')
    
end

function fids = get_formatted_fids(p)

    fids = zeros(29,2);
    fids(:,1) = p(1,30:58)';
    fids(:,2) = p(1,1:29)';
    
end

function bboxes = get_bboxes(im)

    x1 = 1; 
    y1 = 1;
    x2 = size(im,2);
    y2 = size(im,1);
    bboxes     = [x1 y1 (x2-x1) (y2-y1)];  

end
