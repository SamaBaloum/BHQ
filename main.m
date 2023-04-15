function [confutionmMat]= main(model,names)
% Please run the following line : [confutionmMat]= main('trainedTuneEnsemble.mat','names.mat')
%This function may take a bit long time for running
% Inputs:
% model = trainedTuneEnsemble;
% names =Testfeatures.Properties.VariableNames;
FilesBHQ=[328,330,331,332,334,336,338,339,340,341,345,351,353,354,358,359,360,370,371,372];
load(model);
load(names);
X=zeros(10000,26)-99;    % Allocate memory for matrix X, with default value -99
Y=zeros(10000,1)-99; % Allocate memory for label vector Y
n_instance=0;
n_instance_vec=[];
j=0;
 for r=1:length(FilesBHQ)
    %filename=337;%FilesBHQ(r);
    [~, ~, raw]=xlsread(num2str(FilesBHQ(r)));
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
         X_row=extract_selcted_features(D,accelerometer,activity_recognition,battery,bluetooth,calls,gyroscope,...
     light,location,screen_state,wireless);
        n_instance=n_instance+1;
          X(n_instance,:)=X_row;
        [DayNumber,~] = weekday(D); %Labels Vector Weekday vs. weekend
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
%% replace NaN values with the mean
[m,n]=find(isnan(norm_f));
norm_f(isnan(norm_f))=0;
for i=1:length(m)
    norm_f(m(i),n(i))=mean(norm_f(:,n(i)));
end
norm_f(~isfinite(norm_f))=0;
%%
X_tot=[norm_f,Y];
%names=Testfeatures.Properties.VariableNames;
X_tot=array2table(X_tot);
X_tot.Properties.VariableNames=names;
EnsembleMdl=trainedTuneEnsemble.ClassificationEnsemble;
[labels,score] = predict(EnsembleMdl,X_tot);
%%
%yfit = model.predictFcn(X_tot) ;
figure;
confusionchart(Y,labels)
title ( 'Tune Ensemble Model ')
confutionmMat=confusionchart(Y,labels);
end
