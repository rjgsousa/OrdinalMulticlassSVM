%% PERFORMANCE MEASURE
%
function p = calc_perf(true,pred,options)
    
    switch ( options.errorfnt )
      case 'tau'
        % KENDALL TAU
        
        tau = kendalltaub([true,pred]',options.nclasses);
        
        if isnan(tau), tau = -1;,end

        p = tau;
        
      case 'rint'
        p = rint([true,pred]',options.nclasses);

      case 'oci'
        tab = contingency_table([true,pred]', options.nclasses);
        p = OrdinalClassificationIndex(tab,options.nclasses);

        if isnan(p), p = 1;,end
        
      case 'mse'
        % MSE
        right = sum( (true - pred).^2 );
        mse   = right / length(pred);

        p = mse;
      case 'mad'
        right = sum( abs(true - pred) );
        mad   = right / length(pred);
    
        p = mad;

      case 'spearman'
        p = corr(true,pred,'type','Spearman');

        if isnan(p), p = -1;,end

      case 'mer'
        p = true - pred;
        p = sum ( p ~= 0 ) / length( true );
        
    end    

    return