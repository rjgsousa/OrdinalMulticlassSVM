function parse(x,y,filename)
    fp = fopen(filename,'w');
    for i=1:size(x,1)
        fprintf(fp,'%d ',y(i));
        for j=1:size(x,2)
            fprintf(fp,'%d:%f ',j,x(i,j));
        end
        fprintf(fp,'\n');
    end
    fclose(fp);

    return