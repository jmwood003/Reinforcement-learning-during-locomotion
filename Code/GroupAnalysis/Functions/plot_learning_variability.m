function anova_T = plot_learning_variability(T, BinSize, fig_dir, post_T, hdi_T)

subjs = unique(T.SID);

cap_size_eb = 5;

binned_variability = nan(length(subjs),ceil(900/BinSize));
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

    %-------------------------Baseline variability-------------------------
    %Calculcate baseline variability
    bslidx = find(strcmp(subjs{s},T.SID)==1 & strcmp('baseline',T.phase)==1);
    bsl_LSL = T.prctLSL(bslidx);
    bsl_LSL(isnan(bsl_LSL)==1) = [];

    bsl_t2t_change = bsl_LSL(1:end-1) - bsl_LSL(2:end);
    bsl_exp = std(bsl_t2t_change(end-49:end));

    bsl_iqr = iqr(bsl_LSL(end-49:end));
    
    %-----------------------Learning phase variability---------------------

    %Index phases
    lrn_idx = find(strcmp(subjs{s},T.SID)==1 & strcmp('learning',T.phase)==1);

    lrn_lsl = T.prctLSL(lrn_idx);
    target = T.Trgt_prct(lrn_idx);
    success = T.Success(lrn_idx);

    %Remove nans
    nan_idx = find(isnan(lrn_lsl)==1);
    lrn_lsl(nan_idx) = [];
    target(nan_idx) = [];
    success(nan_idx) = [];

    %Calculate variability bins
    binned_sd = Bin(lrn_lsl,BinSize,2,'std');
    binned_variability(s,1:length(binned_sd)) = binned_sd;

    %Seperate out early and late variability
    maxPerturbIdx = find(target==10);
    ErlyLrnidx = maxPerturbIdx(1:50);
    var_epochs(s,1:2) = [std(lrn_lsl(ErlyLrnidx)), std(lrn_lsl(end-49:end))];    

    %--------------------Win/stay lose shift behavior----------------------
    start_lrn = find(target==1);
    padded_lsl = [lrn_lsl(start_lrn(1):end); nan];

    hit_idx = find(success(start_lrn(1):end)==1);
    miss_idx = find(success(start_lrn(1):end)==0);

    hit_t2t_change = padded_lsl(hit_idx+1) - padded_lsl(hit_idx);
    miss_t2t_change = padded_lsl(miss_idx+1) - padded_lsl(miss_idx);

    hit_exp(s,1) = nanstd(hit_t2t_change)/bsl_exp;
    miss_exp(s,1) = nanstd(miss_t2t_change)/bsl_exp;

end

%Group indexing variables
rpe_idx = find(GrpIdx==1);
te_idx = find(GrpIdx==2);

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';

%Index when the target is moving
StartMoving = (50/BinSize)+1;
MovingLen = (100/BinSize)-1;

