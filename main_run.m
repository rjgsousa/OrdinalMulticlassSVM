function result = main_run(options,combinations,log_best_options_fd,dataSetID)
    global optimization_method
    global best_results
    
    %global STEPS
    %STEPS = 0;    
    optimization_method = options.optimization_method;
    
    switch( options.errorfnt )
      case {'mse','mad','mer','oci'}
        v = inf;
      case {'tau','rint','spearman'}
        v = -inf;
    end
    
    best_results = struct('libsvm',{v, struct()},...
                          'bsvm',{v struct()},...
                          'std_multiclass_basic_architecture',{v struct()},...
                          'std_multiclass_basic_ext_architecture',{v struct()},...
                          'std_multiclass_sophisticated_architecture',{v struct()},...
                          'unimodal_basic_architecture',{v struct()},...
                          'unimodal_basic_architecture_other',{v struct()},...
                          'unimodal_sophisticated_architecture',{v struct()},...
                          'oSVM',{v struct()});
    
    [ features, classes, testFeatures, testClasses, K ] = loadDataSets(dataSetID);
    options.nclasses = K;
    
    result = 1;
    % if options.run <= 74
    %     result = -1;
    %     return 
    % else
    %     global allResults;
    %     allResults1 = load('allResults_nruns=100_tau_winequality-red_rbf.mat');
    %     allResults  = allResults1.allResults;
    % end
    % opt = {'ro','b<','k>'}
    % for i =1:3
    %     ind = classes == i;
    %     plot(features(ind,1),features(ind,2),opt{i})
    %     hold on
    % end
    % akaka
    
    if isempty( testFeatures )
        % ------------------------------------------------------------
        % divide data
        trainIDX = [];

        for i = 1:K
            ind = find ( classes == i );
            trainSize = round( length(ind) * .4); 
            trainIDX  = [trainIDX; ind(1:trainSize) ];
        end
        
        trainIDX = trainIDX';
        ind      = randperm(length(trainIDX));
        trainIDX = trainIDX(ind);
        
        testIDX  = setxor(trainIDX,1:size(features,1));
        
        trainFeatures = features(trainIDX,:);
        trainClasses  = classes(trainIDX,:);
        
        testFeatures  = features(testIDX,:);
        testClasses   = classes(testIDX,:);
    else
        trainFeatures = features;
        trainClasses  = classes;
    end
    
    fprintf(1,'Training dataset size: %d\n',size(trainFeatures,1));
    % --------------------------------------------------------------
    for i=1:length(options.all_methods)
        
        options.method = options.all_methods{i};
        fprintf(1,'Method: %s\n',options.method);
        
        totalcomb = size(combinations,2);
        
        fprintf(1,'(START) Time: %s\n',datestr(now,'HH:MM:SS'))
        %STARTTIME = tic;
        % train & validation
        for j=1:totalcomb
            
            if strcmp(options.kernel,'rbf') == 1
                options.C     = combinations(1,j); %% Cvalue
                options.gamma = combinations(2,j); %% gamma; 

            elseif strcmp(options.kernel,'polynomial')
                
                options.C     = combinations(1,j);
                if options.degree > 1
                    options.gamma = combinations(2,j);
                else
                    options.gamma = 1;
                end
            end
            
            perform_cross_validation(trainClasses,trainFeatures,testClasses,testFeatures,options)
            
            if ( mod(j,10) == 0 )
                fprintf(1, '#################### Progress: %.2f%% (%d/%d)\n',(j*100)/totalcomb,j,totalcomb);
            end
        end
        fprintf(1,'(END) Time: %s\n',datestr(now,'HH:MM:SS'))
        % toc( STARTTIME )
    
        % test 
        reset_perf(options);

        best_options = getfield(best_results(2),options.method);
        
        perf = runAllTogetherMethods(trainClasses,trainFeatures,testClasses,testFeatures,best_options);
        check_perf(perf,options);

        log_best_options( log_best_options_fd, best_options );
    end

    return
    
    
function log_best_options(log_best_options_fd, best_options)
    fprintf(log_best_options_fd,'\t ****** method: %s\n',best_options.method);
    fprintf(log_best_options_fd,'C: %d\n',log(best_options.C)/log(2));
    fprintf(log_best_options_fd,'gamma: %d\n',log(best_options.gamma)/log(2));
    
    best_options;
    return
    
