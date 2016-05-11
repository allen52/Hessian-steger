function [col]=adjBC(col,width,sign)
            if(sign==-1)
            col=col-15;
            if((col<1))
                col=1;
%             else
%                 col=col;
            end
            elseif(sign==1)
                col=col+15;
                if(col>width)
                    col=width;
                end
            else
                return;
            end           
end