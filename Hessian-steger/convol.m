function [result]=convol(image,sigma,deriv_type)
 [height,width]=size(image);
 result=zeros(height,width);
switch deriv_type
    case 1 %DERIV_R
        [maskr,nr]=compute_gauss_mask_1(sigma);
        [maskc,nc]=compute_gauss_mask_0(sigma);
    case 2 %DERIV_C
        [maskr,nr]=compute_gauss_mask_0(sigma);
        [maskc,nc]=compute_gauss_mask_1(sigma);
    case 3 %DERIV_RR
        [maskr,nr]=compute_gauss_mask_2(sigma);
        [maskc,nc]=compute_gauss_mask_0(sigma);
    case 4 %DERIV_RC
        [maskr,nr]=compute_gauss_mask_1(sigma);
        [maskc,nc]=compute_gauss_mask_1(sigma);
    case 5 %DERIV_CC
        [maskr,nr]=compute_gauss_mask_0(sigma);
        [maskc,nc]=compute_gauss_mask_2(sigma);
end

[h]=convol_rows_guass(image,maskr,nr,width,height);
[k]=convol_cols_guass(h,maskc,nc,width,height);
for i=1:height
   for j=1:width
    result(i,j)=k((i-1)*width+j);
   end
end
end

function [result]=phi0(x,sigma)
result=normal(x/sigma);
end

function [result]=phi1(x,sigma)
SQRT_2_PI_INV=0.398942280401432677939946059935;
t=x/sigma;
result=SQRT_2_PI_INV/sigma*exp(-0.5*t*t) ;
end

function [result]=phi2(x,sigma)
SQRT_2_PI_INV=0.398942280401432677939946059935;
t=x/sigma;
result=-x*SQRT_2_PI_INV/(sigma^3)*exp(-0.5*t*t);
end

function [mask,num]=compute_gauss_mask_0(sigma)
MAX_SIZE_MASK_0=3.09023230616781;
limit=ceil(MAX_SIZE_MASK_0*sigma);
n=limit;
mask=zeros(2*n+1,1);
for i=(-n+2):1:(n)
    mask(i+n)=phi0(-i+0.5,sigma)-phi0(-i-0.5,sigma);
end
    mask(1)=1.0-phi0(n-0.5,sigma);
    mask(2*n+1)=phi0(-n+0.5,sigma);
    num=n;
end


function [mask,num]=compute_gauss_mask_1(sigma)
MAX_SIZE_MASK_1=3.46087178201605;
limit=ceil(MAX_SIZE_MASK_1*sigma);
n=limit;
mask=zeros(2*n+1,1);
for i=(-n+2):1:(n)
    mask(i+n)=phi1(-i+0.5,sigma)-phi1(-i-0.5,sigma);
end
    mask(1)=-phi1(n-0.5,sigma);
    mask(2*n+1)=phi1(-n+0.5,sigma);
    num=n;
end


function [mask,num]=compute_gauss_mask_2(sigma)
MAX_SIZE_MASK_2=3.82922419517181  ;
limit=ceil(MAX_SIZE_MASK_2*sigma);
n=limit;
mask=zeros(2*n+1,1);
for i=(-n+2):1:(n)
    mask(i+n)=phi2(-i+0.5,sigma)-phi2(-i-0.5,sigma);
end
    mask(1)=-phi2(n-0.5,sigma);
    mask(2*n+1)=phi2(-n+0.5,sigma);
    num=n;
end

function [h]=convol_rows_guass(image,mask,n,width,height)
%Inner region
%h=ones(height,width);
for r=n+1:1:height-n
    for c=1:1:width
        l=(r-1)*width+c;
        sum=0.0;
        for j=-n:1:n
        sum=sum+image((r+j),c)*mask(j+n+1);
        end
            h(l)=sum;
    end
end
%Border regions 
for r=1:n
    for c=1:width
        l=(r-1)*width+c;
        sum=0.0;
        for j=-n:1:n
            row=BR(r+j,height);
            sum=sum+image(row,c)*mask(j+n+1);
        end
         h(l)=sum;
    end
end
for r=height-n+1:1:height
    for c=1:1:width
        l=(r-1)*width+c;
        sum=0.0;
        for j=-n:1:n
            row=BR(r+j,height);
            sum=sum+image(row,c)*mask(j+n+1);
        end
              h(l)=sum;
    end
end

end

function [k]=convol_cols_guass(h,mask,n,width,height)
%k=ones(height,width);
for r=1:height
    for c=n+1:width-n 
        l=(r-1)*width+c;
        sum=0.0;
        for j=-n:1:n
            hl=(r-1)*width+c+j;
           % sum=sum+h((r-1)*width+c+j)*mask(j+n+1);
            sum=sum+h(hl)*mask(j+n+1);
        end
         k(l)=(sum);
    end
end

for r=1:height
    for c=1:n
        l=(r-1)*width+c;
        sum=0.0;
        for j=-n:1:n
            col=BC(c+j,width);
            hl=(r-1)*width+col;
            sum=sum+h(hl)*mask(j+n+1);
        end
           k(l)=(sum);
    end
end

for r=1:height
    for  c=width-n+1:width
        l=(r-1)*width+c;
        sum=0.0;
        for j=-n:1:n
            col=BC(c+j,width);
            hl=(r-1)*width+col;
            sum=sum+h(hl)*mask(j+n+1);
        end
        k(l)=(sum);
    end
end
end
            








