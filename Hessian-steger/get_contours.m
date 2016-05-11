function [num_junc,num_cont,cont,junc,crossd]=get_contours(img,ismax,eigVal,n1,n2,p1,p2,sigma,pnt_size,extend_lines,thresh,mode,gradx,grady,width,height,mean_eigVal)
%方向模版

dirtab = {
  { {  1, 0 }, {  1,-1 }, {  1, 1 } },...
  { {  1, 1 }, {  1, 0 }, {  0, 1 } },...
  { {  0, 1 }, {  1, 1 }, { -1, 1 } },...
  { { -1, 1 }, {  0, 1 }, { -1, 0 } },...
  { { -1, 0 }, { -1, 1 }, { -1,-1 } },...
  { { -1,-1 }, { -1, 0 }, {  0,-1 } },...
  { {  0,-1 }, { -1,-1 }, {  1,-1 } },...
  { {  1,-1 }, {  0,-1 }, {  1, 0 } }...
};
 cleartab = {
  { {  0, 1 }, {  0,-1 } },...
  { { -1, 1 }, {  1,-1 } },...
  { { -1, 0 }, {  1, 0 } },...
  { { -1,-1 }, {  1, 1 } },...
  { {  0,-1 }, {  0, 1 } },...
  { {  1,-1 }, { -1, 1 } },...
  { {  1, 0 }, { -1, 0 } },...
  { {  1, 1 }, { -1,-1 } }...
};
DBL_MAX=1.7976931348623157E+308;
cont_no_junc=0;    %/* no end point is a junction */
cont_start_junc=1; % /* only the start point of the line is a junction */
cont_end_junc=2;   % /* only the end point of the line is a junction */
cont_both_junc=3;  %/* both end points of the line are junctions */
cont_closed=4;     %/* the contour is closed */

area=0;
%对图像中特征值大于零的点（像素大于阈值的点）提取出来存在rl
rl=threshold(img,thresh);
[~,num_stpoint]=size(rl);
indx=zeros(height,width);%存放
label=zeros(height,width);
num_cont=1;
num_junc=1;
%rl是一系列的可能的提取起始点（starring point）
% for i=1:num_stpoint
%     area=area+rl(i).ce-rl(i).cb+1;  %area为所有可能起始点的数量
% end
k=1;
%保存到cross结构体
for i=1:num_stpoint
    x=rl(i).r; %r为每个点的行数
    for y=rl(i).cb:1:rl(i).ce
        if(abs(eigVal(x,y))>mean_eigVal)
        startp(k).x=x; 
        startp(k).y=y;
        startp(k).value=eigVal(x,y);
        startp(k).done=0;
        k=k+1;
        else
            break;
        end
    end
end
[~,index]=sort([startp.value]);
[~,in]=size(index);
area=k-1;
%对所有cross结构体可能点进行排序 降序 输出crossd

for i=1:in
    crossd(in-i+1).value=startp(index(i)).value;
    crossd(in-i+1).x=startp(index(i)).x;
    crossd(in-i+1).y=startp(index(i)).y;
    crossd(in-i+1).done=startp(index(i)).done;
end
 for i=1:area
     indx(crossd(i).x,crossd(i).y)=i+1;
 end
%  /* Link lines points. */开始连接点
indx_max=1;%起始点的下角标
while(1)
   cls=cont_no_junc;%contour_no_junction
   while((indx_max<(area+1))&&(crossd(indx_max).done==1))%当前点
       indx_max=indx_max+1;
   end
   if(indx_max==area+1) %到最后一个starting point点跳出循环
       break;
   end
   max=crossd(indx_max).value;
   maxx=crossd(indx_max).x;
   maxy=crossd(indx_max).y;
   if(max==0)
       break;
   end
   %将起始点加入线段中
   num_pnt=1;%matlab数组下标要大于0
   label(maxx,maxy)=num_cont+1;
    if(indx(maxx,maxy)>0)
        crossd(indx(maxx,maxy)-1).done=1;
        %标记当前位置为已经搜索过的起始点
    end
    row(num_pnt)=p1(maxx,maxy);
    col(num_pnt)=p2(maxx,maxy);
    nx=-n2(maxx,maxy);
    ny=n1(maxx,maxy);
    alpha=atan2(ny,nx);%alpha为线条方向
    if(alpha<0);
        alpha=alpha+2*pi;
    end
    if(alpha>=pi)
        alpha=alpha-pi;
    end
    octant=mod(floor(4.0/pi*alpha+0.5),4);
