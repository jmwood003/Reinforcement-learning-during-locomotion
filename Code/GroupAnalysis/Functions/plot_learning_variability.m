function anova_T = plot_learning_variability(T, BinSize, fig_dir)

%Find subjects
subjs = unique(T.SID);

%pre-allocate
binned_variability = nan(length(subjs),ceil(900/BinSize));
%Loop through subject
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

    %Calculcate baseline variability
    bslidx = find(strcmp(subjs{s},T.SID)==1 & strcmp('baseline',T.phase)==1);
    bsl_LSL = T.prctLSL(bslidx);
    bsl_LSL(isnan(bsl_LSL)==1) = [];

    bsl_var = std(bsl_LSL(end-49:end));

    %Caluclate baseline trial to trial change
    bsl_t2t_change = bsl_LSL(1:end-1) - bsl_LSL(2:end);
    bsl_exp = std(bsl_t2t_change(end-49:end));

    %Index learning phases
    lrn_idx = find(strcmp(subjs{s},T.SID)==1 & strcmp('learning',T.phase)==1);

    %Index variables
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
    binned_variability(s,1:length(binned_sd)) = binned_sd/bsl_var;

    %Seperate out early and late variability
    maxPerturbIdx = find(target==10);
    ErlyLrnidx = maxPerturbIdx(1:50);
    var_epochs(s,1:2) = [std(lrn_lsl(ErlyLrnidx))/bsl_var, std(lrn_lsl(end-49:end))/bsl_var];    

    %Win/stay lose shift behavior
    start_lrn = find(target==1);
    padded_lsl = [lrn_lsl(start_lrn(1):end); nan];

    %index hits and missed
    hit_idx = find(success(start_lrn(1):end)==1);
    miss_idx = find(success(start_lrn(1):end)==0);

    %calculcate trial to trial change
    hit_t2t_change = padded_lsl(hit_idx+1) - padded_lsl(hit_idx);
    miss_t2t_change = padded_lsl(miss_idx+1) - padded_lsl(miss_idx);

    %calculcate variability after hits and misses
    hit_exp(s,1) = nanstd(hit_t2t_change)/bsl_exp;
    miss_exp(s,1) = nanstd(miss_t2t_change)/bsl_exp;

end

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';

