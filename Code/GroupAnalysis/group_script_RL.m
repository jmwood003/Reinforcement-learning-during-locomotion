%% Reinforcement learning in locomotion script 
%Jonathan Wood 5/5/2023

close all; clear all; clc;

%Set directories and add paths
group_dir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Data';
doc_dir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Docs';
% fig_dir = '/Users/jonathanwood/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofDelaware-o365/Team-CHS-PT-Morton Lab - RL in Locomotion - Jonathan - RL in Locomotion - Jonathan/Docs/Writing/Manuscript/Figures';
fig_dir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Docs/Figures';
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Code/GroupAnalysis');
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Code/GroupAnalysis/Functions');
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Code/GroupAnalysis/Functions/helper_functions');
addpath('/Users/jonathanwood/Documents/GitHub/analysis_functions');

%Load data 
cd(doc_dir);
DT = readtable("Data_management.xlsx");

cd(group_dir);
load('E1data.mat');
load('E2data.mat');

%% Display demographics

clc;

%Total individuals consented
disp(['Total n = ' num2str(height(DT))]);
disp(['M = ', num2str(sum(contains(DT.Sex,'M'))), ', F = ', num2str(sum(contains(DT.Sex,'F')))]);

%Display number of replaced subjects
replaced_e1 = sum(contains(DT.Replacement,'Replaced')==1 & DT.Exp_Num==1);
replaced_e2 = sum(contains(DT.Replacement,'Replaced')==1 & DT.Exp_Num==2);
disp([num2str(replaced_e1) ' replaced in exp 1']);
disp([num2str(replaced_e2) ' replaced in exp 2']);

%remove subjects
removed_idx = contains(DT.Replacement,'Replaced');
DT(removed_idx,:) = [];

disp(' ');
disp(['Experiment 1 n = ' num2str(sum(DT.Exp_Num==1))]);
disp(['M = ', num2str(sum(contains(DT.Sex,'M')==1 & DT.Exp_Num==1)), ', F = ', num2str(sum(contains(DT.Sex,'F')==1 & DT.Exp_Num==1))]);
disp(['RPE = ' num2str(sum(contains(DT.SID,'Reward')==1 & DT.Exp_Num==1)), ', TE = ' num2str(sum(contains(DT.SID,'Visual')==1 & DT.Exp_Num==1))]);

disp(' ');
disp(['Experiment 2 n = ' num2str(sum(DT.Exp_Num==2))]);
disp(['M = ', num2str(sum(contains(DT.Sex,'M')==1 & DT.Exp_Num==2)), ', F = ', num2str(sum(contains(DT.Sex,'F')==1 & DT.Exp_Num==2))]);
disp(['RPE = ' num2str(sum(contains(DT.SID,'Reward')==1 & DT.Exp_Num==2)), ', TE = ' num2str(sum(contains(DT.SID,'Visual')==1 & DT.Exp_Num==2))]);

disp(' ');
disp(['Mean Treadmill Speed +/- SD = ' num2str(round(mean(DT.TM_Speed),2)) ' +/- ' num2str(round(std(DT.TM_Speed),2))]);

disp(' ');
disp('Experiment 1: ')
disp(['RPE F = ' num2str(sum(contains(DT.Sex,'F')==1 & DT.Exp_Num==1 & contains(DT.SID,'Reward')==1))...
    ', M = ' num2str(sum(contains(DT.Sex,'M')==1 & DT.Exp_Num==1 & contains(DT.SID,'Reward')==1))]);
disp(['TE F = ' num2str(sum(contains(DT.Sex,'F')==1 & DT.Exp_Num==1 & contains(DT.SID,'Visual')==1))...
    ', M = ' num2str(sum(contains(DT.Sex,'M')==1 & DT.Exp_Num==1 & contains(DT.SID,'Visual')==1))]);

