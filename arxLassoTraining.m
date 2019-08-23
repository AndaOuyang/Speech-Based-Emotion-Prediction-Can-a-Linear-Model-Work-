function [AR, X, b, fitinfo] = arxLassoTraining(y, x, order_AR, order_X, delay_X, lambda)

% Ouyang, A., Dang, T., Sethu, V., and Ambikairajah, E., (accepted 2019),
% "Speech Based Emotion Prediction: Can a Linear Model Work?", 
% in INTERSPEECH, 2019.

% Code by Anda Ouyang (Feb 2019)

nt = length(y); %% length of training data
np = order_AR + order_X; %% number of parameters to estimate
dimension_X = size(x,2);
J = zeros(nt, np);


%% J = [yt, u(t-delay), u(t-delay-1), ... u(t-nb)]
for t = 1:order_AR
    for j = 1:t-1
        J(t,j) = y(t-j);
    end
end

for t = order_AR+1:nt
%     t-1:-1:t-order_AR
    J(t, 1:order_AR) = y(t-1:-1:t-order_AR);
end

for t = delay_X+1:min(delay_X+order_X, nt)
    begin_location = order_AR+1;
    for i = 1:t-delay_X
%         str = x(t-i+1 : t-i+dimension_B)
        J(t, begin_location:begin_location+dimension_X-1) = x(t-i+1-delay_X,:);
        begin_location = begin_location+dimension_X;
    end
end

if delay_X+order_X < nt
    for t = delay_X+order_X+1:nt
            begin_location = order_AR+1;
            for i = 1:order_X
                J(t, begin_location:begin_location+dimension_X-1) = x(t-i+1-delay_X,:);
                begin_location = begin_location+dimension_X;
            end
    end
end



[b, fitinfo] = lasso(J, y, 'Lambda', lambda);
theta1 = b(:,1); %% estimated parameters

% theta2 = (J.' * J) \(J.' * y ); %% direct linear regression, same as matlab ARX model
% diff_theta = theta2 - theta1


% error_in_prediction = y - J * theta1;
% mean_error = mean(error_in_prediction);
% std_error = std(error_in_prediction);

AR = [1; -theta1(1:order_AR)].';

for i = 1:order_X 
    B_matrix(i,:) = theta1(order_AR + (i-1)*dimension_X + 1 : order_AR + i*dimension_X).';
end

for i = 1:dimension_X
    X{i} = [zeros(1,delay_X), B_matrix(:,i).'];
end


%%
% figure()
% length_of_labmda = length(lambda)
% if length(lambda) > 2
% lassoPlot(b,fitinfo,'PlotType','Lambda','XScale','log');
% end
