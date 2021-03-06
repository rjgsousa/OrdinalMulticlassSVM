function [zz, bias] = std_multiclass_sophisticated(n,K,features,classes,options,qqprog)
    beq = 0;
    
    supportVector = [];
    supportVectorAlphaClasses = [];
    alpha = [];
    
    NA = n*(K-1);
    NZ = n*K;
    
    % ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

    f  = -[zeros(NZ,1); ones(NA, 1)];
    lb = [-inf*ones(NZ,1); zeros(NA, 1)];
    ub = [+inf*ones(NZ,1); options.C * ones(NA, 1)];

    beq = zeros(K+NZ, 1);
    Aeq = zeros(K+NZ, NZ+NA);

    % restriction 3.62 (first branch)
    for k=1:K
        Aeq(k, [1:n] + (k-1)*n) = ones(1,n);
    end
    pos = K+1;
    for i=1:n
        cls = classes(i);
        for k=1:K
            if ( k<cls )
                Aeq(pos, sub2ind([n K], i, k)) = 1;
                Aeq(pos, NZ+sub2ind([n K-1], i, k)) = 1;
            elseif ( k>cls )
                Aeq(pos, sub2ind([n K], i, k)) = 1;
                Aeq(pos, NZ+sub2ind([n K-1], i, k-1)) = 1;
            else
                Aeq(pos, sub2ind([n K], i*ones(1,K), [1:K])) = ones(1, K);
            end
            pos = pos+1;
        end
    end

    % -------------------------------------------------------------------------+
    A = zeros(n,NZ+NA);
    for j=1:n
        A(j, NZ+sub2ind([n K-1], j*ones(1,K-1), [1:K-1])) = ones(1, K-1);
    end
    A = [A; -A];
    b = [options.C * ones( n, 1 ); zeros(n,1)];
    % -------------------------------------------------------------------------+
    
    HH = my_svm_kernelfunction ( features, features, options );
    
    H = zeros( NZ+NA, NZ+NA );
    for i=1:n
        for k=1:n
            for j=1:K
                idx1 = sub2ind( [n, K], i, j );
                idx2 = sub2ind( [n, K], k, j );
                H(idx1,idx2) = HH(i,k);
            end
        end
    end
    
    % we exchange the upper and lower bounds because we have
    % lb < -alpha < ub <=> ... <=> -ub < alpha < -lb
    [res,fval,exitflag] = optimize( H, f, Aeq, beq, A, b, lb, ub, qqprog, options );

    zz     = res(1:NZ,1);
    alphas = res(NZ+1:end,1);
    
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