%         /* Select normal to the line.  The normal points to the right of the line
%        as the line is traversed from 0 to num-1.  Since the points are sorted
%        in reverse order before the second iteration, the first beta actually
%        has to point to the left of the line! */
    beta=alpha+pi/2;
    if(beta>=(2*pi))
        beta=beta-2*pi;  %beta为垂直线条的法线方向
    end
    angle(num_pnt)=beta;
    resp(num_pnt)=interpolate_response(eigVal,maxx,maxy,p1,p2,width,height);
    num_pnt=num_pnt+1;
%%%%%%%%%%/* Mark double responses as processed. */%%%%%%%%%
    for i=1:2
    nextx=maxx+cleartab{1,octant+1}{1,i}{1,1};
    nexty=maxy+cleartab{1,octant+1}{1,i}{1,2};
    if((nextx>1)&&(nextx<=height)&&(nexty>1)&&(nexty<=width))
    if(ismax(nextx,nexty)>0)
            nx=-n2(nextx,nexty);
            ny=n1(nextx,nexty);
            nextalpha=atan2(ny,nx);
            if(nextalpha<0)
                nextalpha=nextalpha+2*pi;
            end
            if(nextalpha>=pi)
                nextalpha=nextalpha-pi;
            end
            diff=abs(alpha-nextalpha);
            if(diff>=pi/2)
                diff=pi-diff;
            end
            if(diff<pi/6)
                label(nextx,nexty)=num_cont+1;
                if(indx(nextx,nexty))
                    crossd(indx(nextx,nexty)-1).done=1;
                end
            end 
    end
    end
    end
    % 分别向正负方向搜索
    for it=1:2
        if(it==1) %第一次搜索
            x = maxx;
            y = maxy;
            nx=-n2(x,y);
            ny=n1(x,y);
            alpha = atan2(ny,nx);
            if (alpha < 0.0)
              alpha = alpha+2.0*pi;
            end
            if (alpha >= pi)
              alpha =alpha-pi;
            end
            last_octant=mod(floor(4.0/pi*alpha+0.5),4);
            last_beta = alpha+pi/2.0;
            if (last_beta >= 2.0*pi)
              last_beta=last_beta-2.0*pi;
            end
        else %反方向搜索
            x = maxx;
            y = maxy;
            nx=-n2(x,y);
            ny=n1(x,y);
            alpha = atan2(ny,nx);
            if (alpha < 0.0)
              alpha = alpha+2.0*pi;
            end
            if (alpha >= pi)
              alpha =alpha-pi;
            end
            last_octant=mod(floor(4.0/pi*alpha+0.5),4)+4;
            last_beta = alpha+pi/2.0;
            if (last_beta >= 2.0*pi)
              last_beta=last_beta-2.0*pi;
            end
        end
% /* Sort the points found in the first iteration in reverse. */
        if(it==2)%      checked here 2016.3.1 night
            %if(num_pnt>1)
            for i=1:floor((num_pnt)/2) %2016/3/3修改 num_pnt-i+1
                %2016/3/3 修改 num_pnt-i
              tmp = row(i);
              row(i) = row(num_pnt-i);
              row(num_pnt-i) = tmp;
              tmp = col(i);
              col(i) = col(num_pnt-i);
              col(num_pnt-i)= tmp;
              tmp = angle(i);
              angle(i) = angle(num_pnt-i);
              angle(num_pnt-i) = tmp;
              tmp = resp(i);
              resp(i) = resp(num_pnt-i);
              resp(num_pnt-i) = tmp;
           % end 
            end
        end
