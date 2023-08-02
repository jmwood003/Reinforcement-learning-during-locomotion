function [anova_T, trl_hist_anova_T, trl_hist_regress_T] = plot_learning_exploration(T)

subjs = unique(T.SID);

trial_history_idx = [1, 1, 1;...
    1, 1, 0;...
    1, 0, 1;...
    1, 0, 0;...
    0, 1, 1;...
    0, 1, 0;...
    0, 0, 1;
    0, 0, 0];

trial_history = nan(length(subjs),8);
trial_history_anova = [];
for s = 1:length(subjs)

    %Make an indexing variable for the group
    if strcmp(subjs{s}(1),'V')==1
        GrpIdx(s,1) = 2;
    elseif strcmp(subjs{s}(1),'R')==1
        GrpIdx(s,1) = 1;
    end

    %Indexing variable for experiment
    if contains(subjs{s},'ER')==1
        exp_idx(s,1) = 2;
    else
        exp_idx(s,1) = 1;
    end

    %Index phases
    lrn_idx = find(strcmp(subjs{s},T.SID)==1 & strcmp('learning',T.phase)==1);
    bsl_idx = find(strcmp(subjs{s},T.SID)==1 & strcmp('baseline',T.phase)==1);

    %-----------------------Baseline variability---------------------------
    bsl_lsl = T.prctLSL(bsl_idx);
    bsl_lsl(isnan(bsl_lsl)==1) = [];
    bsl_var(s,1) = std(bsl_lsl(end-149:end));

    %Learning
    lrn_lsl = T.prctLSL(lrn_idx);
    success = T.Success(lrn_idx);

    %Remove nans
    nan_idx = find(isnan(lrn_lsl)==1);
    lrn_lsl(nan_idx) = [];
    success(nan_idx) = [];

    %Index successes
    miss_idx = find(success==0);
    hit_idx = find(success==1);
    padded_lsl = [lrn_lsl; nan(3,1)];

    %--------------------Win/stay lose shift behavior----------------------
    miss_idx = find(success==0);
    hit_idx = find(success==1);
    padded_lsl = [lrn_lsl; nan];

    change_after_miss(s,1) = nanmean(abs(padded_lsl(miss_idx+1) - padded_lsl(miss_idx)));
    change_after_hit(s,1) = nanmean(abs(padded_lsl(hit_idx+1) - padded_lsl(hit_idx)));

% 
%     %-----------------------Win stay lose shift----------------------------
%     delta_miss(s,1) = nanmean(abs(padded_lsl(miss_idx+1) - padded_lsl(miss_idx)));
%     delta_hit(s,1) = nanmean(abs(padded_lsl(hit_idx+1) - padded_lsl(hit_idx))); 

%     delta_miss(s,2) = nanmean(abs(padded_lsl(miss_idx+2) - padded_lsl(miss_idx)));
%     delta_hit(s,2) = nanmean(abs(padded_lsl(hit_idx+2) - padded_lsl(hit_idx)));    
% 
%     delta_miss(s,3) = nanmean(abs(padded_lsl(miss_idx+3) - padded_lsl(miss_idx)));
%     delta_hit(s,3) = nanmean(abs(padded_lsl(hit_idx+3) - padded_lsl(hit_idx)));    

%     %Trial to trial change 
%     change_after_miss = nanmedian((padded_lsl(miss_idx+1) - padded_lsl(miss_idx)).^2);
%     change_after_hit = nanmedian((padded_lsl(hit_idx+1) - padded_lsl(hit_idx)).^2);
%     explore_ttc(s,1) = change_after_miss - change_after_hit;

%     %Attc method of exploration 
%     explore_attc(s,1) = ExpATTC(success,lrn_lsl);

%     %Loop through reward history 
%     padded_success = [nan(3,1); success];
%     padded_lsl = [nan(3,1); lrn_lsl; nan];
%     for trl_idx = 1:size(trial_history_idx,1)
%         
%         %Find the trial with the specific reward history
%         history = trial_history_idx(trl_idx,:);
%         first_trl_idx = find(padded_success==history(1));
%         past_idx = find(padded_success(first_trl_idx-1)==history(2) & padded_success(first_trl_idx-2)==history(3));
%         history_idx = first_trl_idx(past_idx);
% 
%         %Caluclate the absolute change after each trial
%         trial_history(s, trl_idx) = nanmean(abs(padded_lsl(history_idx) - padded_lsl(history_idx+1)));
%         trial_history_anova = [trial_history_anova; trial_history(s, trl_idx)];
%     end

