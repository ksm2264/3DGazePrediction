clear all
close all

%% stacks

gazeVec = [];

velMarkersAll = [];
%% main iter



for subj = 1:3
    disp(['Subject: ' num2str(subj)]);
    switch subj
        case 1
            sub_str_worldvid = '2018-01-23_JSM';
            sub_str = 'JSM';
            endDex = 2;
        case 2
            sub_str_worldvid = '2018-01-26_JAC';
            sub_str = 'JAC';
            endDex = 2;
        case 3
            sub_str_worldvid = '2018-01-31_JAW';
            sub_str = 'JAW';
            endDex = 2;
    end
    
    
    for cond = 1:endDex
        disp(['Cond: ' num2str(cond)]);
        switch cond
            case 1
                cond_str = 'Woodchips';
            case 2
                cond_str = 'Rocks';
        end
        
        for walk = 1:6
          
            
            data_path = ['/home/karl/Dropbox/OpticFlowProject/Data/' sub_str_worldvid '/OutputFiles/' ...
                cond_str '_allWalks.mat'];
            
            load(data_path);
            thisWalk = allWalks{1,walk};
            
            % indeces of heelstrike events
            steps = thisWalk.steps_HS_TO_StanceLeg_XYZ;
            gazeVecs = normr(mean(cat(3,thisWalk.rGazeGroundIntersection-thisWalk.rEyeballCenterXYZ,...
                    thisWalk.lGazeGroundIntersection-thisWalk.lEyeballCenterXYZ),3));
            % iterate over all steps
            for stepDex = 1:size(steps,1)-1
                
                disp(['Subj: ' sub_str ', Cond: ' cond_str ', Walk: ' num2str(walk) ', Progress: '...
                    num2str(stepDex/size(steps,1))]);
                
                % frame range for step at stepDex
                frameRange = steps(stepDex,1):steps(stepDex+1,1)-1;
                
                gazeVecsThis = gazeVecs(frameRange,:);
                
                gazeVec = [gazeVec;gazeVecsThis(2:end,:)];
                
            end
            
           
            
        end
    end
end

            save('gazeVec.mat','gazeVec');