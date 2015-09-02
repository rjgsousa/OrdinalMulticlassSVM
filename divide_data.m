function index = divide_data( nfold, class )
    nobservations = size( class, 1 );

    npartitions = size(nfold,2);
    if ( npartitions == 2 )
        part1_end = nfold(1)*nobservations;
        idx1 = round(1:part1_end);
        idx2 = round(part1_end+1:nobservations);

        index{1} = idx1;
        index{2} = idx2;

        return
    end

    foldsSize     = nobservations/nfold;

    index = [];
    for i=1:nfold
        idx   = round((i-1)*foldsSize+1:i*foldsSize);
        index = [index; idx];
    end
    
    return;
