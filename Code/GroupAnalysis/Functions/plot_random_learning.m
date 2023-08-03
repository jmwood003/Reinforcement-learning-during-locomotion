function plot_random_learning(T, subjs_to_plot)

%Get all subject IDs
subj_IDs = unique(T.SID);

miss_color = '#67a9cf';
hit_color = '#ef8a62';

%Set up plotting
figure('Position', [10 200 1500 900], 'Color','w');
ax_pos = [0.05, 0.6; 0.37, 0.6; 0.7, 0.6;...
    0.05, 0.1; 0.37, 0.1; 0.7, 0.1];

%Loop through subjects
for subj_idx = 1:length(subjs_to_plot)

    %Get the current subject name for indexing 
    if isnumeric(subjs_to_plot)
        current_subj_id = subj_IDs{subjs_to_plot(subj_idx)};
    else
        current_subj_id = subjs_to_plot(subj_idx);
    end

    %Index the current subject
    learning_idx = find(strcmp(current_subj_id,T.SID)==1 & strcmp('learning',T.phase)==1);
    
    %Index data
    LSL = T.prctLSL(learning_idx);
    success = T.Success(learning_idx);
    trgt_hi = T.TrgtHi_prct(learning_idx);
    trgt_lo = T.TrgtLo_prct(learning_idx);

    %Remove nans
    nan_idx = find(isnan(LSL)==1);
    LSL(nan_idx) = [];
    success(nan_idx) = [];
    trgt_hi(nan_idx) = [];
    trgt_lo(nan_idx) = [];

    %Index hits and misses
    miss_idx = find(success==0);
    hit_idx = find(success==1);

    %Plot
    axes('Position', [ax_pos(subj_idx,1), ax_pos(subj_idx,2), 0.27, 0.35]); hold on
    s1 = scatter(miss_idx,LSL(miss_idx), 'o', 'MarkerFaceColor', miss_color, 'SizeData',50);
    s2 = scatter(hit_idx,LSL(hit_idx), 'o', 'MarkerFaceColor', hit_color);
    alpha(s1,0.5);     alpha(s2,0.5);
    plot(1:length(trgt_hi),trgt_hi, 'k--','LineWidth',2);
    plot(1:length(trgt_lo),trgt_lo, 'k--','LineWidth',2);
    plot(1:length(LSL),zeros(length(LSL),1),'k-','LineWidth',1);
    xlim([-10, 910]); ylim([-20, 40]);
    set(gca,'FontSize',20, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
    if subj_idx==1
        ylabel('\DeltaLSL (%)','FontSize',25,'FontName','Ariel');
        text(100, 35, 'Hit', 'Color', hit_color, 'FontSize', 25, 'FontName', 'Ariel', 'HorizontalAlignment', 'left');
        text(100, 30, 'Miss', 'Color', miss_color, 'FontSize', 25, 'FontName', 'Ariel', 'HorizontalAlignment','left');
    elseif subj_idx==2
        title('TE Individuals','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
    elseif subj_idx==4
        ylabel('\DeltaLSL (%)','FontSize',25,'FontName','Ariel');
    elseif subj_idx==5
        title('RPE Individuals','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
        xlabel('Learning Steps','FontSize',25,'FontName','Ariel');
    end

end


end