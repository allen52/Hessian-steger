function [width_l,width_r,pos_x,pos_y,correction,asymm,cont]=fix_location(width_l,width_r,grad_l,grad_r,pos_x,pos_y,correct_pos,sigma,cont)

cont_no_junc=0;    %/* no end point is a junction */
cont_start_junc=1; % /* only the start point of the line is a junction */
cont_end_junc=2;   % /* only the end point of the line is a junction */
cont_both_junc=3;  %/* both end points of the line are junctions */
cont_closed=4;     %/* the contour is closed */
                  
[width_l,grad_l,~]=fill_gaps(width_l,grad_l,0,cont);
[width_r,grad_r,~]=fill_gaps(width_r,grad_r,0,cont);
num_points=cont.num;
if(correct_pos)
    correct_start=((cont.cont_class==cont_no_junc)||(cont.cont_class==cont_end_junc)||(cont.cont_class==cont_closed)&&(width_r(1)>0)&&(width_l(1)>0));
    correct_end=((cont.cont_class==cont_no_junc)||(cont.cont_class==cont_start_junc)||(cont.cont_class==cont_closed)&&(width_r(num_points))>0&&(width_l(num_points)>0));
        for i=1:num_points
            if((width_r(i)>=0)&&(width_l(i)>=0))
            w_est=(width_r(i)+width_l(i))*1.05;%LINE_WIDTH_COMPENSATION
            if(grad_r(i)<=grad_l(i))
                r_est=grad_r(i)/grad_l(i);
                weak_is_r=1;
            else
                r_est=grad_l(i)/grad_r(i);
                weak_is_r=0;
            end
            [w_real,h_real,corr,w_strong,w_weak]=line_corrections(sigma,w_est,r_est);
            w_real=w_real/1.05;
            corr=corr/1.05;
            %isvalid(i)=is_valid;
            width_r(i)=w_real;
            width_l(i)=w_real;
            if(weak_is_r)
                asymm(i)=h_real;
                correction(i)=-corr;
            else
                asymm(i)=-h_real;
                correction(i)=corr;                
            end
            end  
        end
        
       [width_l,correction,asymm]=fill_gaps(width_l,correction,asymm,cont);
        for i=1:num_points
            width_r(i)=width_l(i);
        end
        if(correct_start==0)
        correction(1)=0;
        end
        if(correct_end==0)
            correction(num_points)=0;
        end
        [~,sizecorrect]=size(correction);
        for i=1:sizecorrect
            px=pos_x(i);
            py=pos_y(i);
            nx=cos(cont.angle(i));
            ny=sin(cont.angle(i));
            px=px+correction(i)*nx;
            py=py+correction(i)*ny;
            pos_x(i)=px;
            pos_y(i)=py;
        end
end
 %[~,sizep]=size(correction);
%indexk=1;%%对于棋盘格图像的处理
    for i=1:num_points
        
      % if((width_l(i)<5)&&(width_r(i)<5))
        cont.width_l(i)=width_l(i);
        cont.width_r(i)=width_r(i);
        cont.row(i)=pos_x(i);
        cont.col(i)=pos_y(i);
      % indexk=indexk+1;
        %end
       
    end


end
