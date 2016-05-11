function x=qsort(x,N)
temp=x(1).value;
i=1;
j=N;
while 1
    while (i ~= j) && (~( x(j).value < temp ))
        j = j - 1;
    end
    if i == j
        break;
    end
    x(i).value = x(j).value;
    x(i).x = x(j).x;
    x(i).y = x(j).y;
    i = i + 1;
    while (i ~= j) && (~( x(i).value> temp ))
        i = i + 1;
    end
    if i == j
        break;
    end
    x(j).value = x(i).value;
    x(j).x = x(i).x;
    x(j).y = x(i).y;
    j = j - 1;
end
    x(i).value = temp;

if N - i > 1
    x(i+1 : N) = qsort(x(i+1 : N));
end
if i-1 > 1
    x(1 : i-1) = qsort(x(1 : i-1));
end

end
