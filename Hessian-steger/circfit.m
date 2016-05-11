function [centerpt] = circfit(nPointW,vc)
%CIRCFIT Fits a circle in x,y plane
% [XC, YC, R, A] = CIRCFIT(X,Y)
% Result is center point (yc,xc) and radius R.A is an

% optional output describing the circle's equation:
% x^2+y^2+a(1)*x+a(2)*y+a(3)=0
%vc=pan_vector;
[~,sizeW]=size(nPointW);
a=vc(1);
b=vc(2);
c=vc(3);
d=vc(4);
a2=a*a;
b2=b*b;
c2=c*c;
NewZ=[a b c];
pt1=[0 0 0];
if(abs(a)<abs(b))
    pt1(1)=1;
else
    pt1(2)=1;
end
k1=-(a*pt1(1)+b*pt1(2)+c*pt1(3)+d)/(a2+b2+c2);
k0=-d/(a2+b2+c2);
originpt=[k0*a k0*b k0*c];
projpt=[pt1(1)+k1*a pt1(2)+k1*b pt1(2)+k1*c];
if(abs(a)<abs(b))
    NewX=projpt-originpt;
    NewY=cross(NewZ,NewX);
else
    NewY=projpt-originpt;
    NewX=cross(NewY,NewZ);
end

for i=1:sizeW
PointW=nPointW(i).PointW;
pos=[PointW(:,1)-originpt(1),PointW(:,2)-originpt(2),PointW(:,3)-originpt(3)];
[nSize,~]=size(pos);
for j=1:nSize
    pt2d(i).x(j)=dot(pos(j,:),NewX);
    pt2d(i).y(j)=dot(pos(j,:),NewY);
    pt2d(i).z(j)=dot(pos(j,:),NewZ);
end
clear pos;
end
for i=1:sizeW
    x=pt2d(i).x;
    y=pt2d(i).y;
    z=pt2d(i).z;
    zmean=mean(z);
    n=length(x);
    xx=x.*x;
    yy=y.*y;
    xy=x.*y;
    A=[sum(x) sum(y) n;sum(xy) sum(yy)...
    sum(y);sum(xx) sum(xy) sum(x)];
    B=[-sum(xx+yy) ; -sum(xx.*y+yy.*y) ; -sum(xx.*x+xy.*y)];
    a=A\B;
    centerpt(i).pos(1,1) = -.5*a(1);
    centerpt(i).pos(1,2) = -.5*a(2);
    centerpt(i).pos(1,3) =zmean;
    centerpt(i).R = sqrt((a(1)^2+a(2)^2)/4-a(3));
end

end