%% ORDINAL CLASSIFICATION INDEX (OCI)              
% If you use this code please cite the following journal paper:
%    @article{CardosoJaimeS.Sousa2011,
%      author = {Cardoso, Jaime S. and Sousa, Ricardo},
%      journal = {International Journal of Pattern Recognition and Artificial Intelligence},
%      title = {{Measuring the Performance of Ordinal Classification}},
%      year = {2011},
%      doi = {10.1142/S0218001411009093},
%      volume = {25},
%      number = {8},
%      pages = {1173--1195}
%    }
% input: confusion matrix and number of classes
% size(cMatrix) must be [K K]
function oc=OrdinalClassificationIndex(cMatrix, K)
    N = sum(cMatrix(:));
    ggamma = 1;
    bbeta  = 0.75/(N*(K-1)^ggamma);

    helperM2 = zeros(K,K);
    for r=1:K
        for c=1:K
            helperM2(r,c) = cMatrix(r,c) * ...
                ((abs(r-c))^ggamma);
        end
    end
    TotalDispersion=(sum(helperM2(:))^(1/ggamma));
    helperM1       =cMatrix/(TotalDispersion+N);

    errMatrix(1,1) = 1 - helperM1(1,1) + ...
        bbeta*helperM2(1,1);
    for r=2:K 
        c=1;
        errMatrix(r,c) = errMatrix(r-1, c) - ...
            helperM1(r,c) + bbeta*helperM2(r,c);
    end 
    for c=2:K  
        r=1;
        errMatrix(r,c) = errMatrix(r,c-1) - ...
            helperM1(r,c) + bbeta*helperM2(r,c);
    end

    for c=2:K
        for r=2:K
            costup      = errMatrix(r-1, c);
            costleft    = errMatrix(r, c-1);
            lefttopcost = errMatrix(r-1, c-1);
            [aux,idx]   = min([costup costleft ... 
                               lefttopcost]);
            errMatrix(r,c) = aux  - helperM1(r,c) + ...
                bbeta*helperM2(r,c);
        end
    end
    oc = errMatrix(end,end);
    return
