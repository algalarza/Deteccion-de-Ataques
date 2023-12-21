function Y_ = Atk_seleccionados(Y,selec)

[samples,~] = size(Y);
[~,cant] = size(selec);

Y_ = zeros(samples,1);
ant = Y(1);
atk = 0;
ind = 1;
encontrado = 0;

    for ii = 1:samples
        
        if(Y(ii) == 1 && ant == 0)
            atk = atk + 1;
            ant = Y(ii);
            if(atk == selec(1,ind))
                Y_(ii) = 1;
                encontrado = 1;
            end
        elseif(Y(ii) == 1 && ant == 1)
            if(atk == selec(1,ind))
                Y_(ii) = 1;
            end
        elseif(Y(ii) == 0 && ant == 1)
            ant = Y(ii);
            if(encontrado == 1)
                encontrado = 0;
                ind = ind + 1;
                if(ind>cant)
                    break;
                end
            end
        end
        
        
            
    end


end