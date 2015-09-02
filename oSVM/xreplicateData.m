%% oSVM                                                             
% author: Jaime S. Cardoso
% See: Learning to Classify Ordinal Data: The Data Replication Method

% based on equation (2) on page 6 of JMLR article "Learning to Classify Ordinal Data: The Data Replication Method"
% NOTE: the number of replicas per observation is variable and is determined by the class number 
function [features_rep, classes_rep] = xreplicateData(features, classes, nclasses, options)
    
    H = options.h;
    s = options.s;

    if (isempty(classes))   %when testing, classes can be an empty vector
        s=nclasses-1;   %
        classes = ones(size(features,1),1);
    end
    
    Eye      = eye(nclasses-2);
    
    leftIdx  = find (classes == 1);
    rightIdx = find (classes >=2 & classes<=min(nclasses,1+s));  
    
    features_rep = [features([leftIdx; rightIdx],:) zeros(length(leftIdx)+length(rightIdx),nclasses-2)];
    classes_rep  = [-ones(length(leftIdx), 1); ones(length(rightIdx), 1)];
    
    for q=2:(nclasses-1)
        
        leftIdx      = find (classes >= max(1, q-s+1) & classes<= q);
        rightIdx     = find (classes >=q+1 & classes<=min(nclasses,q+s));   
        Ones         = ones(length(leftIdx) + length(rightIdx), 1);
        
        features_rep = [features_rep; features([leftIdx; rightIdx], :) H*Ones*Eye(q-1,:)];
        classes_rep  = [classes_rep; -ones(length(leftIdx), 1); ones(length(rightIdx), 1)];
    end

    return