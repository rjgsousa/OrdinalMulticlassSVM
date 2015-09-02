
function data = carsdata_parser()
fid = fopen('../datafiles/car/car.data');
C   = textscan(fid,'%s%s%s%s%s%s%s','Delimiter',',');
%vhigh,vhigh,2,2,small,low,unacc
fclose(fid);

data = zeros(size(C{1},1),size(C,2));
for i = 1:length(C)
    if i ==length(C)
        d = parse_classes(C{i});
    else
        d = parse_data(C{i},i);
    end
    data(:,i) = d;
end
return

function d = parse_data(C,i)
d = zeros(length(C),1);

for j=1:length(C)
    info = C{j};
    if (i == 1 || i == 2)
        switch(info)
            case 'vhigh'
                d(j) = 1;
            case 'high'
                d(j) = 2;
            case 'med'
                d(j) = 3;
            case 'low'
                d(j) = 4;
        end
    elseif (i == 3)
        switch(info)
            case '2'
                d(j) = 1;
            case '3'
                d(j) = 2;
            case '4'
                d(j) = 3;
            case '5more'
                d(j) = 4;
        end
    elseif (i == 4)
        switch(info)
            case '2'
                d(j) = 1;
            case '4'
                d(j) = 2;
            case 'more'
                d(j) = 3;
        end
    elseif (i == 5)
        switch(info)
            case 'small'
                d(j) = 1;
            case 'med'
                d(j) = 2;
            case 'big'
                d(j) = 3;
        end
    elseif (i == 6)
        switch(info)
            case 'low'
                d(j) = 1;
            case 'med'
                d(j) = 2;
            case 'high'
                d(j) = 3;
        end
    end
end

return


function classes = parse_classes(C)
classes = zeros(length(C),1);

for j=1:length(C)
    class = C{j};
 
    switch(class)
        case 'unacc'
            classes(j) =  1;
        case 'acc'
            classes(j) =  2;
        case 'good'
            classes(j) =  3;
        case 'vgood'
            classes(j) =  4;
    end
end
return
