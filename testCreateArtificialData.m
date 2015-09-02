function data = testCreateArtificialData(n)
    data = createArtificialData(n);
    % create artificial data
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = createArtificialData(nSamples)    
    theta = [-inf, -1, -.1, .25, 1, inf];
    dimension = 2;
    features = rand( nSamples, dimension );

    data = [];
    stdDev = 0.125;
    for i = 1:nSamples
        d = features(i,:);
        x = d - 0.5;
        x = prod (x);
        x = x*10;
        epsilon = stdDev*randn; 
        class = x + epsilon;
        class = theta > class;
        class = find(~class);
        class = size(class, 2);

        data = [data; d class];
    end 

    return;
