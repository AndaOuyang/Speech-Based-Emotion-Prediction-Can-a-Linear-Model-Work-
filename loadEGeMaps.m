function [training_label, training_features, validation_label, validation_features] = loadEGeMaps(chosen_emotion_dimension)

% This function will fail because I can't provide RECOLA database for you. 
% you may obtain the database by yourself and extrac the eGeMaps features
%
% function output: 
% training_label      ==> 67509*1  double array
% training_features   ==> 67509*1  double array
% validation_label    ==> 67509*88 double matrix
% validation_features ==> 67509*88 double matrix
%
% This function read annotation labels and eGeMaps features in RECOLA
% database
% 
% The features are normalized by subtracting mean and dividing standard
% deviation of training set features
%
% The AVEC2016_GT_dev.mat and AVEC2016_GT_train.mat are the ground truth
% labels of RECOLA database for development set and training set, as in
% AVEC2016
%
% The AVEC2016_dev_Audio.mat and AVEC2016_train_Audio.mat are eGeMaps 
% features

%% load file
load_struct=load('AVEC2016_train_Audio.mat');
variables=fields(load_struct);
audio_features_training = load_struct.(variables{1});

load_struct=load('AVEC2016_dev_Audio.mat');
variables=fields(load_struct);
audio_features_validation = load_struct.(variables{1});

load_struct=load('AVEC2016_GT_train.mat');
variables=fields(load_struct);
label_training = load_struct.(variables{1});

load_struct=load('AVEC2016_GT_dev.mat');
variables=fields(load_struct);
label_validation = load_struct.(variables{1});





%% cascade all the mean_annotations and features for training
training_label = []; % ground truth label (average among annotators)
training_features = []; %% 88 dimensional eGeMaps features
for fn = 1:9
    training_label = [training_label; label_training{fn, chosen_emotion_dimension}];
    training_features = [training_features; audio_features_training{fn}];
end
mean_features = mean(training_features);
std_features  = std(training_features);
training_features = features_normalization(training_features, mean_features, std_features);






validation_label = [];
validation_features = [];
for n = 1:9
    validation_label = [validation_label; label_validation{n,chosen_emotion_dimension}];
    validation_features = [validation_features; audio_features_validation{n}];
end


validation_features = features_normalization(validation_features, mean_features, std_features);