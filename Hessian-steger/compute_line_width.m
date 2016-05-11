function [out_contours,correct,asymm]=compute_line_width(dx,dy,width,height,sigma,correct_pos,contours,num_contours)
%计算线宽
% global grad_r;
% global grad_l num_line line width_r width_l;
%global width_l grad_l grad_r width_r ;
max_num_points=0;
for i=1:num_contours
    num_points=contours(i).num;
    if(num_points>max_num_points)
        max_num_points=num_points;
    end
end
length=2.5*sigma;
max_line=ceil(length*3);
% line=zeros(1,max_line);
%求梯度图像
for r=1:height
    for c=1:width
        grad(r,c)=sqrt((dx(r,c)*dx(r,c))+(dy(r,c)*dy(r,c)));
    end
end


for i=1:num_contours
    cont=contours(i);
    num_points=cont.num;
    for j=1:num_points
        px=cont.row(j);
        py=cont.col(j);
        pos_x(j)=px;
        pos_y(j)=py;
        r=floor(px+0.5);
        c=floor(py+0.5);
        nx=cos(cont.angle(j));
        ny=sin(cont.angle(j));
       [line,num_line]=bresenham(nx,ny,0,0,length);
       width_r(j)=0;
       width_l(j)=0;
       grad_r(j)=0;
       grad_l(j)=0;
       for dir=-1:2:1
           for k=1:num_line
               x=BR(r+dir*line(k).x,height);
               y=BC(c+dir*line(k).y,width);
               
               i1=grad(BR(x-1,height),BC(y-1,width));
               i2=grad(BR(x-1,height),y);
               i3=grad(BR(x-1,height),BC(y+1,width));
               i4=grad(x,BC(y-1,width));
               i5=grad(x,y);
               i6=grad(x,BC(y+1,width));
               i7=grad(BR(x+1,height),BC(y-1,width));
               i8=grad(BR(x+1,height),y);
               i9=grad(BR(x+1,height),BC(y+1,width));
               t1 = i1+i2+i3;
               t2 = i4+i5+i6;
               t3 = i7+i8+i9;
               t4 = i1+i4+i7;
               t5 = i2+i5+i8;
               t6 = i3+i6+i9;
               dr = (t3-t1)/6;
               dc = (t6-t4)/6;
               drr = (t1-2*t2+t3)/6;
               dcc = (t4-2*t5+t6)/6;
               drc = (i1-i3-i7+i9)/4;
               H1=[2*drr drc;drc 2*dcc];
               [X,B]=eig(H1);                      
               if(abs(B(1,1))>abs(B(2,2)))
                   eigVec1=X(:,1);
                   eigVal1=B(1,1);
               elseif(abs(B(1,1))<abs(B(2,2)))
                   eigVec1=X(:,2);
                   eigVal1=B(2,2);
               else
                   if(B(1,1)<B(2,2))
                       eigVec1=X(:,1);
                       eigVal1=B(1,1);
                   else
                       eigVec1=X(:,2);
                       eigVal1=B(2,2);
                   end
               end
               val=-eigVal1;
               if(val>=0)
                   n1=eigVec1(1,1);
                   n2=eigVec1(2,1);
                   a = 2.0*(drr*n1*n1+drc*n1*n2+dcc*n2*n2);
                   b = dr*n1+dc*n2;
                   if(abs(a)<10^-4)
                       num=0;
                       break;
                   else
                       num=1;
                       t=-b/a;
                   end
                   if(num~=0)
                       p1=t*n1;
                       p2=t*n2;
                       kk1(j)=abs(p1);
                       kk2(j)=abs(p2);
                      if((abs(p1)<=0.6)&&(abs(p2)<=0.6))
                           a=1;
                           b=nx*(px-(r+dir*line(k).x+p1))+ny*(py-(c+dir*line(k).y+p2));
                           t=-b/a;
                           d=(-i1+2*i2-i3+2*i4+5*i5+2*i6-i7+2*i8-i9)/9;
                            if(dir==1)
                                grad_r(j)=d+p1*dr+p2*dc+p1*p1*drr+p1*p2*drc+p2*p2*dcc;
                                width_r(j)=abs(t);
                            end
                            if(dir==-1)
                                grad_l(j)=d+p1*dr+p2*dc+p1*p1*drr+p1*p2*drc+p2*p2*dcc;
                                width_l(j)=abs(t);
                            end
                            %break;
                     end
                   end
               end
           end
       end
    end
   [width_l,width_r,pos_x,pos_y,correct,asymm,cont]=fix_location(width_l,width_r,grad_l,grad_r,pos_x,pos_y,correct_pos,sigma,cont);
  
 %  if((width_l>2)&&())
   out_contours(i).row=cont.row;
   out_contours(i).col=cont.col;
   out_contours(i).angle=cont.angle;
   out_contours(i).response=cont.response;
   out_contours(i).num=cont.num;
   out_contours(i).cont_class=cont.cont_class;
   out_contours(i).width_l=width_l;
   out_contours(i).width_r=width_r;
   out_contours(i).asymm=asymm;
   out_contours(i).correction=correct;
end
