%% Section 1 : Iterate to load files, extract features, and build matrix
sample_rate=15;         % update according to true sample rate
FilesBHQ=[328,330,331,332,334,336,338,339,340,341,345,...
    351,353,354,358,359,360,370,371,372];
X=zeros(10000,34)-99;    % Allocate memory for matrix X, with default value -99
Y=zeros(10000,1)-99; % Allocate memory for label vector Y
n_instance=0;
n_instance_vec=[];
j=0;
 for r=1:length(FilesBHQ)
    %filename=337;%FilesBHQ(r);
    [num, txt, raw]=xlsread(num2str(FilesBHQ(r)));
    dates = unique(raw(2:end,5));
    datetime(cell2mat(raw(2:end,6)),'ConvertFrom','datenum','Format','HH:mm:ss');
    idx_accelerometer = cellfun(@(x) strcmp(x, 'acelerometer'), raw(2:end,7));
    idx_activity_recognition = cellfun(@(x) strcmp(x, 'activity_recognition'), raw(2:end,7));
    idx_battery = cellfun(@(x) strcmp(x, 'battery'), raw(2:end,7));
    idx_bluetooth = cellfun(@(x) strcmp(x, 'bluetooth'), raw(2:end,7));
    idx_calls = cellfun(@(x) strcmp(x, 'calls'), raw(2:end,7));
    idx_gyroscope = cellfun(@(x) strcmp(x, 'gyroscope'), raw(2:end,7));
    idx_light = cellfun(@(x) strcmp(x, 'light'), raw(2:end,7));
    idx_location = cellfun(@(x) strcmp(x, 'location'), raw(2:end,7));
    idx_magnetic = cellfun(@(x) strcmp(x, 'magnetic'), raw(2:end,7));
    idx_screen_state = cellfun(@(x) strcmp(x, 'screenstate'), raw(2:end,7));
    idx_wireless = cellfun(@(x) strcmp(x, 'wireless'), raw(2:end,7));
    raw = raw(2:end,:);
    accelerometer = raw(idx_accelerometer,:);
    activity_recognition = raw(idx_activity_recognition,:);
    battery = raw(idx_battery,:);
    bluetooth = raw(idx_bluetooth,:);
    calls = raw(idx_calls,:);
    gyroscope = raw(idx_gyroscope,:);
    light = raw(idx_light,:);
    location = raw(idx_location,:);
    magnetic = raw(idx_magnetic,:);
    screen_state = raw(idx_screen_state,:);
    wireless = raw(idx_wireless,:);
    % Labels Vector Weekday vs. weekend
    for i=1:length(dates)
        D=dates{i};
         X_row=Extract_Features(D,accelerometer,activity_recognition,battery,bluetooth,calls,gyroscope,...
     light,location,screen_state,wireless);
        n_instance=n_instance+1;
          X(n_instance,:)=X_row;
        [DayNumber,DayName] = weekday(D); %Labels Vector Weekday vs. weekend
         if DayNumber ==6 || DayNumber == 7
             Y_row=0; % Weekend
         else
             Y_row=1; % Weekday
         end
         Y(n_instance)=Y_row;
    end
    n_instance_vec=[n_instance_vec,n_instance];
 end
ind=find(Y~=-99);
X=X(ind,:); % features 
Y=Y(ind,:);% labels 
%% Baseline
norm_f=zeros(size(X,1),size(X,2));
for i=1:length(FilesBHQ)% 20 users
    if i ==1 
        user=X(1:n_instance_vec(i),:);
        n=1:n_instance_vec(i);
    else
        user =X((n_instance_vec(i-1)+1):n_instance_vec(i),:);
        n=(n_instance_vec(i-1)+1):n_instance_vec(i);
    end
    for j=1:size(X,2) % features for user
         norm_f(n,j)=normalize_feature(user(:,j));
    end
end
%% step 2: skip step 1 and Just load the data
load('norm_fnew.mat')
load('Y.mat')
norm_f(:,6)=[]; %column 6 too much NAN and inf
%% replace NaN values with the mean
[m,n]=find(isnan(norm_f));
norm_f(isnan(norm_f))=0;
for i=1:length(m)
    norm_f(m(i),n(i))=mean(norm_f(:,n(i)));
end
norm_f(~isfinite(norm_f))=0;
%% set train and test
rng('default')
part = cvpartition(Y,'Holdout',0.3);
disp(part)
istrain = training(part); % Data for fitting
istest = test(part);      % Data for quality assessment
tabulate(Y(istrain))
 X_training=norm_f(istrain==1,:);
 X_test=norm_f(istest==1,:);
 Y_training=Y(istrain==1);
 Y_test=Y(istest==1);
%% remove correlated features
Pearson=corr(X_training ,'type','Pearson'); 
[x_Pearson, y_Pearson] = find(abs(Pearson)>0.7);% find the indexs where the correlatition>0.7
vec_delete=[];
for i=1:length(x_Pearson)
    if x_Pearson(i)~=y_Pearson(i) % dont give attention to indexs in diag (where the corr==1)
        vec_delete=[vec_delete,x_Pearson(i),y_Pearson(i)]; % add the indexs where the correlatition>0.7 to vec_delete_T
    end
