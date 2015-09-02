%based on the sqrt of the area of the path
%input: confusion matrix and number of classes
% size(confusionM) should be [K K]
function res= myMetricSA(data, K)

confusionM = contingency_table(data,K);


N = sum(confusionM(:));
costMatrix = zeros(size(confusionM));

areaMatrix = zeros(size(confusionM));
benefitMatrix = zeros(size(confusionM));

const = 1/sqrt(2*(K-1)/(K*K*K));

benefitMatrix (1,1)=confusionM(1,1);
areaMatrix (1,1)=0;
errMatrix(1,1) = sqrt(areaMatrix (1,1))/const + (N - benefitMatrix(1,1))/N;
for c=2:K        
    areaMatrix(1,c)    = areaMatrix(1,c-1)+ c-1;
    benefitMatrix(1,c) = benefitMatrix(1,c-1)+ confusionM(1,c);
    errMatrix(1,c) = sqrt(areaMatrix (1,c))/const + (N - benefitMatrix(1,c))/N;
end
for r=2:K        
    areaMatrix(r,1)    = areaMatrix(r-1,1) + 1;
    benefitMatrix(r,1) = benefitMatrix(r-1,1)+ confusionM(r,1);    
    errMatrix(r,1) = sqrt(areaMatrix (r,1))/const + (N - benefitMatrix(r,1))/N;
end 
for c=2:K
    for r=2:K
        costup      = sqrt(areaMatrix(r-1, c) + (r>c))/const + (N - benefitMatrix(r-1,c)-confusionM(r,c))/N;
        costleft    = sqrt(areaMatrix(r, c-1) + abs(r-c))/const + (N - benefitMatrix(r,c-1)-confusionM(r,c))/N;  
        lefttopcost = sqrt(areaMatrix(r-1, c-1) + abs(r-c))/const + (N - benefitMatrix(r-1,c-1)-confusionM(r,c))/N; 
        aux = [costup costleft lefttopcost];
        [mm, idx] = min(aux);
        errMatrix(r,c) = mm; 
        switch idx 
          case {1}
            benefitMatrix(r,c) = benefitMatrix(r-1,c)+confusionM(r,c);
            areaMatrix(r,c) = areaMatrix(r-1, c) + (r>c);
          case 2
            benefitMatrix(r,c) = benefitMatrix(r,c-1)+confusionM(r,c);
            areaMatrix(r,c) = areaMatrix(r, c-1) + abs(r-c);
          case 3
            benefitMatrix(r,c) = benefitMatrix(r-1,c-1)+confusionM(r,c);
            areaMatrix(r,c) = areaMatrix(r-1, c-1) + abs(r-c);
          otherwise
            disp('error');  
        end  
    end
end

res = errMatrix(end,end);