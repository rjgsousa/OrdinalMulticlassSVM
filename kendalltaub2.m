%%
%
function kendall = kendalltaub2 (listDataSet)

    data1 = listDataSet(:,1);
    data2 = listDataSet(:,2);
    N = size(listDataSet,1);
    
    n1 = 0; 
    n2 = 0;
    concordant = 0; 
    discordant = 0;
    
    
    for j = 1:N-1
        for k = (j+1):N
            a1 = data1(j)-data1(k);
            a2 = data2(j)-data2(k);
            aa = a1*a2;
            if (aa~=0)
                n1 = n1 + 1;
                n2 = n2 + 1;
                if aa>0
                    concordant = concordant + 1;
                else
                    discordant = discordant + 1;
                end
            else
                if (a1~=0)
                    n1 = n1 + 1;
                end
                if (a2~=0)
                    n2 = n2 + 1;
                end                
            end
        end
    end
    kendall = (concordant-discordant)/(sqrt(n1)*sqrt(n2));
return;

