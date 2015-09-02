%% Kendal Tau
% 
function [tau,z ] = kendalltaub(data,K)
    
    tab = contingency_table(data,K);

    [i j] = size(tab);
    en1 = 0.0;
    en2 = 0.0;
    s   = 0.0;
    nn  = i*j;
    points = tab(i,j);

    for k=0:(nn-2)
        ki = floor(k/j);
        kj = k - j*ki;
        points = points + tab( floor(ki+1), floor(kj+1) );
        for l=(k+1):(nn-1)
            li = floor(l/j);
            lj = l-j*li;
            m1 = li - ki;
            m2 = lj - kj;
            mm = m1 * m2;

%             info = sprintf('(%d,%d) vs (%d,%d)',ki+1, ...
%                            kj+1,li+1,lj+1);
%             disp(info)

            pairs = tab(floor(ki+1),floor(kj+1)) * tab(floor(li+1),floor(lj+1));
            if mm ~= 0
                en1 = en1 + pairs;
                en2 = en2 + pairs;
                if mm > 0, s = s+pairs;, else s = s-pairs;, end
            else
                if m1 ~= 0 en1 = en1 + pairs;, end
                if m2 ~= 0 en2 = en2 + pairs;, end
            end
            %%pause
        end
    end
    tau  = s/sqrt(en1*en2);
    svar = (4.0*points+10.0)/(9.0*points*(points-1.0));
    z    = tau/sqrt(svar);
    
    return;
    
    
