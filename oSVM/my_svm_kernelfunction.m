function K = my_svm_kernelfunction(V1, V2, options)
    kernel = options.kernel;

    switch kernel
      case 'linear'
        % linear transformation
        K = V1*V2';            
      
      case 'semipolynomial'
        % polynomial
        
        V1_ = V1(:,1:options.trueDim);
        V2_ = V2(:,1:options.trueDim);
        
        K = (options.gamma*V1_*V2_'+options.coef).^options.degree;
        
        V1_ = V1(:,options.trueDim+1:end);
        V2_ = V2(:,options.trueDim+1:end);
        %K1 = (options.gamma*V1_*V2_'+options.coef);
        
        %jsc approach
        K1 = V1_*V2_';
        K = K + K1;
        
      case 'polynomial'
        % polynomial
        K = (options.gamma*V1*V2'+options.coef).^options.degree;
      
      case 'rbf'
        % radial basis function transformation
        ones1 = ones(size(V1, 1), 1);
        ones2 = ones(size(V2, 1), 1);
        K = exp(-options.gamma*(sum(V1.^2,2)*ones2' + ones1*sum(V2.^2,2)' - 2*V1*V2'));
      
      case 'semirbf'
        % radial basis function transformation
        ones1 = ones(size(V1, 1), 1);
        ones2 = ones(size(V2, 1), 1);
        
        V1_ = V1(:,1:options.trueDim);
        V2_ = V2(:,1:options.trueDim);
        
        K = exp(-options.gamma*(sum(V1_.^2,2)*ones2' + ones1*sum(V2_.^2,2)' - 2*V1_*V2_'));
        V1_ = V1(:,options.trueDim+1:end);
        V2_ = V2(:,options.trueDim+1:end);

        K1 = V1_*V2_';
        K = K + K1;
        
      case 'sigmoid'
        % sigmoid transformation
        K = tanh( options.gamma * V1*V2' + options.coef);
        
      otherwise
        error('Unknown kernel function');            
    end
    K = double(K);
    return;