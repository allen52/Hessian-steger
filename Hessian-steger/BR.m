function [row]=BR(row,height)
            if(row<=0)
                row=1-row;
            elseif(row>height)
                row=height+height-row;
            end
end