end
vec_delete_new= unique(vec_delete); % take the indexs one time
Pearson_new=Pearson;
Pearson_new(vec_delete_new,:)=[]; % delete the corr features (rows)  
Pearson_new(:,vec_delete_new)=[]; % delete the corr features (columns)
%Update X_training_T and X_test_T
X_training(:,vec_delete_new)=[];
X_test(:,vec_delete_new)=[];
%% Save train & test files 
Trainfeatures=[X_training,Y_training];
xlswrite('Trainfeatures.xlsx',Trainfeatures)
Testfeatures=[X_test,Y_test];
xlswrite('Testfeatures.xlsx',Testfeatures) 
%After saving we worked with Classification Learner APP in Matlab and
%creates a model using train data, then we chose the best two models; which
%are Ensemble (KNN supspace) & Neural Network (Bilayared) & an optimization
%model of Ensamble
%% Train Models for test data
yfitNeuralNetwork = trainedNeuralNetwork.predictFcn(Testfeatures1) ;
yfitEnsemble = trainedEnsemble.predictFcn(Testfeatures1); 
yfitTuneEnsemble = trainedTuneEnsemble.predictFcn(Testfeatures1) ;
%% confusion matrix test set
figure;
confusionchart(Y_test,yfitNeuralNetwork)
title ( 'Neural Network Model - Test set')
figure;
confusionchart(Y_test,yfitEnsemble)
title ( 'Ensemble Model - Test set')
%% confusion matrix train set
yfitNeuralNetworktrain = trainedNeuralNetwork.predictFcn(Trainfeatures1) ;
yfitEnsembletrain = trainedEnsemble.predictFcn(Trainfeatures1); 
yfitTuneEnsembletrain = trainedTuneEnsemble.predictFcn(Trainfeatures1) ;
%EnsembleMdl=trainedTuneEnsemble.ClassificationEnsemble;
%[labels,score] = predict(EnsembleMdl,X_tot);
figure;
confusionchart(Y_training,yfitNeuralNetworktrain)
title ( 'Neural Network Model - Train set')
figure;
confusionchart(Y_training,yfitEnsembletrain)
title ( 'Ensemble Model - Train set')
%% test and train for Tune Ensemble 
figure;
confusionchart(Y_test,yfitTuneEnsemble)
title ( 'Tune Ensemble Model - Test set')
figure;
confusionchart(Y_training,yfitTuneEnsembletrain)
title ( 'Tune Ensemble Model - Train set')
figure;
confmatEnsamble=confusionchart(Y_training,yfitTuneEnsembletrain);
%% confution matrix for Tune Ensemble - default
X_tot=[table2array(Trainfeatures1);table2array(Testfeatures1)];
names=Testfeatures1.Properties.VariableNames;
X_tot=array2table(X_tot);
X_tot.Properties.VariableNames=names;
yfitTuneEnsembletotal = trainedTuneEnsemble.predictFcn(X_tot) ;
EnsembleMdl=trainedTuneEnsemble.ClassificationEnsemble;
[labels,score] = predict(EnsembleMdl,X_tot);
figure
confusionchart( table2array(X_tot(:,end)),yfitTuneEnsembletotal)
title ( 'Tune Ensemble Model ')
% confmatEnsamble=confusionchart(Y,yfitTuneEnsembletotal);
%%  confution matrix for Tune Ensemble - sensitivity = 90%
TP=0;%confusionmat(1);
FP=290;%confusionmat(2);
FN=2;%confusionmat(3);
TN=773;%confusionmat(4);
sens=0.9;% %sensitivity = [ (TP/TP+FN)] 
TP_new=floor(sens*(TP+FN));
FPR=0.908; % false positive rate
spes=1-FPR; %TN/TN+FP
TN_new=floor(spes*(TN+FP));
FN_new=FN+TP-TP_new;
FP_new= FP+TN-TN_new;
conf_new_sen=[TP_new,FN_new;FP_new,TN_new]; % 261    29; 704    71
%%  confution matrix for Tune Ensemble - PPV = 90%
PPV=0.9;
TP_PPV=floor((TP+FP)*PPV);
FN_PPV=FN;%+TP-TP_PPV;
FP_PPV=FP+TP-TP_PPV;
TN_PPV=TN;%(TP+TN+FP+FN)-(TP_PPV+FP_PPV+FN_PPV);
conf_new_PPV=[TP_PPV,FN_PPV;FP_PPV,TN_PPV]; %    1   289; 1   774
%% PPV and sensitivity
[x,y]=perfcurve(labels,score(:,2),1,'Xcrit','PPV','Ycrit','tpr');
indsens=find(x>=0.9);
indppv=find(y>=0.9);
Y_new=labels;
Y_PPV=labels;
Y_new(1:indsens)=0;
Y_PPV(1:indppv)=0;
figure;
confusionchart(Y,Y_PPV)
title ('90% PPV')
figure;
confusionchart(Y,Y_new)
title('90% Sensitivity')
%% Save the best model and the
save('trainedTuneEnsemble.mat', 'trainedTuneEnsemble') % best model - with optimization
save('confmatEnsamble.mat','confmatEnsamble')
%% 
save('trainedEnsemble.mat', 'trainedEnsemble') % model 1
save('trainedNeuralNetwork.mat', 'trainedNeuralNetwork') % model 2
save('names.mat','names')
save('Testfeatures.mat','Testfeatures')
%%
save('Trainfeatures.mat','Trainfeatures')
