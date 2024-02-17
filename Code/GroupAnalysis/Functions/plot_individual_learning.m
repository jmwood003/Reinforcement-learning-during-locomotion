function plot_individual_learning(T, percentiles)

%Get all subject IDs
subj_IDs = unique(T.SID);

%Find the subjects with the median, 75th, 25th percentiles of learning variability
for s = 1:length(subj_IDs)

    %Make an indexing variable for the group
    if strcmp(subj_IDs{s}(1),'V')==1
        GrpIdx(s,1) = 2;
    elseif strcmp(subj_IDs{s}(1),'R')==1
        GrpIdx(s,1) = 1;
    end
    
    baseline_idx = find(strcmp(subj_IDs{s},T.SID)==1 & strcmp('baseline',T.phase)==1);
    learning_idx = find(strcmp(subj_IDs{s},T.SID)==1 & strcmp('learning',T.phase)==1);

    %baseline variability
    bsl_LSL = T.prctLSL(baseline_idx);
    bsl_LSL(isnan(bsl_LSL)==1) = [];
    bsl_var = std(bsl_LSL(end-49:end));

    %Index variables
    lrn_lsl = T.prctLSL(learning_idx);
    target = T.Trgt_prct(learning_idx);
    nan_idx = find(isnan(lrn_lsl)==1);
    lrn_lsl(nan_idx) = [];
    target(nan_idx) = [];

    %Seperate out early and late variability
    maxPerturbIdx = find(target==10);
    early_var(s,1) = std(lrn_lsl(maxPerturbIdx(1:50)))/bsl_var;

end

rpe_prcts = prctile(early_var(GrpIdx==1),percentiles);
te_prcts = prctile(early_var(GrpIdx==2),percentiles);
prcts = [rpe_prcts; te_prcts];

group_order = [2,1];
subjs_to_plot = [];
for g = 1:2
    group_idx = group_order(g);
    for p = 1:length(te_prcts)
        [~,min_i] = min(abs(prcts(group_idx,p) - early_var(GrpIdx==group_idx)));
        subj_names = subj_IDs(GrpIdx==group_idx);
        subjs_to_plot = [subjs_to_plot; subj_names(min_i)];
    end
end

disp(subjs_to_plot);

%Set up plotting
figure('Position', [10 200 1500 900], 'Color','w');
ax_pos = [0.05, 0.6; 0.37, 0.6; 0.7, 0.6;...
    0.05, 0.1; 0.37, 0.1; 0.7, 0.1];
plt_titles = [percentiles, percentiles];

%colors
miss_color = '#67a9cf';
hit_color = '#ef8a62';

%Loop through subjects
for subj_idx = 1:length(subjs_to_plot)

    %Get the current subject name for indexing 
    current_subj_id = subjs_to_plot(subj_idx);

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
    text(450,38, [num2str(plt_titles(subj_idx)), '^{th} Percentile'], 'FontSize', 20, 'FontWeight', 'bold', 'FontName', 'Ariel', 'HorizontalAlignment','center');
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