disp(['RPE mean +/- SD age (years) = ' ...
      num2str(round(mean(DT.Age(DT.Exp_Num==1 & contains(DT.SID,'Reward')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.Age(DT.Exp_Num==1 & contains(DT.SID,'Reward')==1)),1))]);
disp(['TE mean +/- SD age (years) = ' ...
      num2str(round(mean(DT.Age(DT.Exp_Num==1 & contains(DT.SID,'Visual')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.Age(DT.Exp_Num==1 & contains(DT.SID,'Visual')==1)),1))]);

disp(['RPE mean +/- SD speed (m/s) = ' ...
      num2str(round(mean(DT.TM_Speed(DT.Exp_Num==1 & contains(DT.SID,'Reward')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.TM_Speed(DT.Exp_Num==1 & contains(DT.SID,'Reward')==1)),1))]);
disp(['TE mean +/- SD speed (m/s) = ' ...
      num2str(round(mean(DT.TM_Speed(DT.Exp_Num==1 & contains(DT.SID,'Visual')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.TM_Speed(DT.Exp_Num==1 & contains(DT.SID,'Visual')==1)),1))]);

disp(' ');
disp('Experiment 2: ')
disp(['RPE F = ' num2str(sum(contains(DT.Sex,'F')==1 & DT.Exp_Num==2 & contains(DT.SID,'Reward')==1))...
    ', M = ' num2str(sum(contains(DT.Sex,'M')==1 & DT.Exp_Num==2 & contains(DT.SID,'Reward')==1))]);
disp(['TE F = ' num2str(sum(contains(DT.Sex,'F')==1 & DT.Exp_Num==2 & contains(DT.SID,'Visual')==1))...
    ', M = ' num2str(sum(contains(DT.Sex,'M')==1 & DT.Exp_Num==2 & contains(DT.SID,'Visual')==1))]);

disp(['RPE mean +/- SD age (years) = ' ...
      num2str(round(mean(DT.Age(DT.Exp_Num==2 & contains(DT.SID,'Reward')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.Age(DT.Exp_Num==2 & contains(DT.SID,'Reward')==1)),1))]);
disp(['TE mean +/- SD age (years) = ' ...
      num2str(round(mean(DT.Age(DT.Exp_Num==2 & contains(DT.SID,'Visual')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.Age(DT.Exp_Num==2 & contains(DT.SID,'Visual')==1)),1))]);

disp(['RPE mean +/- SD speed (m/s) = ' ...
      num2str(round(mean(DT.TM_Speed(DT.Exp_Num==2 & contains(DT.SID,'Reward')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.TM_Speed(DT.Exp_Num==2 & contains(DT.SID,'Reward')==1)),1))]);
disp(['TE mean +/- SD speed (m/s) = ' ...
      num2str(round(mean(DT.TM_Speed(DT.Exp_Num==2 & contains(DT.SID,'Visual')==1)),1)) ' +/- ' ...
      num2str(round(std(DT.TM_Speed(DT.Exp_Num==2 & contains(DT.SID,'Visual')==1)),1))]);


%% Plot the experiment schedule - Figure 1

%Set colors
rpe_color = '#c51b7d';
te_color = '#276419';
phase_len_color = '#a6cee3';

%Index targets
T_up = ET1.TrgtHi_prct(strcmp(ET1.SID,'VisualFB_20')==1);
T_down = ET1.TrgtLo_prct(strcmp(ET1.SID,'VisualFB_20')==1);

%Plot 
schedule_fig = figure('Color', 'w', 'Position', [100, 500, 1500, 500]); 
axes('Position', [0.1, 0.15, 0.8, 0.7]); hold on
rectangle('Position',[0, -7, 250, 30],'EdgeColor','none','FaceColor',[0.9,0.9,0.9]);
rectangle('Position',[1150, -7, 900, 30],'EdgeColor','none','FaceColor',[0.9,0.9,0.9]);
plot(T_up,'k-','LineWidth',2);
plot(T_down,'k-','LineWidth',2);
plot(1:length(T_up),zeros(1,length(T_up)),'k', 'LineWidth', 2);
ylim([-7 20]); xlim([0 1600]); 
ylabel('\DeltaLSL (%)', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Ariel');
set(gca, 'XTick', [], 'XTickLabels', [], 'FontSize',18, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 

rectangle('Position',[5, -6.75, 240, 1.5],'EdgeColor','none','FaceColor',phase_len_color);
rectangle('Position',[255, -6.75, 40, 1.5],'EdgeColor','none','FaceColor',phase_len_color);
rectangle('Position',[305, -6.75, 80, 1.5],'EdgeColor','none','FaceColor',phase_len_color);
rectangle('Position',[395, -6.75, 750, 1.5],'EdgeColor','none','FaceColor',phase_len_color);
rectangle('Position',[1155, -6.75, 440, 1.5],'EdgeColor','none','FaceColor',phase_len_color);

%Phase text
text(250/2,21,'Baseline','FontSize',25, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([250 1150]),21,'Learning','FontSize',25, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1150 1600]),21,'Post-Learning','FontSize',25, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(250/2,-6,'250','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([250 300]),-6,'50','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([300 390]),-6,'90','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([390 1150]),-6,'760','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1150 1600]),-6,'E1: 900          E2: 25 (d1) 250 (d2)','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');

%other text
text(1000,10,'Target zone','FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1 1600]),-8,'Phase Length (Num. Strides)','FontSize',20, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1 1600]),23,'Experiment 1 and 2 schedule','FontSize',30, 'FontName','Arial', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%Instrunction text
text(250/2,17,{'"Walk'; 'Normally"'},'FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(300,18,'RPE: "Gain as much money as possible"','FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'left','Color',rpe_color);
text(300,16,'TE: "Hit the target"','FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'left','Color',te_color);
text(median([1150 1600]),16,{'E1: Washout'; '("Walk Normally")'},'FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1150 1600]),6,{'E2: Retention'; '("Walk like the end of'; 'reward/target phase")'},'FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');

%Save figure
cd(fig_dir);
print('Figure_1C','-depsc', '-vector');
cd(group_dir);

%% Individual learning data - Figure 2

%Plot 3 specific individuals 
subjs_to_plot = {'VisualFB_04','VisualFB_10','VisualFB_20',...
    'RewardFB_07','RewardFB_30','RewardFB_27'};

plot_individual_learning(ET1, subjs_to_plot);

max_sd_plot(ET1, 50);

%Save figure
cd(fig_dir);
print('Figure_2','-dtiff', '-r300');
cd(group_dir);

%% Group averaged data (e1) - Figure 3 

clc

%Plots group averaged exeriment 1 and learning data
anova_T = plot_e1_data(ET1);

%Save plot
cd(fig_dir);
print('Figure_3','-dtiff', '-r300');

%Save data for stats
cd(group_dir);
writetable(anova_T, 'E1_results_anova');

%% Learning Variability analysis - Figure 4

clc;

%Plots learning variability data
T = [ET1; ET2];
anova_T_var = plot_learning_variability(T, 50, fig_dir);

%Save table
cd(group_dir);
writetable(anova_T_var, 'variability_anova');

%% Group averaged data (e2) - Figures 5

clc

%Plots experiment 2 data
E2_ret_anova = plot_e2_data(ET2, fig_dir);

%Save table
cd(group_dir);
writetable(E2_ret_anova, 'E2_results_anova');

%% Matching variability (experiment 1 washout post-hoc analysis)

grp_str = {}; 
subjects = unique(ET1.SID);
for i = 1:length(subjects)

    %Record the group
    if contains(subjects{i},'Reward')==1
        grp_str = [grp_str; 'rpe'];
    else
        grp_str = [grp_str; 'te'];
    end

    %Index phases
    lrn_idx = find(strcmp(ET1.SID,subjects{i})==1 & strcmp(ET1.phase,'learning')==1);
    wsh_idx = find(strcmp(ET1.SID,subjects{i})==1 & strcmp(ET1.phase,'washout')==1);

    %index variability during learning
    lrn_steady_trgt_idx = find(ET1.Trgt_prct(lrn_idx)==10);
    variability(i,1) = nanstd(ET1.prctLSL(lrn_idx(lrn_steady_trgt_idx)));

    %index success during learning
    success = ET1.Success(lrn_idx(lrn_steady_trgt_idx));
    success(isnan(success)==1) = [];
    p_success(i,1) = (sum(success)/length(success))*100;

    %End of learning
    lrn_lsl = ET1.prctLSL(lrn_idx);
    lrn_lsl(isnan(lrn_lsl)==1) = [];
    end_lrn = mean(lrn_lsl(end-49:end));

    %Washout
    wsh_lsl = ET1.prctLSL(wsh_idx);
    wsh_lsl(isnan(wsh_lsl)==1) = [];

    %Washout epochs
    init_wsh(i,1) = (mean(wsh_lsl(1:5))/end_lrn)*100;
    early_wsh(i,1) = (mean(wsh_lsl(6:30))/end_lrn)*100;

end

%Plot prep
cap_size_eb = 5; dot_size = 50;

rpe_color = '#c51b7d';
te_color = '#276419';

%Seperate outcomes by group
rpe_var = variability(strcmp(grp_str,'rpe')==1);
te_var = variability(strcmp(grp_str,'te')==1);
rpe_success = p_success(strcmp(grp_str,'rpe')==1);
te_success = p_success(strcmp(grp_str,'te')==1);
rpe_iw = init_wsh(strcmp(grp_str,'rpe')==1);
te_iw = init_wsh(strcmp(grp_str,'te')==1);
rpe_ew = early_wsh(strcmp(grp_str,'rpe')==1);
te_ew = early_wsh(strcmp(grp_str,'te')==1);

%Match the particiapnts by variability
[var_match_rpe, var_match_te] = unique_matches(rpe_var, te_var);

%plot the matches
figure('Color', 'w'); hold on
plot([0.9 1.1], [rpe_var(var_match_rpe) te_var(var_match_te)], 'k');
plot(1-0.1,rpe_var,'o', 'MarkerEdgeColor','w', 'MarkerFaceColor',rpe_color, 'MarkerSize',8);
plot(1+0.1,te_var,'o', 'MarkerEdgeColor','w', 'MarkerFaceColor',te_color, 'MarkerSize',8);
xlim([0.85 1.15]); ylim([0 6]);
text(1, 5, 'Matched Values', 'FontSize', 15, 'HorizontalAlignment', 'center');
title('Matched Variability'); ylabel('Learning Variability'); 
set(gca, 'XTick', [0.9, 1.1], 'XTickLabels', {'RPE', 'TE'}, 'FontSize',18, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 

%Plot the washout
x_jitter_rpe = normrnd(0.75,0.01,length(var_match_rpe),1);
x_jitter_te = normrnd(1.15,0.01,length(var_match_te),1);

figure('Color', 'w'); hold on
plot(0:4,zeros(5,1),'k-','LineWidth',1);
line([0.65, 0.95],[mean(rpe_iw(var_match_rpe)), mean(rpe_iw(var_match_rpe))],'LineWidth',4,'Color',rpe_color);
line([1.05, 1.35],[mean(te_iw(var_match_te)), mean(te_iw(var_match_te))],'LineWidth',4,'Color',te_color);
errorbar(0.8, mean(rpe_iw(var_match_rpe)), SEM(rpe_iw(var_match_rpe),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(1.2, mean(te_iw(var_match_te)), SEM(te_iw(var_match_te),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
s1 = scatter(x_jitter_rpe, rpe_iw(var_match_rpe),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
s2 = scatter(x_jitter_te, te_iw(var_match_te),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
line([0.65, 0.95]+1,[mean(rpe_ew(var_match_rpe)), mean(rpe_ew(var_match_rpe))],'LineWidth',4,'Color',rpe_color);
line([1.05, 1.35]+1,[mean(te_ew(var_match_te)), mean(te_ew(var_match_te))],'LineWidth',4,'Color',te_color);
s3 = scatter(x_jitter_rpe+1, rpe_ew(var_match_rpe),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
s4 = scatter(x_jitter_te+1, te_ew(var_match_te),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
errorbar(1.8, mean(rpe_ew(var_match_rpe)), SEM(rpe_ew(var_match_rpe),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(2.2, mean(te_ew(var_match_te)), SEM(te_ew(var_match_te),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
alpha(s1,.5); alpha(s2,.5); alpha(s3,.5); alpha(s4,.5); 
xlim([0.5, 2.5]); %ylim([-100, 100]);
set(gca,'XTick',[1,2],'XTickLabel',{'Initial', 'Early'},'Box', 'off', 'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
ylabel('Percent retention','FontSize',20,'FontName','Ariel', 'FontWeight','normal');
title('Implicit Aftereffect - Matched','FontWeight','normal','FontSize',25,'FontName','Ariel', 'Color', 'k');

%Plot matched groups against reward
figure('Color', 'w'); hold on
plot(0:4,zeros(5,1),'k-','LineWidth',1);
line([0.65, 0.95],[mean(rpe_success(var_match_rpe)), mean(rpe_success(var_match_rpe))],'LineWidth',4,'Color',rpe_color);
line([1.05, 1.35],[mean(te_success(var_match_te)), mean(te_success(var_match_te))],'LineWidth',4,'Color',te_color);
errorbar(0.8, mean(rpe_success(var_match_rpe)), SEM(rpe_success(var_match_rpe),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(1.2, mean(te_success(var_match_te)), SEM(te_success(var_match_te),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
s1 = scatter(x_jitter_rpe, rpe_success(var_match_rpe),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
s2 = scatter(x_jitter_te, te_success(var_match_te),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
xlim([0.5, 1.5]); %ylim([-100, 100]);
title('Matched Groups'); ylabel('Learning Success'); 
set(gca, 'XTick', [0.9, 1.1], 'XTickLabels', {'RPE', 'TE'}, 'FontSize',18, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 

for i = 1:length(var_match_rpe)*2
    time1{i,1} = 'Initial';
    time2{i,1} = 'Early';
end

%Make table for comparison
var_match_T = table;
var_match_T.subj_id = [subjects(var_match_rpe); subjects(var_match_te); subjects(var_match_rpe); subjects(var_match_te)];
var_match_T.group = [grp_str(1:length(var_match_rpe)); grp_str(16:16+length(var_match_te)-1); grp_str(1:length(var_match_rpe)); grp_str(16:16+length(var_match_te)-1)];
var_match_T.time = [time1; time2];
var_match_T.washout = [rpe_iw(var_match_rpe); te_iw(var_match_te); rpe_ew(var_match_rpe); te_ew(var_match_te)];
var_match_T.variability = [rpe_var(var_match_rpe); te_var(var_match_te); rpe_var(var_match_rpe); te_var(var_match_te);];
var_match_T.success = [rpe_success(var_match_rpe); te_success(var_match_te); rpe_success(var_match_rpe); te_success(var_match_te);]; 

%Save table
cd(group_dir);
writetable(var_match_T, 'E1_var_match');

%% Does baseline variability predict early learning? 

%This code just runs the data extraction for variability and early learning
%the python code plots and runs the stats

T = [ET1; ET2];
subjects = unique(T.SID,'stable');
grp_str = {};  early_err = []; bsl_var = [];
for i = 1:length(subjects)

    %Record the group
    if contains(subjects{i},'Reward')==1
        grp_str = [grp_str; 'rpe'];
    else
        grp_str = [grp_str; 'te'];
    end

    %Indexing variable for experiment
    if contains(subjects{i},'ER')==1
        exp_idx(i,1) = 2;
    else
        exp_idx(i,1) = 1;
    end

    %Index phases
    bsl_idx = find(strcmp(T.SID,subjects{i})==1 & strcmp(T.phase,'baseline')==1);
    lrn_idx = find(strcmp(T.SID,subjects{i})==1 & strcmp(T.phase,'learning')==1);

    %Calculcate baseline standard deviation (a la Wu et al., 2014)
    bsl_lsl = T.prctLSL(bsl_idx); %percent LSL
    bsl_lsl(isnan(bsl_lsl)==1) = [];
    bsl_var(i,1) = std(bsl_lsl(end-159:end));

    %Calculcate baseline standard deviation of LSL
    bsl_lsl_raw = T.LSL(bsl_idx)*100; %Taking LSL in meters
    bsl_lsl_raw(isnan(bsl_lsl_raw)==1) = [];
    bsl_var_lsl(i,1) = std(bsl_lsl_raw(end-159:end));

    %Calculcate early learning as learning error once the target stops
    %moving
    lrn_lsl = T.prctLSL(lrn_idx);

    %Index the target
    target = T.Trgt_prct(lrn_idx);
    steady_trgt_idx = find(target==10);

    %Calculcate error
    lrn_err = abs(lrn_lsl(steady_trgt_idx) - target(steady_trgt_idx));
    early_err(i,1) = mean(lrn_err(1:50));

end

range(bsl_var_lsl)

%Make table
success_T = table;
success_T.subj_id = subjects;
success_T.group = grp_str;
success_T.experiment = exp_idx;
success_T.bsl_var = bsl_var;
success_T.early_err = early_err;
success_T.bsl_var_lsl = bsl_var_lsl;

%Save table
cd(group_dir);
writetable(success_T, 'bsl_var');

%% Success and aftereffect / retention

T = [ET1; ET2];
subjects = unique(T.SID,'stable');
grp_str = {}; washout = [];
ret5_error = []; ret24_error = [];
for i = 1:length(subjects)

    %Record the group
    if contains(subjects{i},'Reward')==1
        grp_str = [grp_str; 'rpe'];
    else
        grp_str = [grp_str; 'te'];
    end

    %Index phases
    lrn_idx = find(strcmp(T.SID,subjects{i})==1 & strcmp(T.phase,'learning')==1);
    wsh_idx = find(strcmp(T.SID,subjects{i})==1 & strcmp(T.phase,'washout')==1);
    ret5_idx = find(strcmp(T.SID,subjects{i})==1 & strcmp(T.phase,'Retention5min')==1);
    ret24_idx = find(strcmp(T.SID,subjects{i})==1 & strcmp(T.phase,'Retention24Hr')==1);

    %Index learning plateau
    LrnPC = T.prctLSL(lrn_idx);
    nan_idx = find(isnan(LrnPC)==1);
    LrnPC(nan_idx) = [];
    target = T.Trgt_prct(lrn_idx);
    target(nan_idx)= [];
    maxPerturbIdx = find(target==10);    
    end_learning = mean(LrnPC(end-49:end));

    %Success
    learning_success = T.Success(lrn_idx);
    learning_success(nan_idx)= [];
    success(i,1) = (sum(learning_success(maxPerturbIdx))/length(maxPerturbIdx))*100;

    %Indexing variable for experiment
    if contains(subjects{i},'ER')==1

        exp_idx(i,1) = 2;

        %Washout
        washout = [washout; nan];

        %Retention
        ret5_error = [ret5_error; abs(nanmean(T.prctLSL(ret5_idx)) - end_learning)];
        ret24_lsl = T.prctLSL(ret24_idx);
        ret24_lsl(isnan(ret24_lsl)==1) = [];
        ret24_error = [ret24_error; abs(nanmean(ret24_lsl(1:25) - end_learning))];
            
    else

        exp_idx(i,1) = 1;

        %Washout
        washout = [washout; (mean(T.prctLSL(wsh_idx(1:10))) / end_learning)*100];
        
        %Retention
        ret5_error = [ret5_error; nan];
        ret24_error = [ret24_error; nan];

    end

end

%Make table
success_T = table;
success_T.subj_id = subjects;
success_T.group = grp_str;
success_T.experiment = exp_idx;
success_T.success = success;
success_T.washout = washout;
success_T.ret5_error = ret5_error;
success_T.ret24_error = ret24_error;

%Save table
cd(group_dir);
writetable(success_T, 'success_T');

