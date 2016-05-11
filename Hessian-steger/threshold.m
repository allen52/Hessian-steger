function rl=threshold(image,min)
[height,width]=size(image);
num=1;
inside=0;
for r=1:height
    for c=1:width
        if(image(r,c)>=min)
            if(inside~=1)
                inside=1;
                rl(num).r=r;
                rl(num).cb=c;
            end             
        else
            if(inside)
                inside=0;
                rl(num).ce=c-1;
                num=num+1;
            end
        end
    end
    if(inside)
        inside=0;
        rl(num).ce=width-1;
        num=num+1;
    end

end