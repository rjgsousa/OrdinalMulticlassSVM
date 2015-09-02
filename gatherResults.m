function gatherResults(opt_method)
    global best_results
    global allResults
     

    for i=1:length(opt_method)
        v = getfield(allResults,opt_method{i});
        v = [v, getfield(best_results,opt_method{i})];
        allResults = setfield(allResults,opt_method{i},v);
    end

    %best_results
    %allResults

    return
    