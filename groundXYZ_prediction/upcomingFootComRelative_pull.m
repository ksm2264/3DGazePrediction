clear all
close all

%% stacks

feetLocs = [];

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
           
                
            % iterate over all steps
            for stepDex = 1:size(steps,1)-1
                
                disp(['Subj: ' sub_str ', Cond: ' cond_str ', Walk: ' num2str(walk) ', Progress: '...
                    num2str(stepDex/size(steps,1))]);
                
                % frame range for step at stepDex
                frameRange = steps(stepDex,1):steps(stepDex+1,1)-1;
                
                hCenXYZ = thisWalk.hCenXYZ(frameRange,:);
                
                feetLoc_this = steps(stepDex+1:min(stepDex+5,size(steps,1)),4:6);
               
                comRep =5;
                feetLoc_this = reshape(feetLoc_this',[1 size(feetLoc_this(:))]);
                 if size(feetLoc_this,2)~=15
                    feetLoc_this(1,end+1:15)=nan;
                end
                
                hCenXYZ = repmat(hCenXYZ,[1 comRep]);
                
                comRelFeetLocs = feetLoc_this - hCenXYZ;
                comRelFeetLocs = comRelFeetLocs';            
                comRelFeetLocs = comRelFeetLocs(:);
                comRelFeetLocs = reshape(comRelFeetLocs,[3 length(comRelFeetLocs)/3]);
                comRelFeetLocs = normr(comRelFeetLocs')';
                comRelFeetLocs = reshape(comRelFeetLocs,[15 size(hCenXYZ,1)])';
%                 comRelFeetLocs = resh
                
                feetLocs = [feetLocs; comRelFeetLocs(2:end,:)];
                
            end
            
           
            
        end
    end
end

            save('upcomingFeet.mat','feetLocs');