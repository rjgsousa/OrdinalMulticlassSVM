function [alpha, fval, exitflag] = optimize(H,f,Aeq,beq,A,b,lb,ub,qqprog,options)
    maxiter = 7000;
    
    fval = 0;
    exitflag = inf;
    
    %% quadratic programming solver
    %% alpha are the lagrange multipliers
    X0     = []; %ones(size(lb,1),1);
    t = cputime;
    switch qqprog
      case 'cplex'
        if options.verbose > 0
            fprintf(1,'\nStarting CPLEX\n');
        end
        % 
        % cplexoptions = cplexoptimset('cplex');
        % cplexoptions.barrier.crossover  = -1;
        % cplexoptions.emphasis.numerical = 1;
        
        % cplexoptions.feasopt.mode       = 1;
        % cplexoptions.feasopt.tolerance  = options.epsilon;

        % cplexoptions.sifting.algorithm  = 1;
        
        % cplexoptions.simplex.display    = 0;
        % cplexoptions.simplex.tolerances.feasibility = options.epsilon;
        % cplexoptions.simplex.tolerances.optimality  = options.epsilon;

        % cplexoptions.workmem = 512;
        % cplexoptions.qpmethod = 0;
        
        cplexoptions = cplexoptimset('MaxIter',maxiter,'Display','off','Diagnostics','off','TolFun',options.epsilon,...
                                     'TolXInteger',options.epsilon,'TolRLPFun',options.epsilon);
        [alpha,fval,exitflag,output] = cplexqp(H,f,A,b,Aeq,beq,lb,ub,[],cplexoptions);
        if options.verbose > 0
            %if exitflag > 1
            fprintf(1,'\nExitFlag: %d\n',exitflag);
            fprintf(1,'Solution status: %s (%s)\n',output.cplexstatusstring,output.message);
            % output
            % kakakak
            %end
        end
      
      case 'quadprog'
        % TolFun   Termination tolerance on the function value, a
        %          positive scalar. The default is 100*eps, about
        %          2.2204e-14.
        % TolCon   Termination tolerance on the constraint
        %          violation, a positive scalar. The default
        %          is 1e-6.
        % TolX     Termination tolerance on x, a positive
        %          scalar. The default is 1e-6.
        % TolXInteger Tolerance within which the value of a
        %             variable is considered to be integral (a
        %             positive scalar). The default is 1.0e-8.
        % TolRLPFun   Termination tolerance on the function value
        %             of a linear programming relaxation problem
        %             (a positive scalar). The default is 1.0e-6.
     
                                    % 'Simplex','on',...
                                    % 'TolFun'     ,options.epsilon,...
                                    % 'TolCon'     ,options.epsilon,...
                                    % 'TolX'       ,options.epsilon,...
                                    % 'TolXInteger',options.epsilon,...
                                    % 'TypicalX'   ,ones(size(H,1),1),...
        
        
        quadprog_options = optimset('Display','off',...
                                    'TolFun'     ,options.epsilon,...
                                    'TolCon'     ,options.epsilon,...
                                    'TypicalX'   ,ones(size(H,1),1),...
                                    'MaxIter',maxiter);

        %         %quadprog_options = optimset('Algorithm','interior-point','Hessian',{'lbfgs',100});
        %         quadprog_options = optimset('Algorithm','sqp'); %,'ObjectiveLimit',options.epsilon,'ScaleProblem','none'
        %         quadprog_options = optimset(quadprog_options,'Display','off','MaxIter',maxiter);
        %         quadprog_options;
        [alpha, fval, exitflag, output, lambda] = ...
            quadprog(H, f, A, b, Aeq, beq, lb, ub,X0,quadprog_options);
        %         fprintf(1,'Iterations: %d \t CGITERATIONS: %d\n',output.iterations,output.cgiterations);
      
      case 'ga'
        f1 = @(x)qp(x,H,f);
        [alpha, fval, exitflag, output] = ...
            ga(f1,length(f),A,b,Aeq,beq,lb,ub);
        alpha = alpha';
        
        fprintf(1,'Generations: %d\n',output.generations);
      
      case 'mexclp'
        options.solver = 1;

        % options.epsilon = 1e-2;
        optimization_options.maxnumiterations = maxiter;
        optimization_options.verbose = 0;
        optimization_options.primalpivot = 1;
        optimization_options.dualpivot   = 1;
        
        optimization_options.primaltolerance = options.epsilon;
        optimization_options.dualtolerance   = options.epsilon;
        [alpha,z,exitflag] = clp(H,f,A,b,Aeq,beq,lb,ub,optimization_options);
      
      case 'intpoint'
        quadprog_options = sprintf('sigfig_9_maxiter_%d__margin_0.005_bound_10',maxiter);
        optimizer = intpoint_pr(quadprog_options);
        [alpha, dual, how] = optimize(optimizer, f, H, Aeq, beq, lb, ub);
      
      case 'qpc'
        % this option gives huge errors - use it with care!
        [alpha,err,lm] = qpip(H,f,A,b,Aeq,beq,lb,ub,0,0,0);
    end
    if options.verbose > 0
        fprintf(1,'Optimization took %f seconds (%s) with exitflag %d\n\n',cputime-t,qqprog,exitflag);
    end
    
    return

function y = qp(x,H,f)
    
    y = .5 * x * H * x' + f' * x';
    
    return