% /* Now start adding appropriate neighbors to the line. */
while(1)
            nx=-n2(x,y);
            ny=n1(x,y);
            px=p1(x,y);
            py=p2(x,y);
            alpha=atan2(ny,nx);
            if(alpha<0)
                alpha=alpha+2*pi;
            end
            if(alpha>=pi)
                alpha=alpha-pi;
            end
            octant=mod(floor(4.0/pi*alpha+0.5),4);
            switch (octant)
                case 0
                    if((last_octant>=3)&&(last_octant<=5))
                        octant=4;
                    end
                case 1    
                    if((last_octant>=4)&&(last_octant<=6))
                        octant=5;
                    end
                case 2
                    if((last_octant>=4)&&(last_octant<=7))
                        octant=6;
                    end
                case 3
                    if((last_octant==0)||(last_octant>=6))
                        octant=7;
                    end
            end
            last_octant = octant;
        %/* Determine appropriate neighbor. *///date:2016-2-29-21:50
            nextismax=0;
            nexti=1;
            mindiff=DBL_MAX;
            for i=1:3
                 nextx=x+dirtab{1,octant+1}{1,i}{1,1};
                 nexty=y+dirtab{1,octant+1}{1,i}{1,2};
                 if((nextx>1)&&(nextx<=height)&&(nexty>1)&&(nexty<=width))
                     if(ismax(nextx,nexty)>0)
                       dx=p1(nextx,nexty)-px;
                       dy=p2(nextx,nexty)-py;
                       dist=sqrt(dx*dx+dy*dy);
                        nx=-n2(nextx,nexty);
                        ny=n1(nextx,nexty);
                        nextalpha=atan2(ny,nx);
                        if(nextalpha<0)
                            nextalpha=nextalpha+2*pi;
                        end
                        if(nextalpha>=pi)
                            nextalpha=nextalpha-pi;
                        end
                        diff=abs(alpha-nextalpha);
                        if(diff>=pi/2)
                            diff=pi-diff;
                        end
                        diff = dist+diff;
                        if(diff<mindiff)
                            mindiff=diff;
                            nexti=i;
                        end
                        if(ismax(nextx,nexty))
                            nextismax=1;
                        end
                    end
                end
            end
        %/* Mark double responses as processed. */
            for i=1:2
            nextx=x+cleartab{1,octant+1}{1,i}{1,1};
            nexty=y+cleartab{1,octant+1}{1,i}{1,2};
            if((nextx>1)&&(nextx<=height)&&(nexty>1)&&(nexty<=width))
            if(ismax(nextx,nexty)>0)
                    nx=-n2(nextx,nexty);
                    ny=n1(nextx,nexty);
                    nextalpha=atan2(ny,nx);
                    if(nextalpha<0)
                        nextalpha=nextalpha+2*pi;
                    end
                    if(nextalpha>=pi)
                        nextalpha=nextalpha-pi;
                    end
                    diff=abs(alpha-nextalpha);
                    if(diff>=pi/2)
                        diff=pi-diff;
                    end
                    if(diff<pi/6)
                        label(nextx,nexty)=num_cont+1;
                        if(indx(nextx,nexty))
                            crossd(indx(nextx,nexty)-1).done=1;
                        end
                    end
            end
            end
            end
        %/* Have we found the end of the line? */
        if(nextismax==0)
            break;
        end
       x=x+dirtab{1,octant+1}{1,nexti}{1,1};
       y=y+dirtab{1,octant+1}{1,nexti}{1,2};
       row(num_pnt)=p1(x,y);
       col(num_pnt)=p2(x,y);
       nx=n1(x,y);
       ny=n2(x,y);
       beta=atan2(ny,nx);
       if(beta<0)
           beta=beta+2*pi;
       end
       if(beta>=pi)
           beta=beta-pi;
       end
       diff1=abs(beta-last_beta);
       if(diff1>=pi)
           diff1=2*pi-diff1;
       end
       diff2=abs(beta+pi-last_beta);
       if(diff2>=pi)
           diff2=2*pi-diff2;   
       end
       if(diff1<diff2)
           angle(num_pnt)=beta;
           last_beta=beta;
       else
           angle(num_pnt)=beta+pi;
           last_beta=beta+pi;
       end
       resp(num_pnt)=interpolate_response(eigVal,x,y,p1,p2,width,height);
       num_pnt=num_pnt+1;
