%% oSVM                                                             
% author: Jaime S. Cardoso
% See: Learning to Classify Ordinal Data: The Data Replication Method
function model = oSVM_train(features, classes, nclasses, options, qqprog)

    [features_rep, classes_rep] = xreplicateData(features,classes,nclasses,options);

    model = struct();
    if options.method_parameter
        handle_kernel_fun = @(U,V) my_svm_kernelfunction(U, V, options);
        model = svmtrain(features_rep, classes_rep, 'Autoscale', ...
                         0, 'BoxConstraint', options.C , 'Kernel_Function', handle_kernel_fun,'quadprog_opts',optimset('maxiter',3000));
        % .* weights
        model.options = options;
    else
        model = my_svm_dual_train ( features_rep, classes_rep, options, qqprog);
    end

    model.nclasses = nclasses;

    return;

    
