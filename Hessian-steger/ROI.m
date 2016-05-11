clc
clear
I=imread('test001.jpg');  
figure (1)
imshow(I);
k = waitforbuttonpress;              % 等待鼠标按下
point1 = get(gca,'CurrentPoint');    % 鼠标按下了
finalRect = rbbox;                   %
point2 = get(gca,'CurrentPoint');    % 鼠标松开了
point1 = point1(1,1:2);              % 提取出两个点
point2 = point2(1,1:2);
p1 = min(floor(point1),floor(point2));             % 计算位置
p2 = max(floor(point1),floor(point2));
offset = abs(floor(point1)-floor(point2));
width =offset(1);% offset(1)表示宽，offset(2)表示高
height=offset(2);
img1=zeros(height,width);
transXY=offset;
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on                              %防止plot时闪烁
plot(x,y,'r');
for i=1:height
    for j=1:width
        img1(i,j)=double(I(p1(2)+i,p1(1)+j));
    end
end

