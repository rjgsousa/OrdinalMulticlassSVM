function concatenate_res(errorfnt)
    v = load(['allResults_nruns=10_' errorfnt '_lev_pol3']);
    v = v.allResults;
    
    allResults = load(['../results/lev/pol3/allResults_nruns=10_' errorfnt]);
    allResults = allResults.allResults;
    
    v.libsvm = allResults.libsvm;
    v.std_multiclass_basic_architecture = allResults.std_multiclass_basic_architecture;
    v.std_multiclass_basic_ext_architecture = allResults.std_multiclass_basic_ext_architecture;
    v.std_multiclass_sophisticated_architecture = allResults.std_multiclass_sophisticated_architecture;
    v.unimodal_basic_architecture = allResults.unimodal_basic_architecture;
    v.unimodal_sophisticated_architecture = allResults.unimodal_sophisticated_architecture;
    
    allResults = v;
    allResults
    
    filename = ['allResults_nruns=10_' errorfnt '.mat'];
    save(filename,'allResults');