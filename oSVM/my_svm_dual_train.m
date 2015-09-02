function model = my_svm_dual_train(features, classes, options, qqprog)
    maxiter = 7000;
    
    options = check_svm_options(options,size(features,2));
    %%  svm options

    %% train data size
    N = size(features,1);
    
    %% when targets have values equal to zero,
    %% the values in the hessian matrix are annulated
    %% so, this is exchanged towards Vapnick notation
    maxc = max(classes);
    minc = min(classes);
    classes = (classes*2-minc-maxc)/(maxc-minc);
    
    classes_matrix = repmat(classes, 1, N);

    %% aplies a kernel (linear, polynomial, and so on)
    K = my_svm_kernelfunction( features, features, options );

    %% Hmatrix calculation
    H=K.*classes_matrix.*classes_matrix';

    %% f is multiplied with (-1) because we are minimizing
    %% whereas dual form maximizes..
    f   = -ones(N,1);
    Aeq = classes';
    beq = 0;
    lb  = zeros(N,1);

    if  ( size(options.C,1) == 2 )
        ub = zeros(N,1);
        C1 = logical(classes==1);
        ub(C1) = options.C(1);
        ub(~C1) = options.C(2);
    elseif ( size(options.C,1) > 1 )
        %% C is a vector of tradeoff
        ub = options.C;
    else
        ub = options.C.*(ones(N,1));
    end

    %% quadratic programming solver
    %% alpha are the lagrange multipliers
    switch qqprog
      case 'quadprog'
        quadprog_options = optimset('MaxIter',maxiter,'TolFun',options.epsilon,'TolX', options.epsilon,'Display','off');
        [alpha, fval, exitflag, output, lambda] = quadprog(H,f,[],[],Aeq,beq,lb,ub,[],quadprog_options);
      case 'intpoint'
        quadprog_options = sprintf('sigfig_9_maxiter_%d__margin_0.005_bound_10',maxiter);
        optimizer = intpoint_pr(quadprog_options);
        [alpha, dual, how] = optimize(optimizer, f, H, Aeq, beq, lb, ub);
      case 'qpc'
        [alpha,err,lm] = qpip(H,f,[],[],Aeq,beq,lb,ub,0,0,0);
    end
    
    %% we want only the lagrange multpliers with values above 0
    %% values equal to zero do nothing in the prediction
    supportVectorIdx = (alpha  > options.epsilon);
    supportVector = features(supportVectorIdx,:);
    supportVectorAlphaClasses = classes(supportVectorIdx).*alpha(supportVectorIdx);
    
    %% b value assessment
    supportVectorIdxM = find(alpha > options.epsilon & alpha < ub-options.epsilon);
    supportVectorM = features(supportVectorIdxM,:);
    supportVectorClassesM = classes(supportVectorIdxM);
    
    % kernel computation
    K = my_svm_kernelfunction(supportVector, supportVectorM, options);
    %supportVectorAlphaClassesRepetition = repmat(supportVectorAlphaClasses, 1,length(supportVectorM));
    supportVectorAlphaClassesRepetition = repmat(supportVectorAlphaClasses, 1,size(supportVectorM,1));
    bias = supportVectorClassesM' - sum(supportVectorAlphaClassesRepetition.*K ,1);
    bias = (1/length(bias))*(sum(bias));
    
    model = struct('supportVector', supportVector, 'supportVectorAlphaClasses', supportVectorAlphaClasses, 'bias', bias, 'options',options,'labelMax',maxc,'labelMin' ,minc );
    return;