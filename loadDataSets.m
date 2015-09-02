function [trainSetFeatures,trainSetClass,testSetFeatures, testSetClass,K] = loadDataSets(method)
    testSetFeatures = [];
    testSetClass    = [];
    
    switch(method)
      case 'synthetic3'
        [trainSetFeatures,trainSetClass,K] = synthetic3();
      case 'synthetic5'
        [trainSetFeatures,trainSetClass,K] = synthetic5();
      case 'edistribution'
        [trainSetFeatures,trainSetClass] = edistribution();
      case 'letter'
        [trainSetFeatures,trainSetClass] = letter();
      case 'pasture'
        [trainSetFeatures,trainSetClass,K] = pasture();
      case 'lev'
        [trainSetFeatures,trainSetClass,K] = lev();
      case 'esl'
        [trainSetFeatures,trainSetClass,K] = esl();
      case 'swd'
        [trainSetFeatures,trainSetClass,K] = swd();
      case 'bcct'
        [trainSetFeatures,trainSetClass,K] = bcct();
      
      case 'winequality-red'
        [trainSetFeatures,trainSetClass,K] = winequality_red();
      
      case 'winequality-white'
        [trainSetFeatures,trainSetClass,K] = winequality_white();
        
      case 'poker'
        [trainSetFeatures,trainSetClass,testSetFeatures, testSetClass,K] = poker();
            
      case 'car'
        [trainSetFeatures, trainSetClass,K] = car();
      
      case 'balance'
        [trainSetFeatures, trainSetClass,K] = balance();
    
      otherwise
        str = sprintf('Dataset ''%s'' unknown.\n',method);
        error(str);
    end
    
    return
    

%% synthetic3                                                      
function [trainSetFeatures,trainSetClass,K] = synthetic3()
    data = testCreateArtificialData(100);
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    K = max(trainSetClass);
    return;

%% synthetic5                                                      
function [trainSetFeatures,trainSetClass,K] = synthetic5()
    data = testCreateArtificialData2(65);
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    K = max(trainSetClass);

    return;
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trainSetFeatures,trainSetClass] = edistribution()
    [data, classes] = Edistribution (50);
    trainSetFeatures = data;
    
    idx1 = (classes == 0);
    
    trainSetClass(idx1,1) = 1;
    trainSetClass(~idx1,1) = 3;
    
    return
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trainSetFeatures,trainSetClass] = letter()
    fd = fopen('../datafiles/letter/letter-recognition.data','r');
    class = [];
    data  = [];

    i = 1;
    while 1
        fline = fgetl(fd);
        if ~ischar(fline),   break,   end
        
        %disp(fline)
        c = str2num(sprintf('%d',fline(1)))-65+1; 

        if ( c > 5 ), continue, end
        % classes are between 1-26
        class(i) = c;
        main = str2num(fline(3:end));
        data(i,:)  = main;

        i = i + 1;
    end
    fclose(fd);

    % %% lets create spaces between class so reject option (oSVM) may work
    % class = (class-65)*2;

    trainSetFeatures = data;
    trainSetClass = class';
    
    return
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trainSetFeatures,trainSetClass,K] = pasture()
    
    fd = fopen('../datafiles/agridatasets/pasture.csv');

    trainSetFeatures = [];
    trainSetClass    = [];

    first = true;
    while 1
        fline = fgetl(fd);
        if first == true, first = false; continue, end
        if ~ischar(fline),   break,   end

        idx = regexp(fline,',');
        
        switch(fline(1:idx(1)-1))
          case 'LL'
            d = [1 0 0 0];
          case 'LN'
            d = [0 1 0 0];
          case 'HN'
            d = [0 0 1 0];
          case 'HH'
            d = [0 0 0 1];
        end
        
        for i=1:length(idx)-1
            v = fline(idx(i)+1:idx(i+1)-1);
            d = [d, str2num( v ) ];
        end

        trainSetFeatures = [trainSetFeatures; d];
        
        switch( fline(idx(end)+1:end) )
          case 'LO'
            c = 1;
          case 'MED'
            c = 2;
          case 'HI'
            c = 3;
        end
        
        trainSetClass = [trainSetClass; c];
    end
    fclose(fd);
    K = max(trainSetClass);
    
    
    maxc = max(max(trainSetFeatures));
    minc = min(min(trainSetFeatures));
    trainSetFeatures = ( maxc - trainSetFeatures ) / (maxc - minc);

    nelements = size(trainSetFeatures,1);
    ind = randperm(nelements);
    
    trainSetFeatures = trainSetFeatures(ind,:);
    trainSetClass    = trainSetClass(ind,:);
    return
    