% -----------------------------------------------------------------------------
function perform_cross_validation(trainClasses,trainFeatures,testClasses,testFeatures,options)
    global best_results
    
    index = divide_data( options.nfolds, trainFeatures );
    perf  = zeros(1,options.nfolds);
    
    for k = 1:options.nfolds
    
        idx = setxor(k,1:options.nfolds);
        
        trainIDX = index(idx,:);
        trainIDX = trainIDX(:)';
        
        valIDX   = index(k,:);
        
        xdataT = trainFeatures(trainIDX,:);
        ydataT = trainClasses(trainIDX,:);
        
        xdataV = trainFeatures(valIDX,:);
        ydataV = trainClasses(valIDX,:);

        % runBSVM(trainClasses,trainFeatures,testClasses,testFeatures,options);

        perf(k) = runAllTogetherMethods(ydataT,xdataT,ydataV,xdataV,options);
    end

    perf = mean(perf);
    check_perf(perf,options);
    
    return

% -----------------------------------------------------------------------------
function perf = runLIBSVM(trainClasses,trainFeatures,testClasses,testFeatures,options)

    t = cputime;
    % fprintf(1,'========== LIBSVM ==========\n');
    config =  sprintf('-s 0 -t %d -d %d -r 1 -g %d -c %d -e %d ', ...
                      options.kernel_type,options.degree,options.gamma,...
                      options.C,options.epsilon);

    model2   = svmtrain(trainClasses,trainFeatures,config);
    predict  = svmpredict(testClasses,testFeatures,model2,'-b 0');
    perf     = calc_perf(testClasses,predict,options);
    
    return
    
% -----------------------------------------------------------------------------
function runBSVM(trainClasses,trainFeatures,testClasses,testFeatures,options)
    fprintf(1,'========== BSVM ==========\n');
    t = cputime;
    config =  sprintf('-s 2 -t %d -d %d -r 1 -g %d -c %d -e %d ', ...
                      options.kernel_type,options.degree,options.gamma,...
                      options.C,options.epsilon);
    
    parse(trainFeatures,trainClasses,'bsvm/train.data');
    parse(testFeatures,testClasses,'bsvm/test.data');
    
    exitcode= unix(['./bsvm/bsvm-train ',config,'bsvm/train.data bsvm/train_model']);
    unix('./bsvm/bsvm-predict bsvm/test.data bsvm/train_model bsvm/classified_result');
    predict = dlmread('bsvm/classified_result');
    perf    = calc_perf(testClasses,predict,options);

    fprintf(1,'BSVM perf: %.2f %%\n',perf);
    fprintf(1,'BSVM took %f seconds\n\n',cputime-t);
    return
    
% -----------------------------------------------------------------------------
function perf = runAllTogetherMethods(trainClasses,trainFeatures,testClasses,testFeatures,options)
    global optimization_method

    % for i = 1:options.nclasses
    %     fprintf(1,'N. elements for class %d = %d\n',i,length( find(trainClasses==i)));
    % end

    t = cputime;
    switch options.method
      case 'libsvm'
        perf = runLIBSVM(trainClasses,trainFeatures,testClasses,testFeatures,options);
      
      case 'oSVM'
        osvm_model = oSVM_train( trainFeatures, trainClasses, options.nclasses, options,'qpc');
        predict    = oSVM_test ( osvm_model, testFeatures)';
        perf       = calc_perf(testClasses,predict,options);
      
      otherwise
        qqprog         = optimization_method;

        model1   = my_svm_dual_train(trainFeatures, trainClasses, options, qqprog);
        predict  = my_svm_dual_test(model1,testFeatures);
        perf     = calc_perf(testClasses,predict,options);
    end
    
    if options.verbose > 0
        fprintf(1,'multiclass perf (%s): %.2f\n',options.errorfnt,perf);
        fprintf(1,'%s took %f seconds\n\n',options.method,cputime-t);
    end
    
    return
    
% -----------------------------------------------------------------------------
function check_perf(perf,options)
    global best_results 
    
    v = getfield( best_results(1), options.method );

    switch( options.errorfnt )
      case {'mse','mad','mer','oci'}
        if v > perf
            best_results(1) = setfield(best_results(1),options.method,perf);
            best_results(2) = setfield(best_results(2),options.method,options);
        end
      
      case {'tau','rint','spearman'}
        if v < perf
            best_results(1) = setfield(best_results(1),options.method,perf);
            best_results(2) = setfield(best_results(2),options.method,options);
        end
    end

    return

% -----------------------------------------------------------------------------
function reset_perf( options)
    global best_results 

    switch( options.errorfnt )
      case {'mse','mad','mer','oci'}
        v = inf;
      case {'tau','rint','spearman'}
        v = -inf;
    end

    best_results(1) = setfield(best_results(1),options.method,v);

    return
