

%% Create Artificial/Synthetic Data 
% Generates n gaussian with different means
function data = testCreateArtificialData2( nSamples )
    
    nclasses = 3;
    dimension = 2;

    var1  = 3;
    var2  = 5;
    var3  = 2;
    
    mean1 = -2;
    mean2 =  2;
    mean3 =  5;
    
    sample1 = mvnrnd([mean1 mean1], [var1 0; 0 var1], nSamples);
    sample2 = mvnrnd([mean2 mean2], [var2 0; 0 var2], nSamples);
    sample3 = mvnrnd([mean3 mean3], [var3 0; 0 var3], nSamples);
    
    classes = [repmat(1,nSamples,1); repmat(2,nSamples,1); repmat(3,nSamples,1)];
    
    noise   = repmat(0.025+0.225*rand(1,dimension),nSamples*nclasses,1);

    data    = [sample1; sample2; sample3];
    data    = data + noise;

    data    = [data, classes];

    idx  = randperm(nSamples*nclasses);
    data = data(idx,:);

    %plot_features(data)
    
return

