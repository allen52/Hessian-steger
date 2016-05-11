function [x]=SGN(x)
if(x==0)
    x=0;
else
    if(x>0)
        x=1;
    end
    if(x<0)
        x=-1;
    end
end
end