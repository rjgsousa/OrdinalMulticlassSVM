%% unimodal project main file
%
function main()
    clear all
    format long
    
    format long
    
    warning off all;

    rmpath('libsvm_binaries/');
    rmpath('oSVM/');
    rmpath('mexclp/');
    
    % addpath('libsvm_binaries/');
    % addpath('oSVM/');
    % addpath('mexclp/');
    
    rmpath(genpath('/home/rsousa/opt/ilog/cplex/matlab/'))
    addpath(genpath('/home/rsousa/opt/ilog/cplex/matlab/'))
    
    % max num of threads
    % maxnumcompthreads(2);

    dataSetID = 'synthetic3';
    
    epsilon = 1e-5;

    rand('twister', 5489);
    randn('state',8817);
    
    Cvalue = -3:2:10 
    Cvalue = 2.^Cvalue;
    gamma  = -3:2:3 
    gamma  = 2.^gamma;

    opt_method = {'libsvm',...
                  'std_multiclass_basic_architecture',...
                  'std_multiclass_basic_ext_architecture',...
                  'std_multiclass_sophisticated_architecture',...
                  'unimodal_basic_architecture',...
                  'unimodal_sophisticated_architecture'};
    
    opt_method = {'std_multiclass_basic_ext_architecture',...
                  'std_multiclass_sophisticated_architecture',...
                  'unimodal_basic_architecture',...
                  'unimodal_sophisticated_architecture'};

    % opt_method = {'unimodal_basic_architecture'};
    % -------------------------------------------------------------------------------
    options = struct('epsilon',epsilon,'datasetname',dataSetID);
    options.all_methods = opt_method;
    options.method_parameter = 1;

    options.kernel   = 'polynomial';
    options.weights  = 1;
    options.degree   = 2;
    options.coef     = 1;
    options.method   = '';
    options.nfolds   = 5;
    options.verbose  = 0;
    options.optimization_method = 'quadprog'; %{'quadprog','mexclp','cplex'};

    % measures = {'new','mad','mer','mse','tau','spearman','rint'};
    
    switch options.kernel
      case 'polynomial'
        options.kernel_type  = 1;
      case 'rbf'
        options.kernel_type  = 2;
    end

    switch ( options.kernel )
      case {'linear',0}
        % linear
        combinations = combvec( Cvalue );

      case {'polynomial','rbf',1,2,3}
        % polynomial, rbf
        combinations = combvec( Cvalue, gamma );
    end
    
    nruns   = 50;
    results = [];
    options
    global allResults

    %measures = {'mer','spearman','tau'};
    %measures = {'mer','spearman','tau','oci'};
    measures = {'mer'};

    for k = 1:length(measures)
        options.errorfnt = measures{k};
	
        %'bsvm',[],...
        allResults = struct('libsvm',[],...
                            'std_multiclass_basic_architecture',[],...
                            'std_multiclass_basic_ext_architecture',[],...
                            'std_multiclass_sophisticated_architecture',[],...
                            'unimodal_basic_architecture',[],...
                            'unimodal_sophisticated_architecture',[],...
                            'unimodal_basic_architecture_other',[],...
                            'oSVM',[]);
        allResults.kernel = options.kernel;
        allResults.degree = options.degree;
        allResults.nfolds = options.nfolds;
        allResults.nruns  = nruns;
        allResults.epsilon = options.epsilon;
        allResults.optimization = options.optimization_method;
        allResults.errorfnt = options.errorfnt;
        allResults
        
        log_best_options_fd = fopen('log_best_options','w');
        filename = sprintf('allResults_nruns=%d_%s_%s_%s.mat',nruns,options.errorfnt,dataSetID,options.kernel);
        
        STARTTIME = tic;
        for i=1:nruns
            options.run = i;
            fprintf(1,'================ RUN NUMBER: %d ================\n',i)
            exitcode = main_run(options,combinations,log_best_options_fd,dataSetID);
            if exitcode == -1
                continue
            end
            gatherResults(opt_method);

            allResults
            save(filename, 'allResults')
        end
        
        fprintf(1,'Entire process took %f seconds\n\n',toc(STARTTIME));
        fclose(log_best_options_fd);
        

        save(filename, 'allResults')
        % dlmwrite('results.txt',results,'delimiter',',');
    end
    return
    