%% ESL
%
function [trainSetFeatures,trainSetClass, K] = esl()
    data = dlmread('../../datafiles/arie_ben_david/ESL.csv');
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);

    K = max(trainSetClass);
    return

%% LEV
%
function [trainSetFeatures,trainSetClass, K] = lev()
    data = dlmread('../../datafiles/arie_ben_david/LEV.csv');
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end)+1;

    nelements = size(trainSetFeatures,1);
    ind = randperm(nelements);
    
    trainSetFeatures = trainSetFeatures(ind,:);
    trainSetClass    = trainSetClass(ind,:);
    
    K = max(trainSetClass);
    return

%% SWD
%
function [trainSetFeatures,trainSetClass, K] = swd()
    data = dlmread('../../datafiles/arie_ben_david/SWD.csv');
    
    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end)+1;

    nelements = size(trainSetFeatures,1);
    ind = randperm(nelements);
    
    trainSetFeatures = trainSetFeatures(ind,:);
    trainSetClass    = trainSetClass(ind,:);
    
    Kmin = min(trainSetClass);

    trainSetClass = trainSetClass - Kmin + 1;

    K = max(trainSetClass);
    
    return

%% bcct
%
function [trainSetFeatures,trainSetClass, K] = bcct()
    data = dlmread('../../datafiles/bcct/bcct.csv');

    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);

    K = max(trainSetClass);
    
    
    % feature selection
    % trainSetFeatures = trainSetFeatures(:,[9,11,20,26]);
    
    return;

%% winequality-red
%
function [trainSetFeatures,trainSetClass, K] = winequality_red()
    data = dlmread('../../datafiles/winequality/winequality-red.csv');

    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);

    K = max(trainSetClass);

    return;

%% winequality-white
%
function [trainSetFeatures,trainSetClass, K] = winequality_white()
    data = dlmread('../../datafiles/winequality/winequality-white.csv');

    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);

    % normalize
    minK = min(trainSetClass);
    maxK = max(trainSetClass);

    trainSetClass = trainSetClass-minK+1;
    K = max(trainSetClass);

    return;
    
%% Poker                                                                
% 
function [trainSetFeatures,trainSetClass, testSetFeatures, testSetClass,K] = poker()
    features = dlmread('../datafiles/poker/poker-hand-training-true.data');

    trainSetClass     = features(:,end)+1;
    trainSetFeatures  = features(:,1:end-1);
    K = max(trainSetClass);
    
    nelements = size(trainSetFeatures,1);
    idx       = randperm(nelements);
    idx       = idx(1:80);
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);
    
    features = dlmread('../datafiles/poker/poker-hand-testing.data');
    
    testSetClass     = features(:,end)+1;
    testSetFeatures  = features(:,1:end-1);
    nelements = size(testSetFeatures,1);
    idx       = randperm(nelements);
    idx       = idx(1:1000);
    
return

function [trainSetFeatures,trainSetClass, K] = car()
    data = dlmread('../datafiles/car/car.csv');

    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx  = randperm(size(trainSetFeatures,1));
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);

    K = max(trainSetClass);
return

function [trainSetFeatures,trainSetClass, K] = balance()
    data = dlmread('../../datafiles/balance/balance.csv');

    trainSetFeatures = data(:,1:end-1);
    trainSetClass    = data(:,end);
    
    idx  = randperm(size(trainSetFeatures,1));
    
    trainSetFeatures = trainSetFeatures(idx,:);
    trainSetClass    = trainSetClass(idx,:);

    K = max(trainSetClass);
return
