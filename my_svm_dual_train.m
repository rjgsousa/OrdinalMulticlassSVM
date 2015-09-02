function model = my_svm_dual_train(features, classes, options, qqprog)
    warning all on
    
    options = check_svm_options(options,size(features,2));
    %%  svm options

    %% train data size
    n = size(features,1);

    % calculates the number of existent classes
    K = options.nclasses;

    alpha = [];
    supportVector = [];
    supportVectorAlphaClasses = [];

    switch options.method
        % --------------------------------------------------------------------------------------
      case 'binary'
        %% f is multiplied with (-1) because we are minimizing
        %% whereas svm dual form maximizes..
        f   = -ones(n,1);

        %% aplies a kernel (linear, polynomial, and so on)
        Kernel = my_svm_kernelfunction( features, features, options );

        classes_matrix = repmat( classes, 1, n );
        H = Kernel.*classes_matrix.*classes_matrix';

        Aeq = classes';
        beq = 0;
        % ---------------------------------------------------------------------------------------------------------
        
      case 'std_multiclass_basic_architecture'
        [zz, bias] = std_multiclass_basic(classesDiffidx,n,K,features,classes,options,qqprog);
      
      case 'std_multiclass_basic_ext_architecture'
        [zz, bias] = std_multiclass_basic_ext(n,K,features,classes,options,qqprog);

      case 'std_multiclass_sophisticated_architecture'
        [zz, bias] = std_multiclass_sophisticated( n,K,features,classes,options,qqprog);

      case 'unimodal_basic_architecture'
        [zz, bias] = unimodal_basic( n, K, features, classes, options, qqprog );

      % case 'unimodal_basic_architecture_special'
      %   [zz, bias] = unimodal_basic_special( n,K,features,classes,options,qqprog );

      % case 'unimodal_basic_architecture_other'
      %   [zz, bias] = unimodal_basic_other( classesDiffidx,n,K,features,classes,options,qqprog );
        
      case 'unimodal_sophisticated_architecture'
        [zz, bias] = unimodal_sophisticated( n,K,features,classes,options,qqprog );
    end
    
    options.nclasses = K;
    model = struct('zz',zz,'alpha',alpha, 'features', features, 'nclasses', K, ...
                   'supportVector', supportVector, 'supportVectorAlphaClasses', ...
                   supportVectorAlphaClasses, ...
                   'bias', bias, 'options',options);

    return;