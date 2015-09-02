function K = my_svm_kernelfunction(V1, V2, options)
    kernel = options.kernel;

    switch kernel
      case 'linear'
        % linear transformation
        K = V1*V2';            
      
      case 'polynomial'
        % polynomial
        K = (options.gamma*V1*V2'+options.coef).^options.degree;
      
      case 'rbf'
        % radial basis function transformation
        ones1 = ones(size(V1, 1), 1);
        ones2 = ones(size(V2, 1), 1);
        K = exp(-options.gamma*(sum(V1.^2,2)*ones2' + ones1*sum(V2.^2,2)' - 2*V1*V2'));
      
      case 'sigmoid'
        % sigmoid transformation
        K = tanh( options.gamma * V1*V2' + options.coef);
        
      otherwise
        error('Unknown kernel function');            
    end
    K = double(K);
    return;