
%%                                                                                       
%
function [zz,bias] = unimodal_basic_other(classesDiffidx,n,K,features,classes,options,qqprog)

    disp('---> unimodal basic (other) <---')
    classes
    
    supportVector = [];
    supportVectorAlphaClasses = [];

    NA = n*K;

    % ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    f       = -ones(NA, 1); % only alphas
    lb      = zeros(NA,1);
    ub      = options.C * ones(NA, 1);
    
    idx = [];
    for i=1:K
        if i <= length(classesDiffidx)
            ind = find ( classes == classes(classesDiffidx(i)) );
            idx = [idx; (i-1)*n+ind];
        end
    end
    
    % f(idx)  = 0;
    % lb(idx) = -inf;
    % ub(idx) = +inf;
    
    beq = zeros(NA, 1 );
    Aeq = zeros(NA, NA);
    size(Aeq)
    
    pos = 1;
    for i=1:n
        cls = classes(i);
        for k=1:K
            
            if ( k>1 )
                Aeq(pos, sub2ind([n K-1], i, k-1)) = -((k>=2)&(k<=cls)) + (k>=cls+1);
            end
            
            if ( k<K )
                Aeq(pos, sub2ind([n K-1], i, k))   = (k<=cls-1) - ((k>=cls)&(k<= K-1));
            end
            
            pos = pos + 1;
        end
    end
    Aeq
    size(Aeq)
    kkkkkkkkkkkkkkkkkkkkkkkkkkk
    
    
    HH = my_svm_kernelfunction (features, features, options);
    
    H  = zeros (NA, NA);
    for i=1:n
        for k=1:n
            for j=1:K
                idx1 = sub2ind([n, K], i, j);
                idx2 = sub2ind([n, K], k, j);
                H(idx1,idx2) = HH(i,k);
            end
        end
    end
    
    size(H)
    size(f)
    size(Aeq)
    size(beq)
    size(lb)
    size(ub)

    
    % we exchange the upper and lower bounds because we have
    % lb < -alpha < ub <=> ... <=> -ub < alpha < -lb
    t = cputime;
    [alpha,fval,exitflag] = optimize( H, f, Aeq, beq, [], [], lb, ub, qqprog, options );
    fprintf(1,'Optimization took %f seconds (%s)\n\n',cputime-t,qqprog);
    
    zz     = reshape (alpha, n, K);
    
    zz
    exitflag
    options
    kkk
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