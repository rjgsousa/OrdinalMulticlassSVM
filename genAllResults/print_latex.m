function print_latex(all_means, all_stds, titlename, opt_method,measures)

    textstr = '\documentclass[a4paper]{article}\usepackage{lscape}\usepackage[left=2cm,top=2cm,right=3.5cm]{geometry}\begin{document}\begin{landscape}';
    textstr = [textstr '\begin{table}[!h]\begin{tabular}{'];
    for i = 1:size(all_means,2)+1
        textstr = [textstr 'c'];
    end
    textstr = [textstr '} Method '];
    % header
    
    for i = 1:length(opt_method)
        flag = 1;
        switch( opt_method{i} )
          case 'libsvm'
            name = 'pairwise';
            
          case 'std_multiclass_basic_architecture'
            name = 'standard (basic)';
            
          case 'std_multiclass_basic_ext_architecture'
            name = 'standard (basic, extended)';
            
          case 'std_multiclass_sophisticated_architecture'
            name = 'standard (sophisticated)';
            
          case 'unimodal_basic_architecture'
            name = 'unimodal (basic)';
            
          case 'unimodal_sophisticated_architecture'
            name = 'unimodal (sophisticated)';

          case 'oSVM'
            name = 'oSVM';
            
          otherwise
            flag = 0;
            continue
        end
        if flag
            textstr = [textstr '& ' name ];
        end
    end
    textstr = [textstr '\\'];
    
    for i=1:size(all_means,1)
        textstr = [textstr measures{i}];
        for j = 1:size(all_means,2)
            textstr = [textstr sprintf(' & %.2f (%.2f)', all_means(i,j),all_stds(i,j))];
        end
        textstr = [textstr '\\'];
    end
    textstr = [textstr '\end{tabular}'];
    textstr = [textstr '\caption{mean ( std. dev. ) for each method and measure.}'];
    textstr = [textstr '\end{table}'];
    textstr = [textstr '\end{landscape}\end{document}'];

    textstr;
    fid = fopen(['latex/' titlename '.tex'],'w');
    fwrite( fid, textstr );
    fclose( fid );

    return