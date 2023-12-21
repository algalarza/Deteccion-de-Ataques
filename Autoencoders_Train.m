% 1: Cross_Validation
% 2: Autoencoders_Train ****
% 3: Autoencoders_Test

% ================= Autoencoder TRAIN =================

clear
clc

load('batadal.mat')

[X1, D1] = Remove_var_cat(dataset1);      % Xn: continuous variables of datasetn 
                                            % Dn: discrete variables of datasetn
[X1] = Remove_Outliers00(X1);             % Remove Outliers of dataset1
[samples,var] = size(X1);

[X1_,m,sigma] = zscore(X1);                % Normalice normal data

%% ------------------- TRAIN -----------------------
Xtrain = X1_';
Xval = X1_';

dim = 24;

   %% Train autoencoder
    AE_det = trainAutoencoder(Xtrain, dim, 'MaxEpochs', 3000,...
        'EncoderTransferFunction','logsig',...
        'DecoderTransferFunction','purelin',...
        'ShowProgressWindow',true,...
        'L2WeightRegularization', 0.001,...
        'SparsityRegularization',1,...
        'SparsityProportion',0.99);

    Xval_ = predict(AE_det,Xval);                           % Output prediction
    SPE = diag(sqrt((Xval - Xval_)' * (Xval - Xval_)));     % Prediction error (SPE)
    MSE = mse(Xval - Xval_)
     

%% Save
save atkAEs_det.mat AE_det SPE