%/* If the appropriate neighbor is already processed a junction point is found. */
      if(label(x,y)>0)
        k=label(x,y)-1;
        if(k==num_cont)%line_intersect itself
        for j=1:num_pnt
            cl=[row(j)-p1(x,y)  col(j)-p2(x,y)];
            if (any(cl))
            %if(row(j)==p1(x,y))&&(col(j)==p2(x,y))
                if(j==1)
                    cls=cont_closed;
                    %if(num_pnt>1)
                    for i=1:floor((num_pnt)/2)
                      tmp = row(i);
                      row(i) = row(num_pnt-i);
                      row(num_pnt-i) = tmp;
                      tmp = col(i);
                      col(i) = col(num_pnt-i);
                      col(num_pnt-i)= tmp;
                      tmp = angle(i);
                      angle(i) = angle(num_pnt-i);
                      angle(num_pnt-i) = tmp;
                      tmp = resp(i);
                      resp(i) = resp(num_pnt-i);
                      resp(num_pnt-i) = tmp;
                    %end 
                    end
                    it=2;
                else
                    if(it==2)
                        if(cls==cont_start_junc)
                            cls=cont_both_junc;
                        else
                            cls=cont_end_junc;
                        end
                        junc(num_junc).cont1=num_cont;
                        junc(num_junc).cont2=num_cont;
                        junc(num_junc).pos=j;
                        junc(num_junc).x=p1(x,y);
                        junc(num_junc).y=p2(x,y);
                        num_junc=num_junc+1;
                    else
                         cls = cont_start_junc;
                        junc(num_junc).cont1=num_cont;
                        junc(num_junc).cont2=num_cont;
                        junc(num_junc).pos=num_pnt-1-j;
                        junc(num_junc).x=p1(x,y);
                        junc(num_junc).y=p2(x,y);
                        num_junc=num_junc+1;
                    end
                end
                break;
            end
        end
%%%%%%%%/* Mark this case as being processed for the algorithm below. */%%%
        j=-1;
        else
            for j=1:(cont(k).num)
                %if((cont(k).row(j)==p1(x,y))&&(cont(k).col(j)==p2(x,y)))
                cl=[cont(k).row(j)-p1(x,y)  cont(k).col(j)-p2(x,y)];
                 if (any(cl))
                    break;
                end
            end
            if(j==cont(k).num)
                mindist=DBL_MAX;
                j=-1;
                for l=1:cont(k).num
                    dx=p1(x,y)-cont(k).row(l);
                    dy=p2(x,y)-cont(k).col(l);
                    dist=sqrt(dx*dx+dy*dy);
                    if(dist<mindist)
                        mindist=dist;
                        j=l;
                    end
                end
                %/* Add the point with index j to the current line. */
                row(num_pnt)=cont(k).row(j);
                col(num_pnt)=cont(k).col(j);
                beta=cont(k).angle(j);
                if(beta>=pi)
                    beta=beta-pi;
                end
                   diff1=abs(beta-last_beta);
                   if(diff1>=pi)
                       diff1=2*pi-diff1;
                   end
                   diff2=abs(beta+pi-last_beta);
                   if(diff2>=pi)
                       diff2=2*pi-diff2;
                   end
                   if(diff1<diff2)
                       angle(num_pnt)=beta;
                   else
                       angle(num_pnt)=beta+pi;
                   end
                   resp(num_pnt)=cont(k).response(j);
                   num_pnt=num_pnt+1;  
            end
        end
        if((j>0)&&(j<cont(k).num))
            if(it==1) 
                cls=cont_start_junc;
            elseif(cls==cont_start_junc)
                cls=cont_both_junc;
            else
                cls=cont_end_junc;
            end
            junc(num_junc).cont1=k;
            junc(num_junc).cont2=num_cont;
            junc(num_junc).pos=j;
            junc(num_junc).x=row(num_pnt-1);
            junc(num_junc).x=col(num_pnt-1);
            num_junc=num_junc+1;            
        end
        break;
       end
        label(x,y)=num_cont+1;
        if(indx(x,y))
            crossd(indx(x,y)-1).done=1;
        end     
