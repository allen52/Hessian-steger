%I=(imread('C:\Users\melo\Desktop\Hessinan矩阵法\test\testimage\0312\test\image005.jpg')); 
function [tranXY,img2]=imgcrop(I)
level=graythresh(I);
BW=im2bw(I,level);
I=im2uint8(I);
%figure(1)
%imshow(I);
%hold on;
[Iheight,Iwidth]=size(I);
[height,width]=size(BW);
k=1;
inside=0;
for i=1:height
    for j=1:width
        bw=BW(i,j)-1;
        if(~bw)
            if(inside~=1)
                inside=1;
            rl.r(k)=i;
            rl.cb(k)=j;
            end
        else
            if(inside)
                inside=0;
                rl.ce(k)=j;
                k=k+1;
            end
        end
        
    end
    if(inside)
        inside=0;
        rl.ce(k)=width-1;
        k=k+1;
    end
    
end
rmin=min(rl.r);
rmax=max(rl.r);
cmin=min(rl.cb);
cmax=max(rl.ce);

%function [row]=adjBRC(row,height,sign)

p1=[adjBRC(rmin,Iheight,-1),adjBRC(cmin,Iwidth,-1)];
p2=[adjBRC(rmax,Iheight,1),adjBRC(cmax,Iwidth,1)];
tranXY=p1;
offset=floor(p2-p1);
%plot(x,y,'r');
width =offset(2);% offset(1)表示高，offset(2)表示宽
height=offset(1);
% x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
% y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
% hold on                              %防止plot时闪烁
% plot(y,x,'r');
img2=zeros(height,width);
for i=1:height
    for j=1:width
        img2(i,j)=I(p1(1)+i,p1(2)+j);
    end
end
end
%figure (2);
%imshow(img2);

