function [col]=BC(col,width)
            if(col<=0)
                col=1-col;
            elseif(col>width)
                col=width+width-col;
            end
end
