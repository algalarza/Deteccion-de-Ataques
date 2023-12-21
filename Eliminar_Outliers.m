function [out_d, out_l] = Eliminar_Outliers(data,label)

    [samples,var] = size(data);
    cont = 1;
    
    for i = 1:var
        dev = std(data(:,i));
        med = mean(data(:,i));
        x = data(:,i);
        for j = 1:samples
            if data(j,i)-med>3*dev
                remove(cont) = j;
                cont = cont + 1;
            end         
        end
    end
    
    c = 1;
    s = 1;
    flag = 0;
    for i = 1:samples
        
        for c = 1:cont-1
            if (remove(c) == i)
                flag = 1;
            end      
        end
        
        if(flag == 1)
            flag = 0;
        else
            out_d(s,:) = data(i,:);
            out_l(s) = label(i);
            s = s + 1;

        end
        
    end

end