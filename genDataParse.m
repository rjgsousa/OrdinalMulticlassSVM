
function genDataParse()
    
    rand('twister', 5489);
    randn('state',8817);

    
    [ features, classes ] = loadDataSets('synthetic3');

    trainFeatures = features(1:20,:);
    trainClasses  = classes(1:20,:);
    
    testFeatures = features(21:40,:);
    testClasses  = classes(21:40,:);

    parse(trainFeatures,trainClasses,'bsvm/train.data');
    parse(testFeatures,testClasses,'bsvm/test.data');
    return
    
