function normolizaed_features = features_normalization(features, mean_features, std_features)

% remove mean and deviation

normolizaed_features = zeros(size(features));
ncol = size(features, 2);
for j = 1:ncol
    normolizaed_features(:,j) = (features(:,j) - mean_features(j)) / std_features(j);
end
