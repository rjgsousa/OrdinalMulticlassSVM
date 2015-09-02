%% oSVM                                                             
% author: Jaime S. Cardoso
% See: Learning to Classify Ordinal Data: The Data Replication Method
function [predict,prob] = oSVM_test( model, test_data )
    nclasses = model.nclasses;
    
    [test_data_rep] = xreplicateData(test_data,[],nclasses,model.options);
    
    if model.options.method_parameter
        predict_aux = svmclassify( model, test_data_rep );
    else
        [predict_aux, prob] = my_svm_dual_test ( model, test_data_rep );
    end
    
    predictionIDX1 = logical(predict_aux == -1);
    predict_aux(predictionIDX1) = 0;

    step = length(predict_aux)/(nclasses-1);

    for i=1:(nclasses-1)
        stepi = (i-1)*step+1;
        endi  = (i-1)*step+step;
        predict(i,:) = predict_aux(stepi:endi);
    end
    
    predict = 1+sum(predict,1);
    
    return;