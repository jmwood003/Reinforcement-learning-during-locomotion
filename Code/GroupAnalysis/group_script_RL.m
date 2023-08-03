%% Reinforcement learning in locomotion script 
%Jonathan Wood 5/5/2023

close all; clear all; clc;

%Set directories and add paths
group_dir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Data';
doc_dir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-during-locomotion/Docs';
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

%Index targets
T_up = ET1.TrgtHi_prct(strcmp(ET1.SID,'VisualFB_20')==1);
T_down = ET1.TrgtLo_prct(strcmp(ET1.SID,'VisualFB_20')==1);

%Plot 
schedule_fig = figure('Color', 'w', 'Position', [100, 500, 1500, 500]); 
axes('Position', [0.1, 0.15, 0.8, 0.7]); hold on
rectangle('Position',[0, -5, 250, 30],'EdgeColor','none','FaceColor',[0.9,0.9,0.9]);
rectangle('Position',[1150, -5, 900, 30],'EdgeColor','none','FaceColor',[0.9,0.9,0.9]);
plot(T_up,'k-','LineWidth',2);
plot(T_down,'k-','LineWidth',2);
plot(1:length(T_up),zeros(1,length(T_up)),'k', 'LineWidth', 2);
ylim([-5 20]); xlim([0 1600]); 
ylabel('\DeltaLSL (%)', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Ariel');
set(gca, 'XTick', [250, 300, 390, 1150, 1600], 'XTickLabels', {}, 'FontSize',18, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 

%Phase text
text(250/2,21,'Baseline','FontSize',25, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([250 1150]),21,'Learning','FontSize',25, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1150 1600]),21,'Post-Learning','FontSize',25, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(250/2,-6,'250','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([250 300]),-6,'50','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([300 390]),-6,'90','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([390 1150]),-6,'760','FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1150 1600]),-7,{'E1: 900'; 'E2: 750'},'FontSize',18, 'FontName','Arial', 'HorizontalAlignment', 'center');

%other text
text(1000,10,'Target zone','FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1 1600]),-8,'Num. Strides','FontSize',20, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1 1600]),23,'Experiment 1 and 2 schedule','FontSize',30, 'FontName','Arial', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%Instrunction text
text(250/2,17,{'"Walk'; 'Normally"'},'FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(300,18,'RPE: "Gain as much money as possible"','FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'left','Color',rpe_color);
text(300,16,'TE: "Hit the target"','FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'left','Color',te_color);
text(median([1150 1600]),16,{'E1: Washout'; '("Walk Normally")'},'FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');
text(median([1150 1600]),6,{'E2: Retention'; '("Walk like you did'; 'at the end of learning")'},'FontSize',22, 'FontName','Arial', 'HorizontalAlignment', 'center');

%Save figure
cd(fig_dir);
print('Figure_1C','-depsc', '-vector');
cd(group_dir);

%% Individual learning data - Figure 2

%Plot 3 specific individuals 
subjs_to_plot = {'VisualFB_04','VisualFB_10','VisualFB_20',...
    'RewardFB_07','RewardFB_30','RewardFB_27'};

plot_random_learning(ET1, subjs_to_plot);

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

clc

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

%% E2 exploratory analysis 

clc;

dot_size = 75;
rpe_color = '#c51b7d';
te_color = '#276419';

%remove subjects
removed_idx = contains(DT.Replacement,'Replaced')==1 | DT.Exp_Num==1;
DT(removed_idx,:) = [];

%index learning data and retention data
grp_str = {}; 
for i = 1:height(DT)

    %Record the group
    if contains(DT.SID{i},'Reward')==1
        grp_str = [grp_str; 'rpe'];
    else
        grp_str = [grp_str; 'te'];
    end
    time_ret1{i,1} = 'Immediate';
    time_ret2{i,1} = '24hr';

    %Index phases
    lrn_idx = find(strcmp(ET2.SID,DT.SID{i})==1 & strcmp(ET2.phase,'learning')==1);
    imm_idx = find(strcmp(ET2.SID,DT.SID{i})==1 & strcmp(ET2.phase,'Retention5min')==1);
    ret24_idx = find(strcmp(ET2.SID,DT.SID{i})==1 & strcmp(ET2.phase,'Retention24Hr')==1);

    %Index end of learning
    lrn_lsl = ET2.prctLSL(lrn_idx);
    lrn_lsl(isnan(lrn_lsl)==1) = [];
    end_lrn(i,1) = mean(lrn_lsl(end-49:end));

    %index immediate retetion
    imm_lsl = ET2.prctLSL(imm_idx);
    imm_lsl(isnan(imm_lsl)==1) = [];

    %index 24 hour retetion
    ret24_lsl = ET2.prctLSL(ret24_idx);
    ret24_lsl(isnan(ret24_lsl)==1) = [];

    imm_ret(i,1) = (mean(imm_lsl)/end_lrn(i,1))*100;
    ret24(i,1) = (mean(ret24_lsl(1:25))/end_lrn(i,1))*100; 

    ret_err5(i,1) = abs(mean(imm_lsl)-end_lrn(i,1));
    ret_err24(i,1) = abs(mean(ret24_lsl(1:25)) - end_lrn(i,1));

    %index success during learning
    lrn_steady_trgt_idx = find(ET2.Trgt_prct(lrn_idx)==10);
    success = ET2.Success(lrn_idx(lrn_steady_trgt_idx));
    success(isnan(success)==1) = [];

    lrn_success(i,1) = (sum(success) / length(success))*100;

end



%Make table
stat_T = table;
stat_T.SID = [DT.SID; DT.SID];
stat_T.group = [grp_str; grp_str];
stat_T.ret_prct = [imm_ret; ret24];
stat_T.ret_err = [ret_err5; ret_err24];
stat_T.time = [time_ret1; time_ret2];
% stat_T.late_lrn = [end_lrn; end_lrn];
% stat_T.success = [lrn_success; lrn_success];
stat_T.LSLperception = [DT.LSLperception; DT.LSLperception];
% stat_T.Focus = [DT.Focus; DT.Focus];

cd(group_dir);
writetable(stat_T, 'E2_sub_regress');

