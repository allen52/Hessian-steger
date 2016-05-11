close all;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%手动裁剪图片%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I=(imread('C:\Users\melo\Desktop\circletest\标准圆R=500Width=12.jpg')); 
% figure (1)
% imshow(I);
% hold on;
% k = waitforbuttonpress;              % 等待鼠标按下
% point1 = get(gca,'CurrentPoint');    % 鼠标按下了
% finalRect = rbbox;                   %
% point2 = get(gca,'CurrentPoint');    % 鼠标松开了
% point1 = point1(1,1:2);              % 提取出两个点
% point2 = point2(1,1:2);
% p1 = min(floor(point1),floor(point2));             % 计算位置
% p2 = max(floor(point1),floor(point2));
% offset = abs(floor(point1)-floor(point2));
% width =offset(1);% offset(1)表示宽，offset(2)表示高
% height=offset(2);
% img=zeros(height,width);
% tranXY=p1;
% trany(1)=tranXY(1,1);
% tranx(1)=tranXY(1,2);
% % trantemp=tranXY(1,1);
% % tranXY(1,1)=tranXY(1,2);
% % tranXY(1,2)=trantemp;
% %tranXY=tranXY';
% x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
% y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
% hold on                              %防止plot时闪烁
% plot(x,y,'r');
% for i=1:height
%     for j=1:width
%         img(i,j)=double(I(p1(2)+i,p1(1)+j));
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%图像处理main函数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取图像并裁剪%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
t1=clock;
I=(imread ('C:\Users\melo\Desktop\test\testimage\0329\test\image002.jpg'));
[tranXY,img]=imgcrop(I);
t2=clock;
time1=etime(t2,t1);%裁剪图像的时间；

%%%%%%%%%%%%%%%%%%%老版本！！！%%%%%%%%%
tranx(1)=tranXY(1,1);
trany(1)=tranXY(1,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[height,width]=size(img);
            sigma=4;
% [~,~,eigVal,n1,n2,p1,p2,dx,dy,ismax]=compute_line_points(img,sigma,1,0,0.34);

%sigma=3.96;
%二阶导数极大值为可能的中心点
%计算最大特征值对应的特征向量
%法线方向为nx ny
%点为px py
[a,eigVec,eigVal,n1,n2,p1,p2,dx,dy,ismax]=compute_line_points(img,sigma,1,0.34,0.85);
t21=clock;
time21=etime(t21,t2);%计算Hessian矩阵和二阶导数极大值点的时间
%计算特征值平均值
mean=0;
for i=1:height
    for j=1:width
        if(eigVal(i,j)>0)
        mean=mean+eigVal(i,j);
        end
    end
end
mean_eig=mean/(width*height);
[num_junc,num_cont,cont,junction,cross]=get_contours(img,ismax,eigVal,n1,n2,p1,p2,sigma,100,1,30,1,dx,dy,width,height,mean_eig);
t22=clock;
time22=etime(t22,t21);%将点连接成线的时间
[~,num_contours]=size(cont);
[contours,correction,asymm]=compute_line_width(dx,dy,width,height,sigma,1,cont,num_contours);
t3=clock;
time23=etime(t3,t22);%计算线宽并用补偿中心的时间
time2=etime(t3,t2);%Hessian矩阵时间；
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%绘图指令%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t4=clock;
time3=etime(t4,t3);%Hessian矩阵时间；
[k,h]=size(p1);
p=1;
for i=1:k
    for j=1:h
        if((p1(i,j)~=0)||(p2(i,j)~=0))
        posx(p)=p1(i,j)+tranx(1);
        posy(p)=p2(i,j)+trany(1);
        end
        p=p+1;
    end   
end
figure(2);
imshow(I);
hold on;
plot(posy,posx,'.');
hold on;
[~,n]=size(cutcont);
for i=1:n
    plot(cutcont(i).col,cutcont(i).row,'-g');
    hold on;
end
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%数据处理%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