%     %Set up regression 
%     abs_delta_u = abs(diff(lrn_lsl));
%     padded_r = [nan(2,1); success];
%     r_current = 1-success(1:end-1);
%     r_1past = 1-padded_r(2:end-2);
%     r_2past = 1-padded_r(1:end-3);
%     X = [ones(length(abs_delta_u),1), r_current, r_1past, r_2past];
%     betas(:,s) = regress(abs_delta_u, X);

end

% %Group indexing variables
% rpe1_idx = find(GrpIdx==1 & exp_idx==1);
% te1_idx = find(GrpIdx==2 & exp_idx==1);
% rpe2_idx = find(GrpIdx==1 & exp_idx==2);
% te2_idx = find(GrpIdx==2 & exp_idx==2);

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';

figure('Position',[0, 100, 800, 500],'Color','w'); 
subplot(1,2,1); hold on
plot(1:2, [change_after_hit(GrpIdx==1 & exp_idx==1,:), change_after_miss(GrpIdx==1 & exp_idx==1,:)],'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, [change_after_hit(GrpIdx==2 & exp_idx==1,:), change_after_miss(GrpIdx==2 & exp_idx==1,:)],'Color',te_color, 'LineWidth',0.5);
plot(1:2, [mean(change_after_hit(GrpIdx==1 & exp_idx==1,:)), mean(change_after_miss(GrpIdx==1 & exp_idx==1,:))],'Color',rpe_color, 'LineWidth',4);
plot(1:2, [mean(change_after_hit(GrpIdx==2 & exp_idx==1,:)), mean(change_after_miss(GrpIdx==2 & exp_idx==1,:))],'Color',te_color, 'LineWidth',4);
xlim([0.75, 2.25]); ylim([0 10]);
title('Experiment 1', 'FontSize',25,'FontName','Ariel');
ylabel('abs change in %LSL','FontSize',20,'FontName','Ariel');
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Post Hit','Post Miss'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 


subplot(1,2,2); hold on
plot(1:2, [change_after_hit(GrpIdx==1 & exp_idx==2,:), change_after_miss(GrpIdx==1 & exp_idx==2,:)],'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, [change_after_hit(GrpIdx==2 & exp_idx==2,:), change_after_miss(GrpIdx==2 & exp_idx==2,:)],'Color',te_color, 'LineWidth',0.5);
plot(1:2, [mean(change_after_hit(GrpIdx==1 & exp_idx==2,:)), mean(change_after_miss(GrpIdx==1 & exp_idx==2,:))],'Color',rpe_color, 'LineWidth',4);
plot(1:2, [mean(change_after_hit(GrpIdx==2 & exp_idx==2,:)), mean(change_after_miss(GrpIdx==2 & exp_idx==2,:))],'Color',te_color, 'LineWidth',4);
xlim([0.75, 2.25]); ylim([0 10]);
title('Experiment 2', 'FontSize',25,'FontName','Ariel');
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Post Hit','Post Miss'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
sgtitle({'Win-stay / lose-shift'},'FontSize',25,'FontName','Ariel');


% figure('Position',[0, 100, 1500, 1000],'Color','w'); 
% for i = 1:3
%     
%     subplot(2,3,i); hold on
%     plot(1:2, [delta_hit(rpe1_idx,i), delta_miss(rpe1_idx,i)],'Color',rpe_color, 'LineWidth',0.5);
%     plot(1:2, [delta_hit(te1_idx,i), delta_miss(te1_idx,i)],'Color',te_color, 'LineWidth',0.5);
%     plot(1:2, [mean(delta_hit(rpe1_idx,i)), mean(delta_miss(rpe1_idx,i))],'Color',rpe_color, 'LineWidth',4);
%     plot(1:2, [mean(delta_hit(te1_idx,i)), mean(delta_miss(te1_idx,i))],'Color',te_color, 'LineWidth',4);
%     xlim([0.75, 2.25]); ylim([0 10]);
%     title({'Win-stay / lose-shift'; ['(' num2str(i) ' trials back)']},'FontSize',25,'FontName','Ariel');
%     if i==1
%         ylabel('|Delta %LSL| (Experiment 1)','FontSize',20,'FontName','Ariel');
%     end
%     set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Post Hit','Post Miss'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
% 
% end
% for i = 1:3
%     
%     subplot(2,3,3+i); hold on
%     plot(1:2, [delta_hit(rpe2_idx,i), delta_miss(rpe2_idx,i)],'Color',rpe_color, 'LineWidth',0.5);
%     plot(1:2, [delta_hit(te2_idx,i), delta_miss(te2_idx,i)],'Color',te_color, 'LineWidth',0.5);
%     plot(1:2, [mean(delta_hit(rpe2_idx,i)), mean(delta_miss(rpe2_idx,i))],'Color',rpe_color, 'LineWidth',4);
%     plot(1:2, [mean(delta_hit(te2_idx,i)), mean(delta_miss(te2_idx,i))],'Color',te_color, 'LineWidth',4);
%     xlim([0.75, 2.25]); ylim([0 10]);
%     title({'Win-stay / lose-shift'; ['(' num2str(i) ' trials back)']},'FontSize',25,'FontName','Ariel');
%     if i==1
%         ylabel('|Delta %LSL| (Experiment 2)','FontSize',20,'FontName','Ariel');
%     end
%     set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Post Hit','Post Miss'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
% 
% end

% subplot(2,5,1:3); hold on
% errorbar([1:size(trial_history_idx,1)]-0.1, nanmean(trial_history(rpe1_idx,:)), SEM(trial_history(rpe1_idx,:),1), 'Color', rpe_color, 'MarkerFaceColor', rpe_color, 'LineWidth', 2, 'LineStyle','none', 'Marker','o', 'CapSize',cap_size_eb);
% % s1 = scatter([1:size(trial_history_idx,1)]-0.2, trial_history(rpe1_idx,:), 'o', 'MarkerFaceColor', rpe_color, 'MarkerEdgeColor','w','SizeData',25);
% errorbar([1:size(trial_history_idx,1)]+0.1, nanmean(trial_history(te1_idx,:)), SEM(trial_history(te1_idx,:),1), 'Color', te_color, 'MarkerFaceColor', te_color, 'LineWidth', 2, 'LineStyle','none', 'Marker','o', 'CapSize',cap_size_eb);
% % s2 = scatter([1:size(trial_history_idx,1)]+0.2, trial_history(te1_idx,:), 'o', 'MarkerFaceColor', te_color, 'MarkerEdgeColor','w','SizeData',25);
% % alpha(s1,.5); alpha(s2,.5); 
% set(gca,'FontSize',18, 'FontName','Arial', 'XTick', 0:8, 'XTickLabel', []); 
% text(1,10, 'RPE', 'FontSize',20,'FontWeight','bold', 'FontName','Ariel', 'Color',rpe_color);
% text(1,9, 'TE', 'FontSize',20,'FontWeight','bold', 'FontName','Ariel', 'Color',te_color);
% title('Impact of reward history - Experiment 1'); 
% ylabel('abs change in %LSL'); 

% %Plot trial history 
% figure('Position',[0, 100, 700, 900],'Color','w'); 
% subplot(2,1,1); hold on
% for p = 1:size(betas,1)
% 
%     bar(p-0.15, mean(betas(p,rpe1_idx)),0.3,'FaceColor','none', 'EdgeColor',rpe_color, 'LineWidth',3);
%     errorbar(p-0.15, mean(betas(p,rpe1_idx)), SEM(betas(p,rpe1_idx),2), 'color', rpe_color, 'LineWidth', 3, 'CapSize',cap_size_eb);
%     s1 = scatter(normrnd(p-0.25, 0.02, length(rpe1_idx),1), betas(p,rpe1_idx), 'MarkerFaceColor', rpe_color, 'MarkerEdgeColor', 'w', 'SizeData', dot_size);
%     
%     bar(p+0.15, mean(betas(p,te1_idx)),0.3,'FaceColor','none', 'EdgeColor',te_color, 'LineWidth',3);
%     errorbar(p+0.15, mean(betas(p,te1_idx)), SEM(betas(p,te1_idx),2), 'color', te_color, 'LineWidth', 3, 'CapSize',cap_size_eb);
%     s2 = scatter(normrnd(p+0.25, 0.02, length(te1_idx),1), betas(p,te1_idx), 'MarkerFaceColor', te_color, 'MarkerEdgeColor', 'w', 'SizeData', dot_size);
%     alpha(s1,.5); alpha(s2,.5); 
% 
% end
% set(gca,'FontSize',18, 'FontName','Arial', 'XTick', 1:4, 'XTickLabel', {'Intercept', 'Current trial', '1 trial past', '2 trials past'}, 'XTickLabelRotation', 0, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
% title('Experiment 1'); 
% ylabel('Sensitivity to RPE'); 
% 
% subplot(2,1,2); hold on
% for p = 1:size(betas,1)
% 
%     bar(p-0.15, mean(betas(p,rpe2_idx)),0.3,'FaceColor','none', 'EdgeColor',rpe_color, 'LineWidth',3);
%     errorbar(p-0.15, mean(betas(p,rpe2_idx)), SEM(betas(p,rpe2_idx),2), 'color', rpe_color, 'LineWidth', 3, 'CapSize',cap_size_eb);
%     s1 = scatter(normrnd(p-0.25, 0.02, length(rpe2_idx),1), betas(p,rpe2_idx), 'MarkerFaceColor', rpe_color, 'MarkerEdgeColor', 'w', 'SizeData', dot_size);
%     
%     bar(p+0.15, mean(betas(p,te2_idx)),0.3,'FaceColor','none', 'EdgeColor',te_color, 'LineWidth',3);
%     errorbar(p+0.15, mean(betas(p,te2_idx)), SEM(betas(p,te2_idx),2), 'color', te_color, 'LineWidth', 3, 'CapSize',cap_size_eb);
%     s2 = scatter(normrnd(p+0.25, 0.02, length(te2_idx),1), betas(p,te2_idx), 'MarkerFaceColor', te_color, 'MarkerEdgeColor', 'w', 'SizeData', dot_size);
%     alpha(s1,.5); alpha(s2,.5); 
% 
% end
% set(gca,'FontSize',18, 'FontName','Arial', 'XTick', 1:4, 'XTickLabel', {'Intercept', 'Current trial', '1 trial past', '2 trials past'}, 'XTickLabelRotation', 0, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
% title('Experiment 2'); 
% ylabel('Sensitivity to RPE'); 

% figure('Position',[0, 100, 700, 400],'Color','w'); 
% subplot(1,2,1); hold on
% line([0.75, 1.25],[mean(explore_ttc(rpe1_idx)), mean(explore_ttc(rpe1_idx))],'LineWidth',4,'Color',rpe_color);
% line([1.75, 2.25],[mean(explore_ttc(te1_idx)), mean(explore_ttc(te1_idx))],'LineWidth',4,'Color',te_color);
% s1 = scatter(normrnd(0.9, 0.01, length(rpe1_idx),1), explore_ttc(rpe1_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% s2 = scatter(normrnd(1.9, 0.01, length(te1_idx),1), explore_ttc(te1_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% errorbar(1, mean(explore_ttc(rpe1_idx)), SEM(explore_ttc(rpe1_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize', cap_size_eb)
% errorbar(2, mean(explore_ttc(te1_idx)), SEM(explore_ttc(te1_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
% alpha(s1,.5); alpha(s2,.5); 
% xlim([0.5, 2.5]); ylim([0 30]);
% ylabel('Trial to trial change','FontSize',20,'FontName','Ariel'); 
% title('Experiment 1','FontSize',25,'FontName','Ariel');
% set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
% 
% subplot(1,2,2); hold on
% line([0.75, 1.25],[mean(explore_ttc(rpe2_idx)), mean(explore_ttc(rpe2_idx))],'LineWidth',4,'Color',rpe_color);
% line([1.75, 2.25],[mean(explore_ttc(te2_idx)), mean(explore_ttc(te2_idx))],'LineWidth',4,'Color',te_color);
% s1 = scatter(normrnd(0.9, 0.01, length(rpe2_idx),1), explore_ttc(rpe2_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% s2 = scatter(normrnd(1.9, 0.01, length(te2_idx),1), explore_ttc(te2_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% errorbar(1, mean(explore_ttc(rpe2_idx)), SEM(explore_ttc(rpe2_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize', cap_size_eb)
% errorbar(2, mean(explore_ttc(te2_idx)), SEM(explore_ttc(te2_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
% alpha(s1,.5); alpha(s2,.5); 
% xlim([0.5, 2.5]); ylim([0 30]);
% title('Experiment 2','FontSize',25,'FontName','Ariel');
% set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
% 



% subplot(2,3,4:5); hold on
% errorbar([1:size(trial_history_idx,1)]-0.1, nanmean(trial_history(rpe2_idx,:)), SEM(trial_history(rpe2_idx,:),1), 'Color', rpe_color, 'MarkerFaceColor', rpe_color, 'LineWidth', 2, 'LineStyle','none', 'Marker','o', 'CapSize',cap_size_eb);
% % s1 = scatter([1:size(trial_history_idx,1)]-0.2, trial_history(rpe2_idx,:), 'o', 'MarkerFaceColor', rpe_color, 'MarkerEdgeColor','w');
% errorbar([1:size(trial_history_idx,1)]+0.1, nanmean(trial_history(te2_idx,:)), SEM(trial_history(te2_idx,:),1), 'Color', te_color, 'MarkerFaceColor', te_color, 'LineWidth', 2, 'LineStyle','none', 'Marker','o', 'CapSize',cap_size_eb);
% % s2 = scatter([1:size(trial_history_idx,1)]+0.2, trial_history(te2_idx,:), 'o', 'MarkerFaceColor', te_color, 'MarkerEdgeColor','w');
% alpha(s1,.5); alpha(s2,.5); 
% row1 = {'R(n-2)','1','0','1','0','1','0','1','0'};
% row2 = {'R(n-1)', '1','1','0','0','1','1','0','0'};
% row3 = {'R(n)', '1','1','1','1','0','0','0','0'};
% labelArray = [row1; row2; row3]; 
% tickLabels = strtrim(sprintf('%s\\newline%s\\newline%s\n', labelArray{:}));
% set(gca,'FontSize',18, 'FontName','Arial', 'XTick', 0:8, 'XTickLabel', tickLabels); 
% title('Impact of reward history - Experiment 2'); 
% ylabel('abs change in %LSL'); xlabel('Reward History');


% figure('Position',[0, 100, 700, 700],'Color','w'); 
% subplot(2,2,1); hold on
% line([0.75, 1.25],[mean(explore_ttc(rpe1_idx)), mean(explore_ttc(rpe1_idx))],'LineWidth',4,'Color',rpe_color);
% line([1.75, 2.25],[mean(explore_ttc(te1_idx)), mean(explore_ttc(te1_idx))],'LineWidth',4,'Color',te_color);
% s1 = scatter(normrnd(0.9, 0.01, length(rpe1_idx),1), explore_ttc(rpe1_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% s2 = scatter(normrnd(1.9, 0.01, length(te1_idx),1), explore_ttc(te1_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% errorbar(1, mean(explore_ttc(rpe1_idx)), SEM(explore_ttc(rpe1_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize', cap_size_eb)
% errorbar(2, mean(explore_ttc(te1_idx)), SEM(explore_ttc(te1_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
% alpha(s1,.5); alpha(s2,.5); 
% xlim([0.5, 2.5]); ylim([0 30]);
% ylabel('Exploration TTC','FontSize',20,'FontName','Ariel'); 
% title('Exploration TTC - E1','FontSize',25,'FontName','Ariel');
% set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
% 
% subplot(2,2,2); hold on
% line([0.75, 1.25],[mean(explore_ttc(rpe2_idx)), mean(explore_ttc(rpe2_idx))],'LineWidth',4,'Color',rpe_color);
% line([1.75, 2.25],[mean(explore_ttc(te2_idx)), mean(explore_ttc(te2_idx))],'LineWidth',4,'Color',te_color);
% s1 = scatter(normrnd(0.9, 0.01, length(rpe2_idx),1), explore_ttc(rpe2_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% s2 = scatter(normrnd(1.9, 0.01, length(te2_idx),1), explore_ttc(te2_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% errorbar(1, mean(explore_ttc(rpe2_idx)), SEM(explore_ttc(rpe2_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize', cap_size_eb)
% errorbar(2, mean(explore_ttc(te2_idx)), SEM(explore_ttc(te2_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
% alpha(s1,.5); alpha(s2,.5); 
% xlim([0.5, 2.5]); ylim([0 30]);
% ylabel('Exploration TTC','FontSize',20,'FontName','Ariel'); 
% title('Exploration TTC - E2','FontSize',25,'FontName','Ariel');
% set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
% 
% subplot(2,2,3); hold on
% line([0.75, 1.25],[mean(explore_attc(rpe1_idx)), mean(explore_attc(rpe1_idx))],'LineWidth',4,'Color',rpe_color);
% line([1.75, 2.25],[mean(explore_attc(te1_idx)), mean(explore_attc(te1_idx))],'LineWidth',4,'Color',te_color);
% s1 = scatter(normrnd(0.9, 0.01, length(rpe1_idx),1), explore_attc(rpe1_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% s2 = scatter(normrnd(1.9, 0.01, length(te1_idx),1), explore_attc(te1_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% errorbar(1, mean(explore_attc(rpe1_idx)), SEM(explore_attc(rpe1_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize', cap_size_eb)
% errorbar(2, mean(explore_attc(te1_idx)), SEM(explore_attc(te1_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
% alpha(s1,.5); alpha(s2,.5); 
% xlim([0.5, 2.5]); ylim([-2 10]);
% ylabel('Exploration ATTC','FontSize',20,'FontName','Ariel'); 
% title('Exploration ATTC','FontSize',25,'FontName','Ariel');
% set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
% 
% subplot(2,2,4); hold on
% line([0.75, 1.25],[nanmean(explore_attc(rpe2_idx)), nanmean(explore_attc(rpe2_idx))],'LineWidth',4,'Color',rpe_color);
% line([1.75, 2.25],[nanmean(explore_attc(te2_idx)), nanmean(explore_attc(te2_idx))],'LineWidth',4,'Color',te_color);
% s1 = scatter(normrnd(0.9, 0.01, length(rpe2_idx),1), explore_attc(rpe2_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% s2 = scatter(normrnd(1.9, 0.01, length(te2_idx),1), explore_attc(te2_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
% errorbar(1, nanmean(explore_attc(rpe2_idx)), SEM(explore_attc(rpe2_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize', cap_size_eb)
% errorbar(2, nanmean(explore_attc(te2_idx)), SEM(explore_attc(te2_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
% alpha(s1,.5); alpha(s2,.5); 
% xlim([0.5, 2.5]); ylim([-2 10]);
% ylabel('Exploration ATTC','FontSize',20,'FontName','Ariel'); 
% title('Exploration ATTC - E2','FontSize',25,'FontName','Ariel');
% set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);

anova_T = table;
anova_T.wsls = [change_after_hit; change_after_miss];
anova_T.bsl_var = [bsl_var; nan(length(bsl_var),1)];
anova_T.subj_id = [subjs; subjs];
for i = 1:height(GrpIdx)
    time1{i,1} = 'post_hit';
    time2{i,1} = 'post_miss';
    if GrpIdx(i) == 1
        group{i,1} = 'RPE';
    else
        group{i,1} = 'TE';
    end
end
anova_T.group = [group; group];
anova_T.time = [time1; time2];
anova_T.experiment = [exp_idx; exp_idx];

% trl_hist_regress_T = table;
% trl_hist_regress_T.betas = [betas(1,:)'; betas(2,:)'; betas(3,:)'; betas(4,:)']; 
% for i = 1:length(subjs)
%     int_str{i,1} = 'Intercept';
%     R_current{i,1} = 'Current';
%     R_1past{i,1} = 'One_Past';
%     R_2past{i,1} = 'Two_Past';
% end
% trl_hist_regress_T.R_hist = [int_str; R_current; R_1past; R_2past];
% trl_hist_regress_T.subj_id = [subjs; subjs; subjs; subjs];
% trl_hist_regress_T.group = [group; group; group; group];
% trl_hist_regress_T.exp = [exp_idx; exp_idx; exp_idx; exp_idx];
% 
% trl_hist_anova_T = table;
% trl_hist_anova_T.subj_id = [subjs; subjs; subjs; subjs; subjs; subjs; subjs; subjs];
% trl_hist_anova_T.exp = [exp_idx; exp_idx; exp_idx; exp_idx; exp_idx; exp_idx; exp_idx; exp_idx];
% trl_hist_anova_T.group = [group; group; group; group; group; group; group; group];
% trl_hist_anova_T.abs_deltU = trial_history_anova;


end