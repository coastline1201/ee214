% clc;clear;
%%Part1:load the train and test data with two options: clean && babble 10 db
load('clean');
%load('babble10db');
addpath('voicebox');  %%add voice box into path

%%
%Part2:Training
numSpeakers = 10;   % number of speakers
fs = 8000;   % sampling frequency of the data
numComp = 6;   % number of mixtures
gmmCell = cell(numSpeakers,1);    % declare a cell for storing GMM


for iSpeaker = 1:numSpeakers
    disp(['Training a model for Speaker ' num2str(iSpeaker)]);
    
    fileList = find(TrainLabel == iSpeaker);    
    numFiles = length(fileList);
    featureCell = cell(numFiles,1);    
    for iFile = 1:numFiles
        x = TrainCell{fileList(iFile)};    
         y=resample(x,fs,22050);  % y is wavform sampled at fs

 %%%%%%FEATURE CHOICES       

            LPCfeature = LPCbasic(y,fs);
            %LSFfeature = LSFbasic(y, fs);
            MFCCfeature = MFCCbasic(y,fs);
            %STFTfeature = STFTbasic(y, fs);
            %TDfeatures = TimeDomainbasic(y, fs);
            feature = [LPCfeature, MFCCfeature];
            %feature = [LPCfeature, TDfeatures, STFTfeature];
  %%%%

        featureCell{iFile} = feature;  % store features
    end
    featureMat = cell2mat(featureCell);   % concatenate frames from each file
    [IDX] = kmeans(featureMat,numComp);   % cluster feature vectors 
    options = statset('TolTypeFun','rel','TolFun',0.00001);
    GMM = gmdistribution.fit(featureMat,numComp,'Start',IDX,'Replicates',1,'CovType','diagonal','Regularize',1e-6,'Options',options);  % trainGMM
    gmmCell{iSpeaker} = GMM;    %store the model
end


%%
%%Part3:Testing
numTestFiles = 20;
 disp('--> Start testing ');    
LHmat = zeros(numTestFiles,numSpeakers);  % stores likelihood
    for iFile = 1:numTestFiles
        x = TestCell{iFile,1};
        y=resample(x,fs,22050);

          
 %%%%%%FEATURE CHOICES    
        LPCfeature = LPCbasic(y,fs);
        %LSFfeature = LSFbasic(y, fs);
        MFCCfeature = MFCCbasic(y,fs);
        %STFTfeature = STFTbasic(y, fs);
        %TDfeatures = TimeDomainbasic(y, fs);
        feature = [LPCfeature, MFCCfeature];
        %feature = [LPCfeature, TDfeatures, STFTfeature];
 
  %%%%
 
    featureMat=feature;
       
    LHvec = zeros(numSpeakers,1);
        for iModel = 1:numSpeakers
            [a,neglog] = posterior(gmmCell{iModel},featureMat);  % compute likelihood
            LHmat(iFile,iModel) = -1*sum(neglog);
        end
        
    end

    [val,predict] = max(LHmat,[],2);  % determine the model that correspond to the maximum likelihood
    predictionMat(:,1) = predict;
    acc = mean(predict==TestLabel(1:numTestFiles));  % compute the accuracy

    disp(['--> Accuracy: ' num2str(acc*100) ' %'] )
    

