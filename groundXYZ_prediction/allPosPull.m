clear all
close all

% normalization ( 'leg', 'headRelativeVector', 'none')
normalizationFlag = 'leg';

% set origin of foot locations ('com','plantfoot')
originSet = 'plantfoot';



assert(strcmp(originSet,'plantfoot')||strcmp(originSet,'com'));

switch originSet
    case 'plantfoot'
        footOrig=true;
        outStr_origin = 'plantedFoot';
    case 'com'
        footOrig=false;
        outStr_origin = 'centerOfMass';
end


assert(strcmp(normalizationFlag,'leg')||strcmp(normalizationFlag,'none'));

switch normalizationFlag
    case 'leg'
        legNorm=1;
        normalization_str = 'legNormalized';
    case 'none'
        legNorm=2;
        normalization_str = 'not normalized';  
end






%% stacks

hxAll = [];
hyAll = [];
hzAll = [];
comXYZAll = [];
markersAll = [];
gazeXZAll = [];
gaitCyclePctAll = [];
velComXYZAll=[];
velMarkersAll = [];
%% main iter



for subj = 1:3
    disp(['Subject: ' num2str(subj)]);
    switch subj
        case 1
            sub_str_worldvid = '2018-01-23_JSM';
            sub_str = 'JSM';
            startDex = 2;
            endDex = 2;
        case 2
            sub_str_worldvid = '2018-01-26_JAC';
            sub_str = 'JAC';
            startDex = 2;
            endDex = 2;
        case 3
            sub_str_worldvid = '2018-01-31_JAW';
            sub_str = 'JAW';
            startDex = 2;
            endDex = 2;
    end
    
    
    for cond = startDex:endDex
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
            
            % iterate over all steps
            for stepDex = 1:size(steps,1)-1
                
                disp(['Subj: ' sub_str ', Cond: ' cond_str ', Walk: ' num2str(walk) ', Progress: '...
                    num2str(stepDex/size(steps,1))]);
                
                % frame range for step at stepDex
                frameRange = steps(stepDex,1):steps(stepDex+1,1)-1;
                
                % xz location of planted foot
                stepXZ = steps(stepDex,[4 6]);
                
                
                % rawCOM
                comXYZ = thisWalk.comXYZ(frameRange,:);
                
                % gaze ground intersection relative to center of mass
                
                if footOrig
                    gazeXZ = mean(cat(3,thisWalk.rGazeGroundIntersection(frameRange,:)-thisWalk.comXYZ(frameRange,:),...
                        thisWalk.lGazeGroundIntersection(frameRange,:)),3);
                    gazeXZ = gazeXZ(:,[1 3]);
                    gazeXZ = gazeXZ - stepXZ;
                else % com
                    gazeXZ = mean(cat(3,thisWalk.rGazeGroundIntersection(frameRange,:)-thisWalk.comXYZ(frameRange,:),...
                        thisWalk.lGazeGroundIntersection(frameRange,:)-thisWalk.comXYZ(frameRange,:)),3);
                    gazeXZ = gazeXZ(:,[1 3]);
                end
                    
                
                % percent of the way through a heelstrike to heelstrike
                gaitCyclePct = linspace(0,1,length(frameRange))';
                
                % center of mass velocity
                vel_comXYZ = diff(comXYZ);
                
                % markers
                markers = thisWalk.shadow_fr_mar_dim(frameRange,:,:);
                
                if footOrig
                    stepXYZ_sub = permute(repmat(steps(stepDex,[4 5 6]),[1 1 30]),[1 3 2]);
                    markers = markers-stepXYZ_sub;
                else
                    comXYZ_sub = permute(repmat(comXYZ,[1 1 30]),[1 3 2]);
                    markers = markers-comXYZ_sub;
                end
                
                vel_markers = diff(markers);
                
                % (drop first frame everything else)
                markers = markers(2:end,:,:);
                gaitCyclePct = gaitCyclePct(2:end);
                gazeXZ = gazeXZ(2:end,:);
                comXYZ = comXYZ(2:end,:);
                hx = thisWalk.headVecX_fr_xyz(frameRange,:);
                hx = hx(2:end,:);
                hy = thisWalk.headVecY_fr_xyz(frameRange,:);
                hy = hy(2:end,:);
                hz = thisWalk.headVecZ_fr_xyz(frameRange,:);
                hz = hz(2:end,:);
                %                 markers = markers(2:end,:,:);
                
                if legNorm ==1
                    markers = markers/thisWalk.sesh.legLength;
                    vel_comXYZ = vel_comXYZ/thisWalk.sesh.legLength;
                    vel_markers = vel_markers/thisWalk.sesh.legLength;
                    gazeXZ = gazeXZ/thisWalk.sesh.legLength;                   
                end
                
                
                
                hxAll = [hxAll;hx];
                hyAll = [hyAll;hy];
                hzAll = [hzAll;hz];
                comXYZAll =[comXYZAll;comXYZ];
                velComXYZAll=[velComXYZAll;vel_comXYZ];
                markersAll = [markersAll;markers];
                velMarkersAll = [velMarkersAll;vel_markers];
                gazeXZAll = [gazeXZAll;gazeXZ];
                gaitCyclePctAll = [gaitCyclePctAll;gaitCyclePct];
                
            end
            
            
            
        end
    end
end
markerNames = thisWalk.shadowMarkerNames;

save([outStr_origin '_' normalization_str '_' cond_str '_bodyfullstack.mat'],'hyAll','hzAll','hxAll','comXYZAll','markersAll','gazeXZAll',...
    'gaitCyclePctAll','velComXYZAll','velMarkersAll','markerNames','-v7.3');

