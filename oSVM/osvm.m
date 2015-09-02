function best_options = osvm( folds, combinations, wr, options, trainSetFeatures, trainSetClass )

    global best_error
    %global best_model
    global roc_data

    %% divides data in train and test sets
    %nfolds = [.05 .95];

    [ features, classes ] = divide_data( folds, trainSetFeatures, trainSetClass );
    dataTest   = features{2};
    classTest  = classes{2};

    %% constructs the final dataset 
    full_classTrain = classes{1};
    full_dataTrain  = features{1};

    %% lets do the cross validation
    nfolds = options.nfolds;
    [ features, classes, K ] = divide_data( nfolds, features{1}, classes{1} );
    info = sprintf('Doing a %d-fold Cross Validation',nfolds);
    disp(info)

    %% some initializations
    error       = ones(1,nfolds);
    perf_reject = zeros(1,nfolds);
    perf_error  = zeros(1,nfolds);
    
    foldsIDX = 1:nfolds;
    progress = 1;
    total    = size(combinations,2)*length(wr)*nfolds;
    
    init = cputime;
    
    %options.trueDim = size(features{1},2);
    
    for i=1:length(wr)
        best_options = struct();
        best_error  = inf;
        %best_reject = inf;
        options.wr  = wr(i);%combinations(2,i);
        options.wr;

        for j=1:size(combinations,2)
            
            options.C     = combinations(1,j); %% Cvalue
            options.gamma = combinations(2,j); %% gamma; 
            options.h     = combinations(3,j); %% h
            options.s     = combinations(4,j); %% s
            
            for k=1:nfolds
                if (mod(progress-1,10) == 0 || j == 1) 
                    print_progress(progress,total,cputime-init) 
                end
                progress = progress + 1;

                %% gets the nfolds-1 folds for train
                %% the remain will be for the validation
                trainIDX = setxor(k,foldsIDX);
                
                dataTrain  = [];
                classTrain = [];
                
                for l=1:length(trainIDX)
                    dataTrain  = [dataTrain; features{trainIDX(l)}];
                    classTrain = [classTrain; classes{trainIDX(l)}];
                end

                dataVal   = features{k};
                classVal  = classes{k};
                
                osvm_model = oSVM_train( dataTrain, classTrain, K, options,'qpc');
                predict    = oSVM_test ( osvm_model, dataVal);
                [error(k),perf_error(k),perf_reject(k)] = calc_perf(predict, classVal, options.wr);
                
            end
            error_ = mean(error);
            
            % lets save the options for future use
            if error_ < best_error 
                best_options  = options;
                best_error    = error_;
            end
            
        end

        info = sprintf('Training with 50%% of the data (time %.2f sec)',cputime-init);
        disp(info)

        osvm_model           = oSVM_train( full_dataTrain, full_classTrain, K, best_options,'qpc');
        
        info = sprintf('Testing with 50%% of the data (time %.2f sec)',cputime-init);
        disp(info)

        predict                         = oSVM_test ( osvm_model, dataTest);
        [error_, perror_, perf_reject_] = calc_perf ( predict, classTest, options.wr);

        roc_data = [roc_data; perf_reject_ perror_ 0 0 options.wr]

        disp ( sprintf('best C: %f | best gamma: %f ',best_options.C,best_options.gamma) )
    end
    
    return;
    
    
%% --------------------------------------------------------------------------------------------
function [error, perror, perf_reject] = calc_perf( predict, classVal, wr)
    irej = (predict == 2);
    % reject performance ( how many points were rejected )
    howmanyrejected = sum(irej);

    % how many points where rejected faced to how many points
    % are truly to reject
    perf_reject = (howmanyrejected/length(predict)); %RR
    
    % points that were not classified as to reject
    predict_reject_idx = ~irej; %setxor(z,1:length(predict));
    
    % error performance ( how many errors have been commited )
    z = find( (predict(predict_reject_idx) ~= classVal(predict_reject_idx)'));
    
    howmanyerror = length(z);
    perror       = (howmanyerror/length(predict)); %*100 %ER
    
    % error = wr * perf_reject + (.5 - wr) * perror;
    error = wr * perf_reject + perror;
    return;

%% --------------------------------------------------------------------------------------------
function print_progress(progress,total,time)
    global best_error;
    
    p = progress / total * 100;
    info = sprintf('(Progress: %.2f %% | time: %.2f sec.) best (mean) performance so far: %.2f %%',p,time,(1-best_error)*100);
%     timeleft = 100*time/p;
%     info2 = sprintf('\nTime left: %.2f sec',timeleft-time);
%     info = strcat(info,info2);
    
    disp(info)
    return;
