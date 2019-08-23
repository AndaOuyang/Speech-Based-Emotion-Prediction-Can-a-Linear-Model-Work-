clear; clc; close all;

% This script implements linear ARX model in dimensional emotion 
% recognition (Arousal and Valence), validated in RECOLA database.
% 
% Related paper:
% Ouyang, A., Dang, T., Sethu, V., and Ambikairajah, E., (accepted 2019),
% "Speech Based Emotion Prediction: Can a Linear Model Work?", 
% in INTERSPEECH, 2019.
%
% Code by Anda Ouyang (Feb 2019) oy670203125@yahoo.com
% Supervised by Dr. Vidhyasaharan Sethu and Dr. Ting Dang

%% input 
order_AR = 13;
order_X  = 8;
delay_X = 50; %% optimal model for arousal

% order_AR = 15;
% order_X  = 15;
% delay_X = 7; %% optimal model for valence

arousal = 1;
valence = 2;
chosen_emotion_dimension = arousal; %% chose arousal / valence here
lambda = 0; %% lambda for lasso regression

Dimension_features = 88; %% dimension of eGeMaps features is 88
%% load data
Fs = 25;
[training_label, training_features, validation_label, validation_features] = loadEGeMaps(chosen_emotion_dimension);
% This function will fail because I can't provide RECOLA database for you. 
% you need to obtain the database you may obtain the database by yourself 
% and extrac the eGeMaps features
%
% function output: 
% training_label      ==> 67509*1  double array
% training_features   ==> 67509*1  double array
% validation_label    ==> 67509*88 double matrix
% validation_features ==> 67509*88 double matrix

%% training
lambda = [0, lambda];
[AR_parameters, X_parameters, b, fitinfo] = arxLassoTraining(training_label, training_features, order_AR, order_X, delay_X, lambda);

%% prediction and validation
my_pred = ARX_prediction(validation_features, AR_parameters, X_parameters);

raw_cc = corr(my_pred, validation_label)
raw_ccc = ccc_calculation(my_pred, validation_label)


%% post processing
train_label{1} = training_label;
predict_test{1} = my_pred;
test_label{1} = validation_label;
binomialcoff = 1;
[ y,index,predict_f] = Postprocess_binomial( train_label,predict_test,test_label,binomialcoff );
post_proc_index = index(1);
ccc_after_post_processing = y(1)
cc_after_post_processing = y(2)

%% plot the ground truth and ARX prediction

figure()
plot(my_pred,'r')
hold on 
plot(validation_label, 'b')
hold off
legend({'my prediction', 'mean annotation'})
title(['CC = ',num2str(cc_after_post_processing) ,', ccc = ', num2str(ccc_after_post_processing)])