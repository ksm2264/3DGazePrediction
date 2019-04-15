clear all
close all

%% stacks

feetLocs = [];

velMarkersAll = [];

%% flags

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


assert(strcmp(normalizationFlag,'leg')||strcmp(normalizationFlag,'none')||...
strcmp(normalizationFlag,'headRelativeVector'));

switch normalizationFlag
    case 'leg'
        legNorm=1;
        normalization_str = 'legNormalized';
    case 'none'
        legNorm=2;
        normalization_str = 'not normalized';
    case 'headRelativeVector'
        legNorm=3;
        normalization_str = 'headRelativeVector';
end


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
    
    
    for cond = 2:endDex
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
                
                hCenXYZ = thisWalk.hCenXYZ(frameRange,:);
                
                comRep =5;
                
                hCenXYZ = repmat(hCenXYZ,[1 comRep]);
                
                if legNorm==3
                    feetLoc_this = steps(stepDex+1:min(stepDex+5,size(steps,1)),4:6);
                    
                    
                    feetLoc_this = reshape(feetLoc_this',[1 size(feetLoc_this(:))]);
                    if size(feetLoc_this,2)~=15
                        feetLoc_this(1,end+1:15)=nan;
                    end
                    
                    comRelFeetLocs = feetLoc_this - hCenXYZ;
                    comRelFeetLocs = comRelFeetLocs';
                    comRelFeetLocs = comRelFeetLocs(:);
                    comRelFeetLocs = reshape(comRelFeetLocs,[3 length(comRelFeetLocs)/3]);
                    comRelFeetLocs = normr(comRelFeetLocs')';
                    comRelFeetLocs = reshape(comRelFeetLocs,[15 size(hCenXYZ,1)])';
                    
                    feetLocs = [feetLocs; comRelFeetLocs(2:end,:)];
                    
                    
                elseif legNorm==1
                    feetLoc_this = steps(stepDex+1:min(stepDex+5,size(steps,1)),[4 6]);
                    
                    comRep =5;
                    feetLoc_this = reshape(feetLoc_this',[1 size(feetLoc_this(:))]);
                    if size(feetLoc_this,2)~=10
                        feetLoc_this(1,end+1:10)=nan;
                    end
                    
                    
                    
                    stepXZ = steps(stepDex,[4 6]);
                    stepXZ = repmat(stepXZ,[length(frameRange) comRep]);
                    planStepRelSteps =  feetLoc_this -stepXZ;
                    planStepRelSteps = planStepRelSteps/thisWalk.sesh.legLength;
                    feetLocs = [feetLocs; planStepRelSteps(2:end,:)];
                end
            end
            
           
            
        end
    end
end


save([outStr_origin '_' normalization_str '_' cond_str '_upcomingFootholds.mat'],'feetLocs');
