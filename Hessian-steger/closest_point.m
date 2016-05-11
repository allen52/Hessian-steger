function [cx,cy,t]=closest_point(lx,ly,dx,dy,px,py)
mx=px-lx;
my=py-ly;
den=dx*dx+dy*dy;
nom=mx*dx+my*dy;
if(den~=0)
    tt=nom/den;
else
    tt=0;
end
cx=lx+tt*dx;
cy=ly+tt*dy;
t=tt;
end