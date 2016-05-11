   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ά�ؽ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function [nPointW]=reconstruction(H,contours,percent,trany,tranx)         
   %ȥ����β10%�ĵ�
           % percent=0.02;
            [~,n]=size(contours);%��ȡ�������߶�
            
            for q=1:n
                [~,sizej]=size(contours(q).row);
                delpt=floor(sizej*percent);
                k=1;
                r=1;
                for j=1+delpt:sizej-delpt
                    pos_xy(r,2)=contours(q).row(j)+tranx-1;
                    pos_xy(r,1)=contours(q).col(j)+trany-1;
                    k=k+1;
                    r=r+1;
                end 
            sizeImage=size(pos_xy);%pox_xy is all the points
            addImage=zeros(sizeImage(1),2);
            PointW=zeros(sizeImage(1),3);
            for i=1:sizeImage(1)
                addImage(i,1)=1;
            end
            ImagePixel=[pos_xy addImage];%��������ϵ�µĵ�
            invH=inv(H);
            ImagePoint=zeros(4,1);
            for i=1:sizeImage(1)
                for j=1:4
                    ImagePoint(j)=ImagePixel(i,j);
                end
                %���ۼ���ͶӰ������
                %  ImagePoint=ImagePoint';�������
                Point=invH*ImagePoint;
                %nor=norm(Point(4));
                Point=Point*1/norm(Point(4));
                %NormPoint=H\ImagePoint;%ͶӰ������δ��һ��
                for j=1:3
                    PointW(i,j)=Point(j);
                    %NormPointW(i,j)=NormPoint(j);
                end
            end
            nPointW(q).PointW=PointW;
            clear pos_xy k r;
            end
   end