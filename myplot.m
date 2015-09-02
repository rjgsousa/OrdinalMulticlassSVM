function myplot(features,classes,K)
    plotgraphopt = ['m+'; '*g'; '<k'; 'xr'; '>y'];
    color = [0.8 0.8 0.8; 
             0.5 0   0; 
             0   0.5 0;
             0   0   0.5;
             0.5 0   0.5;
            ];
    
    %% screen size
    scrsz = get(0,'ScreenSize');

    h = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)]);
    %figure
    for k=1:K
        idx = find(classes == k );
        plot (features(idx,1), features(idx,2), plotgraphopt(k,:), 'MarkerSize',12,'MarkerFaceColor',color(k,:));
        hold on;
    end
    hold off
    return;