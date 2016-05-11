function [master,slave1,slave2]=fill_gaps(master, slave1, slave2, cont)
%global flagi flagj flag1 flag2 flag3 markj ;
%global indexj;
num_points=cont.num;
[~,ss1]=size(slave1);
[~,ss2]=size(slave2);
%xi=1:num_points;
for i=1:num_points
    if (master(i)==0)
        j=i+1;
        while ((j<=num_points))
            if (master(j)>0)
                break;
            else
                j=j+1;
            end   
        end
        markj=j;
        flagi=(i>1);
        flagj=(markj<num_points);
        flag1=(flagi && flagj);
        flag2=(i>1);
        flag3=(markj<num_points);
        if flag1
            %从该点起到下个点两个点为零
            s = i;
            e = markj-1;
            m_s=master(s-1);
            m_e=master(e+1);
            if(ss1>1)
                s1_s=slave1(s-1);
                s1_e=slave1(e+1);
            end
            if(ss2>1)
                s2_s=slave2(s-1);
                s2_e=slave2(e+1);
            end
        elseif flag2 %只有一个点为零
            s=i;
            e=num_points-1;
            m_s=master(s-1);
            m_e=master(s-1);
            master(e+1)=m_e;
             if(ss1>1)
                s1_s=slave1(s-1);
                s1_e=slave1(s-1);
                slave1(e+1)=s1_e;
            end
             if(ss2>1)
                s2_s=slave2(s-1);
                s2_e=slave2(s-1);
                slave1(e+1)=s2_e;
            end
        elseif flag3
            s=2;
            e=markj-1;
            m_s=master(e+1);
            m_e=master(e+1);
            master(s-1)=m_s;
             if(ss1>1)
                s1_s=slave1(e+1);
                s1_e=slave1(e+1);
                slave1(s-1)=s1_s;
            end
             if(ss2>1)
                s2_s=slave2(e+1);
                s2_e=slave2(e+1);
                slave2(s-1)=s2_s;
            end
        else
            s=2;
            e=num_points-1;
            m_s=master(s-1);
            m_e=master(e+1);
             if(ss1>1)
                s1_s=slave1(s-1);
                s1_e=slave2(e+1);
            end
             if(ss2>1)
                s2_s=slave2(s-1);
                s2_e=slave2(e+1);
            end
        end
        arc_len=0;
        for k=s:e+1
            d_r=cont.row(k)-cont.row(k-1);
            d_c=cont.col(k)-cont.col(k-1);
            arc_len=arc_len+sqrt(d_r*d_r+d_c*d_c);
        end
        len=0;
        for k=s:e
            d_r=cont.row(k)-cont.row(k-1);
            d_c=cont.col(k)-cont.col(k-1);
            len=len+sqrt(d_r*d_r+d_c*d_c);
            master(k)=(arc_len-len)/arc_len*m_s+len/arc_len*m_e;
             if(ss1>1)
                slave1(k)=(arc_len-len)/arc_len*s1_s+len/arc_len*s1_e;
            end
             if(ss2>1)
                slave2(k)=(arc_len-len)/arc_len*s2_s+len/arc_len*s2_e;
            end
        end
        i=j;
    end
end
end