function [ results, signal_e ] = AEWMA( signal, signalref,dmin,dmax, arl )
% Calculation of detection with AEWMA chart

%% desired parameters
delta_min=dmin; 
delta_max=dmax; 
arl_desired=arl;
[ lambda, k ] = GetParams( delta_min, delta_max, arl_desired );

%% respect to the control limit
% stand_dev=std(signalref-limit);
% mu=limit;

%% respect to the new signals
% temp1=(signalref-limit);
% temp2=(signal-limit);
% signal=temp2;
% 
% stand_dev=std(temp1);
% mu=mean(temp1);

%% respect to the reference signal
stand_dev=std(signalref);
mu=mean(signalref);

%% detecting mean shifts
% initialization
signal_e=0;

for i=1:length(signal)
    
    if i==1    
        e=0;
        [ weight ] = GetAdaptiveWeight( e, lambda, k  );
        signal_e(i)=signal(i);         
    else
        e=signal_e(i-1)-signal(i);
        [ weight ] = GetAdaptiveWeight( e, lambda, k  );
        signal_e(i)=weight*signal(i)+(1-weight)*signal_e(i-1);        
    end    
    
    limit(i)=mu+3*stand_dev;
        
    if signal_e(i) - mu > 3*stand_dev
        results(i)=1;
    else
        results(i)=0;
    end
    
end


end

function [ lambda, k ] = GetParams( delta_min, delta_max, arl_desired )
lambda = log( 1.2219 - 0.04697*log(arl_desired)+0.45985*sqrt(delta_min)...
    - 0.02701*sqrt(delta_max) );

k = sqrt( 4.846 + 1.5852*log(arl_desired) - 2.8679*sqrt(delta_min)...
    -1.7198*sqrt(delta_max) );
end

%% Huber Function 
function [ weight ] = GetAdaptiveWeight( e, lambda, k  )

if e < -k
    fi= e+ (1-lambda)*k;
elseif e > k
     fi= e- (1-lambda)*k;
else
    fi= lambda*e;
end
weight=fi/e;

end

%% Tukey’s bisquare function Function 
% function [ weight ] = GetAdaptiveWeight( e, lambda, k  )
% 
% if abs(e) <= k
%     fi= e*(1 - (1-lambda)*(1-(e/k)^(2)))^(2);
% else
%      fi= e;
% end
% weight=fi/e;
% 
% end