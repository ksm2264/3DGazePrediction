close all
clear all

load('gazeVec.mat');
load('bodyfullstack.mat');
load('upcomingFeet.mat');

trainSplit = 2;
distCutoff = 4000;
inputStack = [];

useFeet = false;

numFeet = 4;

feetLocs = feetLocs(:,1:numFeet*3);

%% clean data

useDex = and(and(gazeVec(:,1)~=gazeVec(:,2),gazeVec(:,2)~=3),gazeVec(:,1)~=gazeVec(:,3));


if useFeet
    nandex = sum(~isnan(feetLocs),2);
    nandex = nandex==numFeet*3;
    
    useDex = and(useDex,nandex);
end

gazeVec = gazeVec(useDex,:);
gaitCyclePctAll=gaitCyclePctAll(useDex,:);
markersAll = markersAll(useDex,:,:);
velComXYZAll = velComXYZAll(useDex,:);
velMarkersAll = velMarkersAll(useDex,:,:);
hxAll = hxAll(useDex,:);
hyAll = hyAll(useDex,:);
hzAll = hzAll(useDex,:);
feetLocs = feetLocs(useDex,:);


trainIDX = randperm(length(gaitCyclePctAll),round(length(gaitCyclePctAll)/trainSplit));

tidx = zeros(length(trainIDX),1);
tidx(trainIDX) = 1;
tidx = logical(tidx);

for ii = 1:25
    inputStack = [inputStack squeeze(markersAll(:,ii,:))];
end

inputStack = [inputStack gaitCyclePctAll velComXYZAll];

for ii = 1:25
    inputStack = [inputStack squeeze(velMarkersAll(:,ii,:))];
end

% inputStack = [inputStack hxAll hyAll hzAll];
if useFeet
    inputStack = [inputStack feetLocs];
end
% inputStack = feetLocs;

train_inputs = inputStack(tidx,:);
test_inputs = inputStack(~tidx,:);

train_outputX = gazeVec(tidx,1);
train_outputY = gazeVec(tidx,2);
train_outputZ = gazeVec(tidx,3);

test_outputX = gazeVec(~tidx,1);
test_outputY = gazeVec(~tidx,2);
test_outputZ = gazeVec(~tidx,3);


[bx dev statsx] = glmfit(train_inputs,train_outputX);
[by dev statsy] = glmfit(train_inputs,train_outputY);
[bz dev statsz] = glmfit(train_inputs,train_outputZ);


guessX = glmval(bx,test_inputs,'identity');
guessY = glmval(by,test_inputs,'identity');
guessZ = glmval(bz,test_inputs,'identity');

rmse_X = mean((guessX-test_outputX).^2);
rmse_Y = mean((guessY-test_outputY).^2);
rmse_Z = mean((guessZ-test_outputZ).^2);

rmse_X_baseline = var(test_outputX);
rmse_Y_baseline = var(test_outputY);
rmse_Z_baseline = var(test_outputZ);

R_sq_X = 1-rmse_X/rmse_X_baseline;
R_sq_Y = 1-rmse_Y/rmse_Y_baseline;
R_sq_Z = 1-rmse_Z/rmse_Z_baseline;

allGuessX = glmval(bx,inputStack,'identity');
allGuessY = glmval(by,inputStack,'identity');
allGuessZ = glmval(bz,inputStack,'identity');

%% headvectest
% x

[sortedBetaX sortedBetaIDX] = sort(abs(bx),'descend');

for ii = 1:length(bx)
    orderedClassesX{ii,1} = returnLanguage(sortedBetaIDX(ii),25);
    orderedClassesX{ii,2} = sortedBetaX(ii);
end

% y

[sortedBetaY sortedBetaIDX] = sort(abs(by),'descend');

for ii = 1:length(bx)
    orderedClassesY{ii,1} = returnLanguage(sortedBetaIDX(ii),25);
    orderedClassesY{ii,2} = sortedBetaY(ii);
end

% z
[sortedBetaX sortedBetaIDX] = sort(abs(bz),'descend');

for ii = 1:length(bx)
    orderedClassesZ{ii,1} = returnLanguage(sortedBetaIDX(ii),25);
    orderedClassesZ{ii,2} = sortedBetaX(ii);
end

save('modelPack.mat','bx','by','bz','inputStack','gazeVec');


%%
for ii = 2000:5:size(gazeVec,1)
    
    figure(1)
    
    figure(1)
    hold off
    quiver3(0,0,0,gazeVec(ii,1),gazeVec(ii,2),gazeVec(ii,3),'color','r','autoscale','off');
    hold on
    quiver3(0,0,0,allGuessX(ii),allGuessY(ii),allGuessZ(ii),'color','g','autoscale','off');
    legend('Actual','Prediction');
    xlim([0 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    campos([0 0 1]);
    camtarget([0 0 0]);
    camup([0 1 0]);
    title('side view');
    
    figure(2)
    hold off
    quiver3(0,0,0,gazeVec(ii,1),gazeVec(ii,2),gazeVec(ii,3),'color','r','autoscale','off');
    hold on
    quiver3(0,0,0,allGuessX(ii),allGuessY(ii),allGuessZ(ii),'color','g','autoscale','off');
    legend('Actual','Prediction');
    xlim([0 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    campos([0 1 0]);
    camtarget([0 0 0]);
    camup([1 0 0]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title('top view');
end