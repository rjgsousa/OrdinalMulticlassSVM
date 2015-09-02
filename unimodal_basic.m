function [zz,bias] = unimodal_basic(n,K,features,classes,options,qqprog)

    supportVector = [];
    supportVectorAlphaClasses = [];
    
    NA = n*(K-1);
    NZ = n*K;
    
    % ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    f       = -[ zeros(NZ,1); ones(NA, 1) ]; % first zij, then alpha's
    
    lb      = [ -inf*ones(NZ,1); zeros(NA,1); ];
    ub      = [ +inf*ones(NZ,1); options.C * ones(NA, 1);];
    
    % Aeq: [K+n,NN]
    beq = zeros(K+NZ, 1);
    Aeq = zeros(K+NZ, NZ+NA);
    % restriction 3.72
    for k=1:K
        Aeq(k, [1:n] + (k-1)*n) = ones(1, n);
    end

    pos = K+1;
    for i=1:n
        cls = classes(i);
        for k=1:K
            Aeq(pos, sub2ind([n K], i, k)) = 1;
            if ( k>1 )
                Aeq(pos, NZ+sub2ind([n K-1], i, k-1)) = -((k>=2)&(k<=cls)) + (k>=cls+1);
            end
            if ( k<K )
                Aeq(pos, NZ+sub2ind([n K-1], i, k))   = (k<=cls-1) - ((k>=cls)&(k<= K-1));
            end
            pos=pos+1;
        end
    end
    
    HH = my_svm_kernelfunction (features, features, options);
    
    H = zeros (NZ+NA, NZ+NA);
    for i=1:n
        for k=1:n
            for j=1:K
                idx1 = sub2ind([n, K], i, j);
                idx2 = sub2ind([n, K], k, j);
                H(idx1,idx2) = HH(i,k);
            end
        end
    end
    
    [alpha,fval,exitflag] = optimize( H, f, Aeq, beq, [], [], lb, ub, qqprog, options );

    zz     = alpha(1:NZ,1);
    alphas = alpha(NZ+1:end,1);
    
    zz     = reshape (zz, n, K);
    alphas = reshape(alphas, n, K-1);
    % ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    
    HH = zeros(n,K);
    for i = 1:K
        supportVectoridx = abs( zz(:,i) ) > options.epsilon;
        supportVector    = features(supportVectoridx,:);
        
        Kernel = my_svm_kernelfunction( supportVector, features, options);
        aux    = repmat(zz(supportVectoridx,i), 1, n);

        P   = Kernel .* aux;
        
        HH(:,i) = sum(P,1)';
    end

    % bias computation
    % restriction 3.66
    % alpha > 0 & \xi = 0
    counter=1;
    for i=1:n
        cls = classes(i);
        for k=1:K
            if (k==cls)
                continue;
            end
            if (abs(zz(i,k)) < options.epsilon)
                continue;
            end
            if (abs(zz(i,k)) > options.C-options.epsilon)
                continue;
            end            
            y(counter)=1 + HH(i,k) - HH(i,cls);
            equation(counter,:)=zeros(1,K);
            equation(counter,cls) = 1;
            equation(counter,k) = -1;
            counter = counter +1;
        end
    end
    equation(counter,:)=zeros(1,K);
    equation(counter,1)=1;
    y(counter) = 0;
    
    %A\b for inv(A)*b
    bias = (equation'*equation)\(equation'*y');
    return