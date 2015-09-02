function options = check_svm_options(options,num_attr)

    % C value
    r = isfield(options,'C');
    if r ~= 1
        options.C = 1;
    end

    % weights
    r = isfield(options,'weights');
    if r == 1
        wi = options.weights;
        options.C = wi.*options.C;
    else
        options.weights = ones(size(options.C,1),1);
    end

    % coef value
    r = isfield(options,'coef');
    if r ~= 1
        options.coef = 1.;
    end

    % epsilon
    r = isfield(options,'epsilon');
    if r ~= 1
        options.epsilon = 0.001;
    end

    % gamma
    r = isfield(options,'gamma');
    if r ~= 1
        k = num_attr;
        options.gamma = 1/k;
    end
    
    % kernel
    r = isfield(options,'kernel');
    if r ~= 1
        options.kernel = 'linear';
    end

    % degree
    r = isfield(options,'degree');
    if r ~= 1
        options.degree = 1;
    end

    return;