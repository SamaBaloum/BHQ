# BHQ
In this Project we used data sampeled by BHQ application,and used it as features for our classification Problem. The classification Problem we chose is : Weekday vs. weekend.
1)Extract_Features: this function take the BHQ data as Input, which include the data for a some user and specific day, and produce 35 features and return X_row as output,
which is the features. 
2) normolize_feature: this function take a feature column for a user and normolise the feature by dividing by basline ( which is two weeks) and return as output a normolized feature.
3) extract_selcted_features: this function take the BHQ data as Input, which include the data for a some user and specific day, and produce 26 features and return X_row as output,
which is the features. 
4) main: take the model and names of table as input and produce confution matrix using ensemble model for all data as an output.
5) trainNeuralNetwork,trainTuneEnsemble,trainEnsemble: this are the generated function after using the classification learner app.
scripts:
1) main_Final_BHQ: the main function we build
