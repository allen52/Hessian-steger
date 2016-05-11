function [gx,gy]=interpolate_gradient(gradx,grady,px,py)
gix=floor(px);
giy=floor(py);
gfx=mod(px,1.0);
gfy=mod(py,1.0);
gx1=gradx(gix,giy);
gy1=grady(gix,giy);
gx2=gradx(gix,giy+1);
gy2=grady(gix,giy+1);
gx3=gradx(gix+1,giy);
gy3=grady(gix+1,giy);
gx4=gradx(gix+1,giy+1);
gy4=grady(gix+1,giy+1);
gx=(1-gfy)*((1-gfx)*gx1+gfx*gx2)+gfy*((1-gfx)*gx3+gfx*gx4);
gy=(1-gfy)*((1-gfx)*gy1+gfx*gy2)+gfy*((1-gfx)*gy3+gfx*gy4);

end