%Index when the target is moving
StartMoving = (50/BinSize)+1;
MovingLen = (100/BinSize)-1;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Experiment 1
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%Plot variability bins
figure('Position',[0, 100, 900, 800],'Color','w'); 
axes('Position', [0.1, 0.55, 0.8, 0.4]); hold on
rectangle('Position',[StartMoving-0.25,0,MovingLen+0.5,10],'FaceColor','none','EdgeColor','k','LineStyle','--','LineWidth',2);
s1 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==1 & exp_idx==1,:),1),SEM(binned_variability(GrpIdx==1 & exp_idx==1,:),1),'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==2 & exp_idx==1,:),1),SEM(binned_variability(GrpIdx==2 & exp_idx==1,:),1),'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none')
ylim([0 10]); xlim([1 size(binned_variability,2)]);
text(16, 9, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
text(16, 8.2, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
text(StartMoving+0.5,9,{'Gadual'; 'Target'; 'Shift'},'FontSize',16, 'FontName','Arial','Color','k','Rotation',0,'HorizontalAlignment','center','VerticalAlignment','middle');
set(gca,'FontSize',18, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title('Exploration','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
ylabel('\sigma_{\DeltaLSL}','FontSize',25,'FontName','Ariel'); 
xlabel(['Strides (bins of ' num2str(BinSize) ')'],'FontSize',20,'FontName','Ariel');

%Plot epochs
axes('Position', [0.15, 0.1, 0.25, 0.3]); hold on
plot(1:2, var_epochs(GrpIdx==1 & exp_idx==1,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, var_epochs(GrpIdx==2 & exp_idx==1,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(var_epochs(GrpIdx==1 & exp_idx==1,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(var_epochs(GrpIdx==2 & exp_idx==1,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 15]);
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('\sigma_{\DeltaLSL}','FontSize',25,'FontName','Ariel'); 
title({'Early vs Late'; 'Exploration'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');

%Plot exploration
axes('Position', [0.6, 0.1, 0.25, 0.3]); hold on
plot(1:2,[hit_exp(GrpIdx==1 & exp_idx==1), miss_exp(GrpIdx==1 & exp_idx==1)],'color',rpe_color, 'LineWidth', 0.5);
plot(1:2,[hit_exp(GrpIdx==2 & exp_idx==1), miss_exp(GrpIdx==2 & exp_idx==1)],'color',te_color, 'LineWidth', 0.5);
plot(1:2,[mean(hit_exp(GrpIdx==1 & exp_idx==1)), mean(miss_exp(GrpIdx==1 & exp_idx==1))],'LineWidth',4,'Color',rpe_color);
plot(1:2,[mean(hit_exp(GrpIdx==2 & exp_idx==1)), mean(miss_exp(GrpIdx==2 & exp_idx==1))],'LineWidth',4,'Color',te_color);
xlim([0.5, 2.5]); ylim([0, 8]);
tickLabels = {['    post\newline success'],['post\newline fail']};
set(gca,'FontSize',18, 'Xtick',1:2,'Xticklabels',tickLabels, 'XTickLabelRotation', 0, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title({'Win-Stay/'; 'Lose Shift'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
ylabel('\sigma_{trial-to-trial}','FontSize',25,'FontName','Ariel'); 

annotation('textbox',[0.02, 0.81, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.08, 0.27, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.53, 0.27, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);

% %save figure
% cd(fig_dir);
% print('Figure_4','-dtiff', '-r300');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Experiment 2
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%Plot variability bins
figure('Position',[0, 100, 900, 800],'Color','w'); 
axes('Position', [0.1, 0.55, 0.8, 0.4]); hold on
rectangle('Position',[StartMoving-0.25,0,MovingLen+0.5,10],'FaceColor','none','EdgeColor','k','LineStyle','--','LineWidth',2);
s1 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==1 & exp_idx==2,:),1),SEM(binned_variability(GrpIdx==1 & exp_idx==2,:),1),'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:size(binned_variability,2),nanmean(binned_variability(GrpIdx==2 & exp_idx==2,:),1),SEM(binned_variability(GrpIdx==2 & exp_idx==2,:),1),'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none')
ylim([0 10]); xlim([1 size(binned_variability,2)]);
text(16, 9, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
text(16, 8.2, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
text(StartMoving+0.5,9,{'Gadual'; 'Target'; 'Shift'},'FontSize',16, 'FontName','Arial','Color','k','Rotation',0,'HorizontalAlignment','center','VerticalAlignment','middle');
set(gca,'FontSize',18, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title('Exploration - Experiment 2','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
ylabel('\sigma_{\DeltaLSL}','FontSize',25,'FontName','Ariel'); 
xlabel(['Strides (bins of ' num2str(BinSize) ')'],'FontSize',20,'FontName','Ariel');

%Plot epochs
axes('Position', [0.15, 0.1, 0.25, 0.3]); hold on
plot(1:2, var_epochs(GrpIdx==1 & exp_idx==2,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, var_epochs(GrpIdx==2 & exp_idx==2,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(var_epochs(GrpIdx==1 & exp_idx==2,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(var_epochs(GrpIdx==2 & exp_idx==2,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 10]);
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('\sigma_{\DeltaLSL}','FontSize',25,'FontName','Ariel'); 
title({'Early vs Late'; 'Exploration'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');

%Plot exploration
axes('Position', [0.6, 0.1, 0.25, 0.3]); hold on
plot(1:2,[hit_exp(GrpIdx==1 & exp_idx==2), miss_exp(GrpIdx==1 & exp_idx==2)],'color',rpe_color, 'LineWidth', 0.5);
plot(1:2,[hit_exp(GrpIdx==2 & exp_idx==2), miss_exp(GrpIdx==2 & exp_idx==2)],'color',te_color, 'LineWidth', 0.5);
plot(1:2,[mean(hit_exp(GrpIdx==2 & exp_idx==2)), mean(miss_exp(GrpIdx==2 & exp_idx==2))],'LineWidth',4,'Color',te_color);
plot(1:2,[mean(hit_exp(GrpIdx==1 & exp_idx==2)), mean(miss_exp(GrpIdx==1 & exp_idx==2))],'LineWidth',4,'Color',rpe_color);
xlim([0.5, 2.5]); ylim([0, 8]);
set(gca,'FontSize',18, 'Xtick',1:2,'Xticklabels',tickLabels, 'XTickLabelRotation', 0, 'FontName', 'Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title({'Win-Stay/'; 'Lose Shift'},'FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
ylabel('\sigma_{trial-to-trial}','FontSize',25,'FontName','Ariel'); 

annotation('textbox',[0.02, 0.81, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.08, 0.27, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.53, 0.27, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);

% %save figure
% cd(fig_dir);
% print('Figure_S2','-dtiff', '-r300');

%Make tables 
anova_T = table;
anova_T.variability = [var_epochs(:,1); var_epochs(:,2)];
anova_T.wsls = [hit_exp; miss_exp];
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