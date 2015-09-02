
%% Ordinal Coefficient Measure rint
%
function res = rint(data,K)
    data;
    tab = contingency_table(data,K);
    
    rowsum = sum(tab,1);
    colsum = sum(tab,2);
    total  = sum(rowsum);
        
    % card s1
    colsum_  = repmat(colsum,1,length(colsum))';
    colsum__ = tril(colsum_');
    cards1  = sum ( sum( colsum__ .* colsum_ ) ) - total;
    
    v = 0;
    for i =1:size(tab,2)
        v1 = 0;
        for j = i:size(tab,2)
            v1 = v1 +  colsum(j);
        end
        v = v + colsum(i)*(v1 - 1);
    end
    %v = v - total;
    d = [cards1 v];
    if diff(d) ~= 0, error('bad rint - 1.\n'), end
    
    % card s2
    rowsum_  = repmat(rowsum,length(rowsum),1);
    rowsum__ = tril( repmat(rowsum',1,length(rowsum)) );
    cards2   = sum( sum( rowsum__ .* rowsum_ ) ) - total;

    v = 0;
    for i =1:size(tab,2)
        v1 = 0;
        for j = i:size(tab,2)
            v1 = v1 +  rowsum(j);
        end
        v = v + rowsum(i)*(v1 - 1);
    end
    %v = v - total;    
    d = [cards2 v];
    if diff(d) ~= 0, error('bad rint - 2.\n'), end
    
    % card s1 \vee s2
    numerator = 0;
    for i = 1:K
        for j = 1:K
            for iprime = i:K
                for jprime = j:K
                    numerator = numerator + tab(i,j)*tab(iprime,jprime);
                end
            end
        end
    end
    
    numerator   = numerator - total;
    denominator = sqrt ( cards1 * cards2 );
    
    res = -1 + 2 * ( numerator / denominator );
    
    res;
    %pause
    %kkk
    return