function [ y,index,predict_f] = Postprocess_binomial( train_label,predict_test,test_label,binomialcoff )
%   Post processing for emotion predictions
%   This function applies three post_processing methods for predictions,
%   and then calculates the CCC for each processed predictions. The method
%   with maximum CCC is chosen as the post-processing method

% Input:
% train_label: training labels in cell: 9x1 cells indicating 9 train speakers
% predict_test: predictions of test speakers in cell: 9x1 cells indicating 9 test predictions
% test_label: real test labels in cell: 9x1 cells indicating 9 test speakers' real labels for CCC calculation
% binomialcoff: binomial filter coefficients for smoothing

% Output:
% y: CCC and CC for the optimal post processing method
% index: optimal method index for maximum CCC and CC
% predict_f: final prediction after post processing

%%%%%%%%%%%%%%%%%%%%%%%%%%Post processing with delay compensation%%%%%%%%%%%%%%%%%%%%%

train_gt=cell2mat(train_label');% real training groudtruth

%center prediction
pred=cell2mat(predict_test');% test predictions
mean_ref=mean(train_gt);
mean_pred=mean(pred);

bias=mean_ref-mean_pred;
pred_center=(pred+repmat(bias,size(pred,1),1));%center

%scale prediction
std_ref=std(train_gt);
std_pred=std(pred);
scale=std_ref./std_pred;
pred_scale=(pred.*repmat(scale,size(pred,1),1));%center

%both center and scale prediction
pred_scale_all=(pred_center.*repmat(scale,size(pred,1),1));%center

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%divide predictions to 9 speakers and storing in cells for smoothing
%purpose
for ii=1:length(predict_test)
    predict_center{ii}=pred_center(1:size(predict_test{ii},1),:);
    pred_center(1:size(predict_test{ii},1),:)=[];
    
    predict_scale{ii}=pred_scale(1:size(predict_test{ii},1),:);
    pred_scale(1:size(predict_test{ii},1),:)=[];
    
    predict_scale_all{ii}=pred_scale_all(1:size(predict_test{ii},1),:);
    pred_scale_all(1:size(predict_test{ii},1),:)=[];
end

% Avoid the inf and nan values
pred_center(isnan(pred_center))=0;
pred_center(isinf(pred_center))=0;

pred_scale(isnan(pred_scale))=0;
pred_scale(isinf(pred_scale))=0;

pred_scale_all(isnan(pred_scale_all))=0;
pred_scale_all(isinf(pred_scale_all))=0;

%%
for i_spkr=1:length(predict_test)% 9 test speakers
    
    yDV_SMOOTH_media{i_spkr} = filter(binomialcoff, 1, predict_test{i_spkr})';%% smoothing/filtering will cause delay
    
    yDV_SMOOTH_media_center{i_spkr} = filter(binomialcoff, 1, predict_center{i_spkr})';
    
    yDV_SMOOTH_media_scale{i_spkr}= filter(binomialcoff, 1, predict_scale{i_spkr})';
    
    yDV_SMOOTH_media_scale_all{i_spkr} = filter(binomialcoff, 1, predict_scale_all{i_spkr})';
    
end

%%
predict_a1=cell2mat(yDV_SMOOTH_media)';
predict_a2=cell2mat(yDV_SMOOTH_media_center)';
predict_a3=cell2mat(yDV_SMOOTH_media_scale)';
predict_a4=cell2mat(yDV_SMOOTH_media_scale_all)';

truth_f=cell2mat(test_label');% real test labels

ccc(1)=ccc_calculation(predict_a1,truth_f); % original CCC
ccc(2)=ccc_calculation(predict_a2,truth_f); % CCC with mean shift
ccc(3)=ccc_calculation(predict_a3,truth_f); % CCC with scaling
ccc(4)=ccc_calculation(predict_a4,truth_f) % CCC with both mean shift and scaling

cc(1)=corr(predict_a1,truth_f); % original CC
cc(2)=corr(predict_a2,truth_f); % CC with mean shift
cc(3)=corr(predict_a3,truth_f); % CC with scaling
cc(4)=corr(predict_a4,truth_f) % CC with both mean shift and scaling

[y1,index1]=max(ccc) % finding which post_processing gives the best performance
[y2,index2]=max(cc)

y=[y1;y2];
index=[index1;index2];

switch index1
    case 1
        predict_f=predict_a1;
    case 2
        predict_f=predict_a2;
    case 3
        predict_f=predict_a3;
    case 4
        predict_f=predict_a4;
end
end