end
    end
    if(num_pnt>pnt_size)
        %/* Only add lines with at least two points. */
       
        cont(num_cont).row=row;
        cont(num_cont).col=col;
        cont(num_cont).angle=angle;
        cont(num_cont).response=resp;
        cont(num_cont).num=num_pnt-1;
        cont(num_cont).cont_class=cls;
        num_cont=num_cont+1;
        clear row;
        clear col;
        clear angle;
        clear resp;
        clear num_pnt;
        
    else
        for i=-1:1
            for j=-1:1
                row1=BR(maxx+i,height);
                col1=BC(maxy+j,width);
                if(label(row1,col1)==num_cont+1)
                   label(row1,col1)=0;
                end
            end
        end
    end 
end
num_cont=num_cont-1;
num_junc=num_junc-1;
%/* Now try to extend the lines at their ends to find additional junctions. */
% end_angle=0;
% end_resp=0;
% if(extend_lines==1)
%     if(mode==1)
%         s=1;
%     else
%         s=-1;
%     end
%     length=2.5*sigma;
%     max_line=ceil(length*3);
%     extx=zeros(1,max_line);
%     exty=zeros(1,max_line);
%     for i=1:num_cont
%         tmp_cont=cont(i);
%         num_pnt=tmp_cont.num;
%         if((num_pnt~=1)&&(tmp_cont.cont_class~=4))
%             trow=tmp_cont.row;
%             tcol=tmp_cont.col;
%             tangle=tmp_cont.angle;
%             tresp=tmp_cont.response;
%             for it=-1:2:1
%                 if(it==-1)
%                     if((tmp_cont.cont_class~=1)&&(tmp_cont.cont_class~=3))
%                        dx=trow(2)-trow(1);
%                        dy=tcol(2)-tcol(1);
%                        alpha=tangle(1);
%                        nx=cos(alpha);
%                        ny=sin(alpha);
%                        if(nx*dy-ny*dx<0)
%                            mx=-ny;
%                            my=nx;
%                        else
%                            mx=ny;
%                            my=-nx;
%                        end
%                        px=trow(1);
%                        py=tcol(1);
%                        response=tresp(1);
%                     end
%                 else
%                     if((tmp_cont.cont_class~=2)&&(tmp_cont.cont_class~=3))
%                         dx=trow(num_pnt)-trow(num_pnt-1);
%                         dy=tcol(num_pnt)-tcol(num_pnt-1);
%                         alpha=tangle(num_pnt);
%                         nx=cos(alpha);
%                         ny=sin(alpha);
%                         if(nx*dy-ny*dx<0)
%                             mx=ny;
%                             my=-nx;
%                         else
%                             mx=-ny;
%                             my=nx;
%                         end
%                        px=trow(num_pnt);
%                        py=tcol(num_pnt);
%                        response=tresp(num_pnt);
%                     end
%                 end
%                 %/* Determine the current pixel and calculate the pixels on the search
%                 x=floor(px+0.5);
%                 y=floor(py+0.5);
%                 dx=px-x;
%                 dy=py-y;
%                 [line,num_line]=bresenham(mx,my,dx,dy,length);
%                 num_add=1;
%                 add_ext=0;
%                 for k=1:num_line
%                     nextx=x+line(k).x;
%                     nexty=y+line(k).y;
%                     [nextpx,nextpy,t]=closest_point(px,py,mx,my,nextx,nexty);
%                     if(t>0.5)
%                         if((nextpx<0)||(nexty<0)||(nextpx>=height)||(nextpy>=width)||(nextx<0)||(nexty<0)||(nextx>height)||(nexty>width))
%                         break;
%                         end
%                        [gx,gy]=interpolate_gradient(gradx,grady,nextpx,nextpy);
%                         if((s*(mx*gx+my*gy)<0)&&(label(nextx,nexty)==0))
%                             break;
%                         end
%                         if(label(nextx,nexty)>0)
%                             m=label(nextx,nexty)-1;
%                             mindist=DBL_MAX;
%                             j=-1;
%                             for l=1:cont(m).num
%                             dx=nextpx-cont(m).row(l);
%                             dy=nextpy-cont(m).col(l);
%                             dist=sqrt(dx*dx+dy*dy);
%                             if(dist<mindist)
%                                 mindist=dist;
%                                 j=l;
%                             end
%                             end
%                             if(mindist>3)
%                                 break;
%                             end
%                                 extx(num_add)=cont(m).row(j);
%                                 exty(num_add)=cont(m).col(j);
%                                 end_resp=cont(m).response(j);
%                                 end_angle=cont(m).angle(j);
%                                 beta=end_angle;
%                                 if(beta>=pi)
%                                     beta=beta-pi;
%                                 end
%                                 diff1=abs(beta-alpha);
%                                 if(diff1>=pi)
%                                     diff1=2*pi-diff1;
%                                 end
%                                 diff2=abs(beta+pi-alpha);
%                                 if(diff2>=pi)
%                                     diff2=2*pi-diff2;
%                                 end
%                                 if(diff1<diff2)
%                                     end_angle=beta;
%                                 else
%                                     end_angle=beta+pi;
%                                 end
%                                 num_add=num_add+1;
%                                 add_ext=1;
%                                 break;
%                         else
%                             extx(num_add)=nextpx;
%                             exty(num_add)=nextpy;
%                             num_add=num_add+1;
%                         end
%                     end
%                 end
%                 num_add=num_add-1;
%                 if(add_ext)
%                     
%                     num_pnt=num_pnt+num_add;
%                     tmp_cont.row=trow;
%                     tmp_cont.col=tcol;
%                     tmp_cont.angle=tangle;
%                     tmp_cont.response=tresp;
%                     tmp_cont.num=num_pnt;
%                     if(it==-1)
%                         %/* Move points on the line up num_add places. */
%                         for k=num_pnt-num_add:-1:1 %question!!
%                             trow(k+num_add+1)=trow(k);
%                             tcol(k+num_add+1)=tcol(k);
%                             tangle(k+num_add+1)=tangle(k);
%                             tresp(k+num_add+1)=tresp(k);
%                             
%                         end
%                         for k=1:num_add
%                             trow(k)=extx(num_add-k);
%                             tcol(k)=exty(num_add-k);
%                             tangle(k)=alpha;
%                             tresp(k)=response;
%                         end
%                         tangle(1)=end_angle;
%                         tresp(1)=end_resp;
%                         for k=1:num_junc
%                             if(junc(k).cont1==i)
%                                 junc(k).pos=junc(k).pos+num_add;
%                             end
%                         end
%                     else
%                         for k=1:num_add
%                             trow(num_pnt-num_add+k+1)=extx(k);
%                             tcol(num_pnt-num_add+k+1)=exty(k);
%                             tangle(num_pnt-num_add+k+1)=alpha;
%                             tresp(num_pnt-num_add+k+1)=response;
%                         end
%                         tangle(num_pnt)=end_angle;
%                         tresp(num_pnt)=end_resp;
%                         
%                     end
%                     if((j>1)&&(j<cont(m).num))
%                         if(it==-1)
%                             if(tmp_cont.cont_class==cont_end_junc)
%                                 tmp_cont.cont_class=cont_both_junc;
%                             else
%                                 tmp_cont.cont_class=cont_start_junc;
%                             end
%                         else
%                            if (tmp_cont.cont_class == cont_start_junc)
%                                tmp_cont.cont_class = cont_both_junc;
%                            else
%                                tmp_cont.cont_class = cont_end_junc;
%                            end
%                         end
%                         junc(num_junc).cont1=m;
%                         junc(num_junc).cont2=i;
%                         junc(num_junc).pos=j;
%                         if(it==-1)
%                             junc(num_junc).x=trow(1);
%                             junc(num_junc).y=tcol(1);
%                         else
%                             junc(num_junc).x=trow(num_pnt);
%                             junc(num_junc).y=tcol(num_pnt);
%                         end
%                         num_junc=num_junc+1;
%                     end 
%                 end    
%             end
%         end
%     end
%     clear extx;
%     clear exty;
%     clear line;
% end
% num_junc=num_junc-1;
% % % /* Done with linking.  Now split the lines at the junction points. */
% for i=1:k:num_junc
%     j=junc(i).cont1;
%     tmp_cont=cont(j);
%     num_pnt=tmp_cont.num;
%      k=1;
%      while((junc(i+k-1).cont1==j)&&((i+k-1)<=num_junc))
%           end
%          k=k+1;
%          if((k==1)&&(tmp_cont.row(1)==tmp_cont.row(num_pnt))&&(tmp_cont.col(1)==tmp_cont.col(num_pnt)))
%              %如果只找到一个交点，线条是封闭的
%              begin=junc(i).pos;
%              trow=tmp_cont.row;
%              tcol=tmp_cont.col;
%              tangle=tmp_cont.angle;
%              tresp=tmp_cont.response;
%              for l=1:num_pnt
%                  pos=begin+1;
%                  if(pos>(num_pnt))
%                      pos=begin+l-num_pnt+2;
%                  end
%                      tmp_cont.row(l)=trow(pos);
%                      tmp_cont.col(l)=tcol(pos);
%                      tmp_angle(l)=tangle(pos);
%                      tmp_cont.response(l)=tresp(pos);
%                 
%              end
%              tmp_cont.cont_class=cont_both_junc;
%            clear tcol;
%            clear trow;
%            clear tangle;
%            clear tresp;
%          else
%              for l=1:k+1
%                  if(l==1)
%                      begin=0;   
%                  else
%                      begin=junc(i+l-1).pos;
%                   end
%                      if(l==k)
%                          end1=tmp_cont.num-1;
%                      else
%                          end1=junc(i+l).pos;
%                      end
%                       num_pnt=end1-begin+1;
%                       if((num_pnt==1)&&k>1)
%                           continue;
%                       end
%                       cont(num_cont).row=tmp_cont.row;
%                       cont(num_cont).col=tmp_cont.col;
%                       cont(num_cont).angle=tmp_cont.angle;
%                       cont(num_cont).response=tmp_cont.response;
%                       cont(num_cont).num=num_pnt;
%                       if (l == 0)
%                           if ((tmp_cont.cont_class == cont_start_junc)||(tmp_cont.cont_class == cont_both_junc))
%                               cont(num_cont).cont_class = cont_both_junc;
%                           else
%                               cont(num_cont).cont_class = cont_end_junc;
%                           end
%                       elseif(l == k)
%                           if ((tmp_cont.cont_class == cont_end_junc)||(tmp_cont.cont_class == cont_both_junc))
%                               cont(num_cont).cont_class = cont_both_junc;
%                           else
%                               cont(num_cont).cont_class = cont_start_junc;
%                           end
%                       else
%                           cont(num_cont).cont_class = cont_both_junc;
%                       end
%                       num_cont=num_cont+1;
%              end
%              num_cont=num_cont-1;
%              cont(j)=cont(num_cont);
%              clear tmp_cont;
%          end     
% end
        for i=1:num_cont
            tmp_cont=cont(i);
            num_pnt=tmp_cont.num;
            trow=tmp_cont.row;
            tcol=tmp_cont.col;
            tangle=tmp_cont.angle;
                k=floor((num_pnt-1)/2);
            dx=trow(k+1)-trow(k);
            dy=tcol(k+1)-tcol(k);
            nx=cos(tangle(k));
            ny=sin(tangle(k));
            if(nx*dy-ny*dx<0)
                for j=1:num_pnt
                    tangle(j)=tangle(j)+pi;
                    if(tangle(j)>=2*pi)
                        tangle(j)=tangle(j)-2*pi;
                    end
                end
            end
        end
        
%         clear junc;
%         clear resp;
%         clear angle;
%         clear col;
%         clear row;
% for i=1:num_cont
%     tmp_cont=cont(i);
%     num_pnt=tmp_cont.num;
%     trow=tmp_cont.row;
%     tcol=tmp_cont.col;
%     tangle=tmp_cont.angle;
%     k=floor((num_pnt-1)/2);
%     dx=trow(k+1)-trow(k);
%     dy=tcol(k+1)-tcol(k);
%     nx=cos(tangle(k));
%     ny=sin(tangle(k));
%     if(nx*dy-ny*dx<0)
%         for j=1:num_pnt
%             tangle(j)=tangle(j)+pi;
%             if(tangle(j)>=2*pi)
%                 tangle(j)=tangle(j)-2*pi;
%             end
%         end
%     end
% end
           

end
























