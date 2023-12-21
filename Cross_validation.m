% 1: Cross_Validation ****
% 2: Autoencoders_Train 
% 3: Autoencoders_Test 

%================= Cross Validation ================= 
clear  
clc

load('batadal.mat')

X = dataset1;


%% -----------------------Initialization------------------------
[X1, D1] = Remove_var_cat(X);           % X1: continuous variables of dataset 1 
                                        % D1: discrete variables of dataset
%
[X1] = Remove_Outliers00(X1);           % Remove Outliers of dataset1
[X1_,m,sigma] = zscore(X1);             % Normalice data with mean value=0 and standar deviation=1

%------------------------Parameters---------------------------
[totalData,~] = size(X);
folds = 5;
prop = 0.2;
ktot = 5;

dim = 25;
since = 21;

atkAEs_det = cell(folds,dim);
MSEs = zeros(folds,dim);

[XTrain,XVal] = GetData_CV(X1_,ktot,prop);  % Sets de datos for Cross Validation

for ii = since:dim
    for j = 1:folds
    
    X1 = XTrain(:,:,j);
    [samples,var] = size(X1);

    % ------------------- TRAIN -----------------------
    Xtrain = X1';
    Xval = XVal(:,:,j)';

    
        % Train
        AE = trainAutoencoder(Xtrain, ii, 'MaxEpochs', 3000,...
            'EncoderTransferFunction','logsig',...
            'DecoderTransferFunction','purelin',...
            'ShowProgressWindow',true,...
            'L2WeightRegularization', 0.001,...
            'SparsityRegularization',1,...
            'SparsityProportion',0.99);

        % Validation
        Xval_ = predict(AE,Xval);  
        atkAEs_det{j,ii} = AE;
        MSE = mse(Xval-Xval_);
        MSEs(j,ii) = MSE;
        
        disp("Dim : "+ii+" Fold : "+j+" MSE: "+MSE+"");

    end
end

% Selection of best hyperparameters

mse_average = sum(MSEs);               
fold = ones(size(mse_average))*folds;
mse_average = mse_average./fold
