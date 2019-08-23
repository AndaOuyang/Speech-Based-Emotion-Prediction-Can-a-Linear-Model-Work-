function prediction_label = ARX_prediction(features, AR, X)

% features is a matrix, AR is an array, X is a cell

% Code by Anda Ouyang (Feb 2019)


[len, Dimension_features] = size(features);

prediction_label = 0;
for ii = 1:Dimension_features
    prediction_label = prediction_label + filter(X{ii}, 1, features(:,ii));
end
prediction_label = filter(1, AR, prediction_label);
