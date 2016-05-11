function [result]=interpolate_response(resp,x,y,px,py,width,height)
i1=resp(BR(x-1,height),BC(y-1,width));
i2=resp(BR(x-1,height),BC(y,width));
i3=resp(BR(x-1,height),BC(y+1,width));
i4=resp(BR(x,height),BC(y-1,width));
i5=resp(BR(x,height),BC(y,width));
i6=resp(BR(x,height),BC(y+1,width));
i7=resp(BR(x+1,height),BC(y-1,width));
i8=resp(BR(x+1,height),BC(y,width));
i9=resp(BR(x+1,height),BC(y+1,width));
t1=i1+i2+i3;
t2=i4+i5+i6;
t3=i7+i8+i9;
t4=i1+i4+i7;
t5=i2+i5+i8;
t6=i3+i6+i9;
d=(-i1+2*i2-i3+2*i4+5*i5+2*i6-i7+2*i8-i9)/9;
dr=(t3-t1)/6;
dc=(t6-t4)/6;
drr=(t1-2*t2+t3)/6;
dcc=(t4-2*t5+t6)/6;
drc=(i1-i3-i7+i9)/4;
xx=px(x,y)-x;
yy=py(x,y)-y;
result=(d+xx*dr+yy*dc+xx*xx*drr+xx*yy*drc+yy*yy*dcc);

end