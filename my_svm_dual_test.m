
% svm prediction function
function [prediction, probability] = my_svm_dual_test(model,Test_data)
    prediction = zeros(size(Test_data,1),1);
    
    switch( model.options.method )
      case 'binary'
        K = my_svm_kernelfunction(Test_data, model.supportVector, model.options);
        P= K.*repmat(model.supportVectorAlphaClasses, 1, size(Test_data, 1))';
        P1 = sum(P,2)+model.bias;
        
        a=1;
        b=0;
        z = 1+exp(a*abs(P1)+b);
        probability = 1./z';
        
        predictionIDX1 = logical(P1 > 0);
        prediction( predictionIDX1) = model.labelMax;
        prediction(~predictionIDX1) = model.labelMin;
      
      case {'std_multiclass_basic_architecture',...
            'std_multiclass_basic_ext_architecture',...
            'std_multiclass_sophisticated_architecture',...
            'unimodal_basic_architecture',...
            'unimodal_basic_architecture_other',...
            'unimodal_sophisticated_architecture'}
        
        n        = size(Test_data,1);
        bias     = model.bias;
        zz       = model.zz;
        features = model.features;
        K        = model.nclasses;

        HH = zeros(n,K);
        for k=1:K
            supportVectorIdx = (abs(zz(:,k))  > model.options.epsilon);
            supportVector    = features(supportVectorIdx,:);
            
            Kernel = my_svm_kernelfunction(supportVector, Test_data, model.options);
            
            aux     = repmat (zz(supportVectorIdx, k), 1, n);
            HH(:,k) = sum(aux.*Kernel, 1)' + bias(k);
        end
        [aux, prediction] = max(HH,[], 2);

      % case {'std_multiclass_sophisticated_architecture','unimodal_sophisticated_architecture'}
      %   n        = size(Test_data,1);
      %   bias     = model.bias;
      %   zz       = model.zz;
      %   features = model.features;
      %   K        = model.nclasses;
    
      %   HH = zeros(n,K);
      %   for k=1:K
      %       supportVectorIdx = (abs(zz(:,k))  > model.options.epsilon);
      %       supportVector    = features(supportVectorIdx,:);
            
      %       Kernel = my_svm_kernelfunction(supportVector, Test_data, model.options);
            
      %       aux     = repmat (zz(supportVectorIdx, k), 1, n);
      %       HH(:,k) = sum(aux.*Kernel, 1)' + bias(k);
      %   end
      %   [aux, prediction] = max(HH,[], 2);
        
        
        
    end
    
    return;