%Plot bins
%Experiment 1
figure('Position',[0, 100, 900, 800],'Color','w'); 
axes('Position', [0.1, 0.55, 0.8, 0.4]); hold on
rectangle('Position',[StartMoving-0.25,0,MovingLen+0.5,10],'FaceColor','none','EdgeColor','k','LineStyle','--','LineWidth',2);
s1 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==1 & exp_idx==1,:),1),SEM(binned_variability(GrpIdx==1 & exp_idx==1,:),1),'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==2 & exp_idx==1,:),1),SEM(binned_variability(GrpIdx==2 & exp_idx==1,:),1),'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none')
ylim([0 10]); xlim([1 size(binned_variability,2)]);
text(16, 9, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
text(16, 8.2, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
text(StartMoving+0.5,9,{'Target'; 'Moving'},'FontSize',16, 'FontName','Arial','Color','k','Rotation',0,'HorizontalAlignment','center','VerticalAlignment','middle');
set(gca,'FontSize',18, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title('Learning Variability','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
ylabel('%LSL change variability (SD)','FontSize',20,'FontName','Ariel'); 
xlabel(['Bin Num (Bin Size=' num2str(BinSize) ')'],'FontSize',20,'FontName','Ariel');

%Plot epochs
axes('Position', [0.15, 0.1, 0.25, 0.3]); hold on
plot(1:2, var_epochs(GrpIdx==1 & exp_idx==1,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, var_epochs(GrpIdx==2 & exp_idx==1,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(var_epochs(GrpIdx==1 & exp_idx==1,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(var_epochs(GrpIdx==2 & exp_idx==1,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 20]);
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('%LSL change variability (SD)','FontSize',18,'FontName','Ariel'); 
title({'Early vs Late'; 'Variability'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');

line([1, 2],[18, 18],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_variability_interact>0)/height(post_T))*100,1);
text(1.5, 19.5, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 18.5, ['[' num2str(round(hdi_T.e1_variability_interact(1),2)) ' ' num2str(round(hdi_T.e1_variability_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

y_loc = (mean(var_epochs(GrpIdx==1 & exp_idx==1,1)) + mean(var_epochs(GrpIdx==2 & exp_idx==1,1)))/2;
line([.9, .9],[mean(var_epochs(GrpIdx==2 & exp_idx==1,1)), mean(var_epochs(GrpIdx==1 & exp_idx==1,1))],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_variability_early>0)/height(post_T))*100,1);
text(0.7, y_loc, [num2str(difference_prob) '%'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', 90, 'VerticalAlignment','middle');
text(0.8, y_loc, ['[' num2str(round(hdi_T.e1_variability_early(1),2)) ' ' num2str(round(hdi_T.e1_variability_early(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', 90, 'VerticalAlignment','middle');

%Plot exploration
axes('Position', [0.6, 0.1, 0.25, 0.3]); hold on
plot(1:2,[mean(hit_exp(GrpIdx==1 & exp_idx==1)), mean(miss_exp(GrpIdx==1 & exp_idx==1))],'LineWidth',4,'Color',rpe_color);
plot(1:2,[hit_exp(GrpIdx==1 & exp_idx==1), miss_exp(GrpIdx==1 & exp_idx==1)],'color',rpe_color, 'LineWidth', 0.5);
plot(1:2,[mean(hit_exp(GrpIdx==2 & exp_idx==1)), mean(miss_exp(GrpIdx==2 & exp_idx==1))],'LineWidth',4,'Color',te_color);
plot(1:2,[hit_exp(GrpIdx==2 & exp_idx==1), miss_exp(GrpIdx==2 & exp_idx==1)],'color',te_color, 'LineWidth', 0.5);
xlim([0.5, 2.5]); ylim([0, 8]);
tickLabels = {['    post\newline success'],['post\newline fail']};
set(gca,'FontSize',18, 'Xtick',1:2,'Xticklabels',tickLabels, 'XTickLabelRotation', 0, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title({'Win-stay'; 'lose shift'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
ylabel({'trial-to-trial change'; 'variability (normalized)'},'FontSize',18,'FontName','Ariel'); 

line([1, 2],[7, 7],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_wsls_interact>0)/height(post_T))*100,1);
text(1.5, 7.7, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 7.2, ['[' num2str(round(hdi_T.e1_wsls_interact(1),2)) ' ' num2str(round(hdi_T.e1_wsls_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

y_loc = (mean(miss_exp(GrpIdx==1 & exp_idx==1,1)) + mean(miss_exp(GrpIdx==2 & exp_idx==1,1)))/2;
line([2.1, 2.1],[mean(miss_exp(GrpIdx==2 & exp_idx==1,1)), mean(miss_exp(GrpIdx==1 & exp_idx==1,1))],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_wsls_late>0)/height(post_T))*100,1);
text(2.3, y_loc, [num2str(difference_prob) '%'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', -90, 'VerticalAlignment','middle');
text(2.2, y_loc, ['[' num2str(round(hdi_T.e1_wsls_late(1),2)) ' ' num2str(round(hdi_T.e1_wsls_late(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', -90, 'VerticalAlignment','middle');

annotation('textbox',[0.02, 0.81, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.08, 0.27, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.53, 0.27, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);

cd(fig_dir);
print('Figure_4','-dtiff', '-r300');

%Experiment 2
figure('Position',[0, 100, 900, 800],'Color','w'); 
axes('Position', [0.1, 0.55, 0.8, 0.4]); hold on
rectangle('Position',[StartMoving-0.25,0,MovingLen+0.5,10],'FaceColor','none','EdgeColor','k','LineStyle','--','LineWidth',2);
s1 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==1 & exp_idx==2,:),1),SEM(binned_variability(GrpIdx==1 & exp_idx==2,:),1),'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==2 & exp_idx==2,:),1),SEM(binned_variability(GrpIdx==2 & exp_idx==2,:),1),'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none')
ylim([0 10]); xlim([1 size(binned_variability,2)]);
text(16, 9, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
text(16, 8.2, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
text(StartMoving+0.5,9,{'Target'; 'Moving'},'FontSize',16, 'FontName','Arial','Color','k','Rotation',0,'HorizontalAlignment','center','VerticalAlignment','middle');
set(gca,'FontSize',18, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title('Learning Variability - Experiment 2','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
ylabel('%LSL change variability (SD)','FontSize',20,'FontName','Ariel'); 
xlabel(['Bin Num (Bin Size=' num2str(BinSize) ')'],'FontSize',20,'FontName','Ariel');

%Plot epochs
axes('Position', [0.15, 0.1, 0.25, 0.3]); hold on
plot(1:2, var_epochs(GrpIdx==1 & exp_idx==2,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, var_epochs(GrpIdx==2 & exp_idx==2,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(var_epochs(GrpIdx==1 & exp_idx==2,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(var_epochs(GrpIdx==2 & exp_idx==2,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 10]);
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('%LSL change variability (SD)','FontSize',18,'FontName','Ariel'); 
title({'Early vs Late'; 'Variability'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');

line([1, 2],[9, 9],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_variability_interact>0)/height(post_T))*100,1);
text(1.5, 9.9, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 9.4, ['[' num2str(round(hdi_T.e2_variability_interact(1),2)) ' ' num2str(round(hdi_T.e2_variability_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

y_loc = (mean(var_epochs(GrpIdx==1 & exp_idx==2,1)) + mean(var_epochs(GrpIdx==2 & exp_idx==2,1)))/2;
line([.9, .9],[mean(var_epochs(GrpIdx==2 & exp_idx==2,1)), mean(var_epochs(GrpIdx==1 & exp_idx==2,1))],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_variability_early>0)/height(post_T))*100,1);
text(0.7, y_loc, [num2str(difference_prob) '%'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', 90, 'VerticalAlignment','middle');
text(0.8, y_loc, ['[' num2str(round(hdi_T.e2_variability_early(1),2)) ' ' num2str(round(hdi_T.e2_variability_early(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', 90, 'VerticalAlignment','middle');

%Plot exploration
axes('Position', [0.6, 0.1, 0.25, 0.3]); hold on
plot(1:2,[mean(hit_exp(GrpIdx==1 & exp_idx==2)), mean(miss_exp(GrpIdx==1 & exp_idx==2))],'LineWidth',4,'Color',rpe_color);
plot(1:2,[hit_exp(GrpIdx==1 & exp_idx==2), miss_exp(GrpIdx==1 & exp_idx==2)],'color',rpe_color, 'LineWidth', 0.5);
plot(1:2,[mean(hit_exp(GrpIdx==2 & exp_idx==2)), mean(miss_exp(GrpIdx==2 & exp_idx==2))],'LineWidth',4,'Color',te_color);
plot(1:2,[hit_exp(GrpIdx==2 & exp_idx==2), miss_exp(GrpIdx==2 & exp_idx==2)],'color',te_color, 'LineWidth', 0.5);
xlim([0.5, 2.5]); ylim([0, 8]);
set(gca,'FontSize',18, 'Xtick',1:2,'Xticklabels',tickLabels, 'XTickLabelRotation', 0, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title({'Win-stay'; 'lose shift'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
ylabel({'trial-to-trial change'; 'variability (normalized)'},'FontSize',18,'FontName','Ariel'); 

line([1, 2],[7, 7],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_wsls_interact>0)/height(post_T))*100,1);
text(1.5, 7.7, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 7.3, ['[' num2str(round(hdi_T.e2_wsls_interact(1),2)) ' ' num2str(round(hdi_T.e2_wsls_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

y_loc = (mean(miss_exp(GrpIdx==1 & exp_idx==2,1)) + mean(miss_exp(GrpIdx==2 & exp_idx==2,1)))/2;
line([2.1, 2.1],[mean(miss_exp(GrpIdx==2 & exp_idx==2,1)), mean(miss_exp(GrpIdx==1 & exp_idx==2,1))],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_wsls_late>0)/height(post_T))*100,1);
text(2.3, y_loc, [num2str(difference_prob) '%'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', -90, 'VerticalAlignment','middle');
text(2.2, y_loc, ['[' num2str(round(hdi_T.e2_wsls_late(1),2)) ' ' num2str(round(hdi_T.e2_wsls_late(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', -90, 'VerticalAlignment','middle');

annotation('textbox',[0.02, 0.81, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.08, 0.27, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.53, 0.27, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);

cd(fig_dir);
print('Figure_S2','-dtiff', '-r300');

%Make tables 
anova_T = table;
anova_T.variability = [var_epochs(:,1); var_epochs(:,2)];
anova_T.wsls = [hit_exp; miss_exp];
% anova_T.iqr = [lrn_iqr; lrn_iqr];
anova_T.subj_id = [subjs; subjs];
for i = 1:height(GrpIdx)
    time1{i,1} = 'Early';
    time2{i,1} = 'Late';
    exp1{i,1} = 'Post_Hit';
    exp2{i,1} = 'Post_Miss';
    if GrpIdx(i) == 1
        group{i,1} = 'RPE';
    else
        group{i,1} = 'TE';
    end
end
anova_T.group = [group; group];
anova_T.time = [time1; time2];
anova_T.exp_time = [exp1; exp2];
anova_T.experiment = [exp_idx; exp_idx];



end