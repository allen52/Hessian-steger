function [row]=adjBRC(row,height,sign)
            if(sign==-1)
            row=row-30;
            if((row<1))
                row=1;
%             else
%                 row=row;
            end
            elseif(sign==1)
                row=row+30;
                if(row>height)
                    row=height;
                end
            else
                return;
            end           
end