% 1: Cross_Validation
% 2: Autoencoders_Train 
% 3: Autoencoders_Test  ****

% ===================== Autoencoders TEST ======================
clear
clc

load('batadal.mat')
load('atkAEs_det.mat')
load('Batadal_result.mat')

% Xn: continuous variables of datasetn 
% Dn: discrete variables of datasetn
[X1, D1] = Remove_var_cat(dataset1);      
[X2, D2] = Remove_var_cat(dataset2);
[X3, D3] = Remove_var_cat(dataset3);

[X1] = Remove_Outliers00(X1);             % Remove Outliers of dataset1

[samples,~] = size(X3);

[X1_,m,sigma] = zscore(X1);                 % Normalice normal data
[~,var] = size(X3);

for i = 1:samples                           % Normalice attack data
    aux = X3(i,:) - m;
    for j = 1:var
        Xtest(i,j) = aux(j)/sigma(j);
    end
    
end

Xtest = Xtest';
Ytest = labels3;

%% TEST
    
P_Xtest = predict(AE_det,Xtest);                                    % Output prediction
P_SPE = diag(sqrt((Xtest - P_Xtest)' * (Xtest - P_Xtest)));         % Prediction error (SPE)

% AEWMA parameters
arl = 400;
d2 = 5;     % maximum delta
d = 0.25;   % minimun delta

[atks_det,~] = AEWMA(P_SPE,SPE,d,d2,arl);           % Classify output in attack (1) or not attack (0)
atks_det = atks_det';
    

%% Classification check

Result = zeros(7,1);
    
    tot_A = 0;
    tot_NA = 0;
    TP = 0;                     % System under attack and attack detected    
    TN = 0;                     % System without attack and without attack detection
    FP = 0;                     % System under attack and without attack detection
    FN = 0;                     % System without attack and attack detected
    
    for ii = 1:samples
            if((Ytest(ii,1) == 1) && (atks_det(ii,1) == 1))
                TP = TP + 1;
            elseif ((Ytest(ii,1) == 0) && (atks_det(ii,1) == 0))
                TN = TN + 1;
            elseif ((Ytest(ii,1) == 0) && (atks_det(ii,1) == 1))
                FP = FP + 1;
            elseif ((Ytest(ii,1) == 1) && (atks_det(ii,1) == 0))
                FN = FN + 1;
            end
    end
    
    TPR = TP/(TP + FN);                                 %TPR = TP/(TP + FN) True Positive Rate
    TNR = TN/(FP + TN);                                 %TNR = TN/(FP + TN) True Negative Rate
    Sclf = (TPR + TNR)/2; 
    FAR = (FP/(FP+TN))*100;
    FDR = TPR*100;
    TP;
    FN;
    recall = TP/(TP+FN)
    precision = TP/(TP+FP)
    F1 = 2*(recall*precision)/(recall+precision)
    
 
ms(1,1) = FDR;
ms(1,2) = FAR;
ms(1,3) = arl;
ms(1,4) = d;
ms(1,5) = d2;

X = ['ARL :',num2str(arl)];
disp(X)
disp('')


%% Checking fast detection

gamma = 0.5;
na = 0;
td = 0;
t0 = 0;
TTD = zeros(1,1);
flag = 0;
delta_t = zeros(1,1);

for ii = 1:samples
    
    if(ii == 1)
        
        if(Ytest(ii,1) == 1)
            t0 = ii;
            na = na + 1;
        end
        if(atks_det(ii,1) == 1)
            td = ii;
            flag = 1;
        end
        
    elseif(Ytest(ii,1)==1 && Ytest(ii-1,1)==0)
        t0 = ii;
        na = na + 1;
        if(atks_det(ii,1)== 1)
            td = ii;
            flag = 1;
        end
    elseif(Ytest(ii,1)==1 && Ytest(ii-1,1)==1)
        if(atks_det(ii,1)==1 && flag == 0)
            td = ii;
            flag = 1;
        end
    elseif(Ytest(ii,1)==0 && Ytest(ii-1,1)==1)
        flag = 0;
        TTD(na,1) = td - t0;
        delta_t(na,1) = ii - t0;
    end
end

sum_aux = 0;
for ii = 1:na
    
    aux = TTD(ii,1)/delta_t(ii,1);
    sum_aux = sum_aux + aux;

end

STTD = 1 - ( (1/na)*sum_aux ) 
Sclf
S = gamma * STTD + (1-gamma)*Sclf

%% To point out the False alarms in the figures
[atks_det1,signal_e] = AEWMA(P_SPE,SPE,d,d2,arl);

value_fa = 0;
times_fa = 0;
cont = 1;
for ii = 1:samples
    if(atks_det(ii,1)>Ytest(ii,1))
        times_fa(cont) = ii;
        value_fa(cont) = signal_e(1,ii);
        cont = cont +1;
    end
    
end


%% Show results

figure
plot(P_SPE);grid on; hold on; plot(Ytest*3);
legend('SPE de Xtest', 'Attacks');

figure
plot(atks_det1,'linewidth',1.5);grid on; hold on; plot(Ytest);
legend('SPE', 'Attack interval');
title('Detection')

P_SPE1 = P_SPE;

figure
a = area(atks_det1); 
a.FaceColor = 'black';
a.FaceAlpha = 0.2;
a.LineStyle = 'none';
e = {'no-attack','attack'};
set(gca,'YTick',0:1:length(e)+1);
set(gca,'YTickLabel',e);
set(gca,'XTick',0:100:samples+1);
hold on;
plot(Ytest,'Color', 'black');
legend('detected attacks','real attacks')

figure
umbral = ones(samples,1)*1.0385;
falsa_alarma = atks_det1' - Ytest;
p = plot(signal_e);
p.Color = [0 0.4470 0.7410];
p.LineWidth = 1.5;
hold on;
plot(Ytest*10,'Color','black');
hold on;
p = plot(umbral,'Color','red');
p.LineWidth = 1.5;
hold on;
p = plot(times_fa,value_fa,'o');
p.Color = [0.4660 0.6740 0.1880];
ylabel('Attack Indicator');
xlabel('Observations');
legend('z(t)','time interval of attack','limit of control chart','false alarm')


%% Save
save atks_det1.mat atks_det1
save P_SPE1.mat P_SPE1

