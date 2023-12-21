function [Xtrain, Xval] = GetData_CV(X,ktot,prop)
    
    sizeData = size(X);
    SData = sizeData(2);
    cantTest = round(sizeData(1)*(1-prop));
    cantVal = sizeData(1) - cantTest;
    Xtrain = zeros(cantTest,SData,ktot);
    Xval = zeros(cantVal,SData,ktot);
    
    
   for k = 1:ktot
       for i = 1:sizeData(1)
       
            if ( (i > (k-1)*cantVal) && (i <= k*cantVal) )
                ind = (k-1)*cantVal;
                Xval(i-ind,:,k) = X(i,:);
            end

            if (i <= (k-1)*cantVal)
                Xtrain(i,:,k) = X(i,:);    
            end

            if (i > k*cantVal)
                ind = k*cantVal;
                Xtrain(i-ind,:,k) = X(i,:);
            end
        
       end
       
   end
    

end