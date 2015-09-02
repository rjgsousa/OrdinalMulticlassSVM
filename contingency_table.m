%% Contingency Table
%
function tab = contingency_table( data, K )
    
    t = data(1,:); %% t - target
    o = data(2,:); %% o - obtained
    
    i = K;
    j = K;
    
    tab = zeros(i,j);

    for x=1:length(o)
        i = o(x);
        j = t(x);
        tab(i,j) = tab(i,j) + 1;
    end
    return;