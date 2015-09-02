function [zz, bias] = std_multiclass_basic(classesDiffidx,n,K,features,classes,options,qqprog)
    
    supportVector = [];
    supportVectorAlphaClasses = [];
    alpha = [];
    
    NZ = n*K;
    
    % ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    idx = [];
    for i=1:K
        if i <= length(classesDiffidx)
            ind = find ( classes == classes(classesDiffidx(i)) );
            idx = [idx; (i-1)*n+ind];
        end
    end

    f       = ones(n * K,1);
    f(idx)  = 0;
    
    lb      = zeros(n * K,1);
    lb(idx) = -inf;
    
    ub      = options.C * ones(n * K,1);
    ub(idx) = +inf;

    beq = zeros(K+n, 1 );
    Aeq = zeros(K+n, NZ);
    % restriction 3.62 (first branch)
    for k=1:K
        Aeq(k, [1:n] + (k-1)*n) = ones(1,n);
    end
    % restriction 3.72
    for j=1:n
        Aeq(j+K, sub2ind([n K], j*ones(1,K), [1:K])) = ones(1, K);
    end
    
    HH = my_svm_kernelfunction (features, features, options);
    
    H = zeros (NZ, NZ);
    for i=1:n
        for k=1:n
            for j=1:K
                idx1 = sub2ind([n, K], i, j);
                idx2 = sub2ind([n, K], k, j);
                H(idx1,idx2) = HH(i,k);
            end
        end
    end
    
    % we exchange the upper and lower bounds because we have
    % lb < -alpha < ub <=> ... <=> -ub < alpha < -lb
    
    t = cputime;
    [zz,fval,exitflag] = optimize( H, f, Aeq, beq, [], [], -ub, -lb, qqprog, options );
    fprintf(1,'Optimization took %f seconds (%s)\n\n',cputime-t,qqprog);
    
    zz = reshape (zz, n, K);
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
                continue
            end
            if (abs(zz(i,k)) < options.epsilon)
                continue
            end
            if (abs(zz(i,k)) > options.C-options.epsilon)
                continue
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