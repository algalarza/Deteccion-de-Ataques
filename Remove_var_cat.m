function [out_d, out_cat] = Remove_var_cat(data)

    [f1,c1] = size(data);
    cont_c = 1;
    cont_d = 1;

    for i = 1:c1

        if( i~=9 && i~=11 && i~=12 && i~=13 && i~=15 && i~=16 && i~=17 && i~=19 && i~=20 && i~=21 && i~=23 && i~=24 && i~=25 && i~=27 && i~=28 && i~=29 && i~=31 )
            out_d(:,cont_c) = data(:,i);
            cont_c = cont_c + 1;
        end
        if ( i==9 || i==11 || i==13 || i==15 || i==17 || i==19 || i==21 || i==23 || i==25 || i==27 || i==29 || i==31 )
            out_cat(:,cont_d) = data(:,i);
            cont_d = cont_d + 1;
        end

    end
    
    
end