
% svm prediction function
function [prediction, probability] = my_svm_dual_test(model,Test_data)
    prediction = zeros(size(Test_data,1),1);

    K = my_svm_kernelfunction(Test_data, model.supportVector, model.options);
    P= K.*repmat(model.supportVectorAlphaClasses, 1, size(Test_data, 1))';
    P1 = sum(P,2)+model.bias;

    a=1;
    b=0;
    z = 1+exp(a*abs(P1)+b);
    probability = 1./z';

    predictionIDX1 = logical(P1 > 0);
    prediction(predictionIDX1) = model.labelMax;
    prediction(~predictionIDX1) = model.labelMin;

    return;