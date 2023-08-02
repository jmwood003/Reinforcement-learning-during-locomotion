function results_T = plot_e2_learning_data(T, BinSize, longer_subjs, slightly_longer, no_change)

phases = unique(T.phase,'stable');
subjs = unique(T.SID);

cap_size_eb = 5;

%Calculate the shortest phase for all subjects to truncate
phaselength = []; 
for i = 1:length(subjs)
    for j = 1:length(phases)
        idx = find(strcmp(subjs{i},T.SID)==1 & strcmp(phases{j},T.phase)==1);
        LSL = T.prctLSL(idx);
        LSL(isnan(LSL)==1) = [];
        phaselength(i,j) = length(LSL);
    end
end
short_phase = nanmin(phaselength);
%Create indexing variable
idxphases = [ones(1,short_phase(1)), ones(1,short_phase(2))*2, ones(1,short_phase(3))*3,ones(1,short_phase(4))*4];

prctSL_change = []; Target = []; 
ret24_epochs = []; baseline_epochs = [];
for s = 1:length(subjs)
    
    %Make an indexing variable for the group
    if strcmp(subjs{s}(1),'V')==1
        GrpIdx(s,1) = 2;
    elseif strcmp(subjs{s}(1),'R')==1
        GrpIdx(s,1) = 1;
    end

    %Make indexing variable for awarness
    if ismember(subjs{s},longer_subjs)==1
        percept_idx(s,1) = 1;
    elseif ismember(subjs{s},slightly_longer)==1
        percept_idx(s,1) = 2;
    elseif ismember(subjs{s},no_change)==1
        percept_idx(s,1) = 3;
    end

    Temp_PrctSLchange = [];
    Temp_Trgt = [];
    for p = 1:length(phases)

        %Index the current phase
        fullidx = find(strcmp(subjs{s},T.SID)==1 & strcmp(phases{p},T.phase)==1);
        trunc_idx = fullidx(1:short_phase(p));
        
        %Percent SL Epochs
        %Learning
        if strcmp('learning',phases{p})==1
            %Percent LSL
            LrnPC = T.prctLSL(fullidx);
            LrnPC(isnan(LrnPC)==1) = [];
            EndLrn(s,1) = mean(LrnPC(end-49:end));

            %Error
            error_dir(s,1) = nanmean(T.prctLSL(fullidx) - T.Trgt_prct(fullidx));
            error = abs(T.prctLSL - T.Trgt_prct);

            learning_error = error(fullidx);
            learning_error(isnan(learning_error)==1) = [];
            mean_learn_err(s,1) = mean(learning_error);

            learning_error_bin = Bin(learning_error,BinSize,2,'mean');
            error_bins(s,1:length(learning_error_bin)) = learning_error_bin;
            
            %Percent success
            learning_success = T.Success(fullidx);
            total_hits_binned = Bin(learning_success,BinSize,2,'sum')./BinSize;
            success_bins(s,1:length(total_hits_binned)) = total_hits_binned*100;
            total_success(s,1) = (nansum(T.Success(fullidx) == 1) / length(fullidx))*100;
        
        elseif strcmp('baseline',phases{p})==1

            baseline = T.prctLSL(fullidx);
            baseline(isnan(baseline)==1) = [];

            baseline_epochs = [baseline_epochs; mean(baseline(1:50)), mean(baseline(end-49:end))];

        elseif strcmp('Retention5min',phases{p})==1
            
            ret_5_PC = T.prctLSL(fullidx);
            prct_ret5(s,1) = (nanmean(ret_5_PC)/EndLrn(s,1))*100;

        elseif strcmp('Retention24Hr',phases{p})==1

            ret_24_PC = T.prctLSL(fullidx);
            ret_24_PC(isnan(ret_24_PC)==1) = [];
            prct_ret24(s,1) = (mean(ret_24_PC(1:25))/EndLrn(s,1))*100;

            ret24_epochs = [ret24_epochs; mean(ret_24_PC(1:50)), mean(ret_24_PC(end-49:end))];

        end      
                 
        %Learning measures
        Temp_PrctSLchange = [Temp_PrctSLchange, T.prctLSL(trunc_idx)'];
                
        %Targets 
        Temp_Trgt = [Temp_Trgt, T.Trgt_prct(trunc_idx)'];
            
    end
    
    %Combine all phases
    prctSL_change = [prctSL_change; Temp_PrctSLchange];
    Target = [Target; Temp_Trgt];

end

%Group indexing variables
rpe_idx = find(GrpIdx==1);
te_idx = find(GrpIdx==2);

%Set colors for plotting
% C = lines(10);
% rpe_color = C(2,:);
% te_color = C(1,:);
rpe_color = '#c51b7d';
te_color = '#276419';
outline_c1 = '#1f78b4';
outline_c2 = '#ffff99';

%Index when the target is moving
StartMoving = (50/BinSize)+1;
MovingLen = (100/BinSize)-1;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Plot stride by stride data
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

figure('Position',[0,0,1500,1000]); 
subplot(2,4,1:4); hold on
rectangle('Position',[1, -40, short_phase(1), 80], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[sum(short_phase(1:2)), -40, sum(short_phase(3:4))+25, 80], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[sum(short_phase(1:3))+1, -40, 23, 80], 'FaceColor','k','EdgeColor','none');
shadedErrorBar(1:sum(short_phase(1:3)), nanmean(prctSL_change(rpe_idx,1:sum(short_phase(1:3)))), SEM(prctSL_change(rpe_idx,1:sum(short_phase(1:3))),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
shadedErrorBar(1:sum(short_phase(1:3)), nanmean(prctSL_change(te_idx,1:sum(short_phase(1:3)))), SEM(prctSL_change(te_idx,1:sum(short_phase(1:3))),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
plot(1:sum(short_phase(1:3)),mean(Target(:,1:sum(short_phase(1:3)))),'k--','linewidth',1.5);
shadedErrorBar(sum(short_phase(1:3))+25:length(idxphases)+24,nanmean(prctSL_change(rpe_idx,sum(short_phase(1:3))+1:end)),SEM(prctSL_change(rpe_idx,sum(short_phase(1:3))+1:end),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
shadedErrorBar(sum(short_phase(1:3))+25:length(idxphases)+24,nanmean(prctSL_change(te_idx,sum(short_phase(1:3))+1:end)),SEM(prctSL_change(te_idx,sum(short_phase(1:3))+1:end),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
plot(sum(short_phase(1:3))+25:length(idxphases)+24,mean(Target(:,sum(short_phase(1:3))+1:end)),'k--','linewidth',1.5);
plot(1:length(idxphases)+25,zeros(1,length(idxphases)+25),'k','linewidth',1.5);
text(median(find(idxphases==1)),23,'Baseline','FontName','Arial','FontSize',20, 'HorizontalAlignment','center'); 
text(median(find(idxphases==2)),23,'Learning','FontName','Arial','FontSize',20, 'HorizontalAlignment','center'); 
text(median(find(idxphases==4))+25,23,'Retention','FontName','Arial','FontSize',20, 'HorizontalAlignment','center'); 
text(sum(short_phase(1:3))+12, 15, '24-hour break', 'Rotation',90, 'FontSize', 15,'Color','w')
xlim([0 length(idxphases)+25]); ylim([-7 25]);
legend('RPE','TE','Target Center','Position',[0.3, 0.86, 0.1, 0.05]); legend('boxoff');
title('Experiment 2 data');
ylabel('%LSL change'); xlabel('Strides');
set(gca,'FontSize',18, 'FontName','Arial'); 

rectangle('Position',[sum(short_phase(1:2))-50, 5, 50, 10],'FaceColor','none','EdgeColor',outline_c1,'LineStyle','-','LineWidth',1);

%Plot learning inset
x_jitter_rpe = 0.95 + (1.05-0.95)*rand(length(rpe_idx),1);
x_jitter_te = 1.95 + (2.05-1.95)*rand(length(te_idx),1);

axes('Position',[0.6, 0.8, 0.1, 0.1],'Box','on','XColor',outline_c1,'YColor',outline_c1,'LineWidth',1); hold on
plot(0:3,ones(4,1)*10,'k--','LineWidth',1);
line([0.75, 1.25],[mean(EndLrn(rpe_idx)), mean(EndLrn(rpe_idx))],'LineWidth',4,'Color',rpe_color);
line([1.75, 2.25],[mean(EndLrn(te_idx)), mean(EndLrn(te_idx))],'LineWidth',4,'Color',te_color);
s1 = scatter(x_jitter_rpe, EndLrn(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w');
s2 = scatter(x_jitter_te, EndLrn(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w');
alpha(s1,.5); alpha(s2,.5); 
xlim([0.5, 2.5]); ylim([5, 15]);
title('End Learning','FontWeight','normal');
set(gca,'XTick',[],'FontName','Ariel','FontSize',16);

%Error --------------------------------------------------------------------
subplot(2,4,5:6); hold on
rectangle('Position',[StartMoving,-1,MovingLen,11],'FaceColor','none','EdgeColor','k','LineStyle','--','LineWidth',2);
shadedErrorBar(1:size(error_bins,2),mean(error_bins(rpe_idx,:),1),SEM(error_bins(rpe_idx,:),1),'lineProps',{'Color',rpe_color,'LineWidth',1.5});
shadedErrorBar(1:size(error_bins,2),mean(error_bins(te_idx,:),1),SEM(error_bins(te_idx,:),1),'lineProps',{'Color',te_color,'LineWidth',1.5});
plot(0:size(error_bins,2),zeros(1,size(error_bins,2)+1),'k','linewidth',1.5);
ylim([-1 10]); xlim([1 size(error_bins,2)]);
text(StartMoving+0.5,8,{'Target'; 'Moving'},'FontSize',16, 'FontName','Arial','Color','k','Rotation',90,'HorizontalAlignment','center','VerticalAlignment','middle');
title('Learning Error');
ylabel('Error (%LSL change)'); xlabel(['Bin Num (Bin Size=' num2str(BinSize) ')']);
set(gca,'FontSize',18, 'FontName','Arial'); 

%Plot inset for learning average
x_jitter_rpe = 0.95 + (1.05-0.95)*rand(length(rpe_idx),1);
x_jitter_te = 1.95 + (2.05-1.95)*rand(length(te_idx),1);

axes('Position',[0.38, 0.28, 0.09, 0.15],'Box','on','LineWidth',1); hold on
line([0.75, 1.25],[mean(mean_learn_err(rpe_idx)), mean(mean_learn_err(rpe_idx))],'LineWidth',4,'Color',rpe_color);
line([1.75, 2.25],[mean(mean_learn_err(te_idx)), mean(mean_learn_err(te_idx))],'LineWidth',4,'Color',te_color);
s1 = scatter(x_jitter_rpe, mean_learn_err(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w');
s2 = scatter(x_jitter_te, mean_learn_err(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w');
alpha(s1,.5); alpha(s2,.5); 
xlim([0.5, 2.5]); ylim([0 15]);
title('All learning','FontWeight','normal');
set(gca,'XTick',[],'FontName','Ariel','FontSize',16);

%Percent Success ----------------------------------------------------------
subplot(2,4,7:8); hold on
rectangle('Position',[StartMoving,0,MovingLen,100],'FaceColor','none','EdgeColor','k','LineStyle','--','LineWidth',2);
shadedErrorBar(1:size(success_bins,2),mean(success_bins(rpe_idx,:),1),SEM(success_bins(rpe_idx,:),1),'lineProps',{'Color',rpe_color,'LineWidth',1.5});
shadedErrorBar(1:size(success_bins,2),mean(success_bins(te_idx,:),1),SEM(success_bins(te_idx,:),1),'lineProps',{'Color',te_color,'LineWidth',1.5});
ylim([0 100]); xlim([1 size(success_bins,2)]);
title('Learning Success');
ylabel('Percent Success'); xlabel(['Bin Num (Bin Size=' num2str(BinSize) ')']);
set(gca,'FontSize',18, 'FontName','Arial'); 

%Inset for learning average
x_jitter_rpe = 0.95 + (1.05-0.95)*rand(length(rpe_idx),1);
x_jitter_te = 1.95 + (2.05-1.95)*rand(length(te_idx),1);

axes('Position',[0.8, 0.13, 0.09, 0.15],'Box','on','LineWidth',1); hold on
line([0.75, 1.25],[mean(total_success(rpe_idx)), mean(total_success(rpe_idx))],'LineWidth',4,'Color',rpe_color);
line([1.75, 2.25],[mean(total_success(te_idx)), mean(total_success(te_idx))],'LineWidth',4,'Color',te_color);
s1 = scatter(x_jitter_rpe, total_success(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w');
s2 = scatter(x_jitter_te, total_success(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w');
alpha(s1,.5); alpha(s2,.5); 
xlim([0.5, 2.5]); ylim([0 100]);
title('All Learning','FontWeight','normal');
set(gca,'XTick',[],'FontName','Ariel','FontSize',16);

%--------------------------------------------------------------------------
%run some regressions
%--------------------------------------------------------------------------

%Error
figure; subplot(1,2,1); hold on
scatter(error_dir(rpe_idx),prct_ret5(rpe_idx),'o','MarkerFaceColor',rpe_color,'MarkerEdgeColor','k','SizeData',100);
scatter(error_dir(te_idx),prct_ret5(te_idx),'o','MarkerFaceColor',te_color,'MarkerEdgeColor','k','SizeData',100);
[~, y_hat, ~] = simple_regression(error_dir,prct_ret5);
plot(error_dir,y_hat, 'k', 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(error_dir(rpe_idx),prct_ret5(rpe_idx));
plot(error_dir(rpe_idx),y_hat, 'Color',rpe_color , 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(error_dir(te_idx),prct_ret5(te_idx));
plot(error_dir(te_idx), y_hat, 'Color',te_color , 'LineWidth', 2);
xlabel('Average Error'); ylabel('Percent Retention')
title('5 minute retention');
axis square
set(gca, 'FontSize', 16, 'FontName','Ariel');

subplot(1,2,2); hold on
scatter(error_dir(rpe_idx),prct_ret24(rpe_idx),'o','MarkerFaceColor',rpe_color,'MarkerEdgeColor','k','SizeData',100);
scatter(error_dir(te_idx),prct_ret24(te_idx),'o','MarkerFaceColor',te_color,'MarkerEdgeColor','k','SizeData',100);
[~, y_hat, ~] = simple_regression(error_dir,prct_ret24);
plot(error_dir,y_hat, 'k', 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(error_dir(rpe_idx),prct_ret24(rpe_idx));
plot(error_dir(rpe_idx),y_hat, 'Color',rpe_color , 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(error_dir(te_idx),prct_ret24(te_idx));
plot(error_dir(te_idx), y_hat, 'Color',te_color , 'LineWidth', 2);
xlabel('Average Error'); ylabel('Percent Retention')
title('24-hour retention');
axis square
set(gca, 'FontSize', 16, 'FontName','Ariel');

%Success
figure; subplot(1,2,1); hold on
scatter(total_success(rpe_idx),prct_ret5(rpe_idx),'o','MarkerFaceColor',rpe_color,'MarkerEdgeColor','k','SizeData',100);
scatter(total_success(te_idx),prct_ret5(te_idx),'o','MarkerFaceColor',te_color,'MarkerEdgeColor','k','SizeData',100);
[~, y_hat, ~] = simple_regression(total_success,prct_ret5);
plot(total_success,y_hat, 'k', 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(total_success(rpe_idx),prct_ret5(rpe_idx));
plot(total_success(rpe_idx),y_hat, 'Color',rpe_color , 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(total_success(te_idx),prct_ret5(te_idx));
plot(total_success(te_idx), y_hat, 'Color',te_color , 'LineWidth', 2);
xlabel('Success Percent'); ylabel('Percent Retention')
title('5 minute retention');
axis square
set(gca, 'FontSize', 16, 'FontName','Ariel');

subplot(1,2,2); hold on
scatter(total_success(rpe_idx),prct_ret24(rpe_idx),'o','MarkerFaceColor',rpe_color,'MarkerEdgeColor','k','SizeData',100);
scatter(total_success(te_idx),prct_ret24(te_idx),'o','MarkerFaceColor',te_color,'MarkerEdgeColor','k','SizeData',100);
[~, y_hat, ~] = simple_regression(total_success,prct_ret24);
plot(total_success,y_hat, 'k', 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(total_success(rpe_idx),prct_ret24(rpe_idx));
plot(total_success(rpe_idx),y_hat, 'Color',rpe_color , 'LineWidth', 2);
[~, y_hat, ~] = simple_regression(total_success(te_idx),prct_ret24(te_idx));
plot(total_success(te_idx), y_hat, 'Color',te_color , 'LineWidth', 2);
xlabel('Success Percent'); ylabel('Percent Retention')
title('24-hour retention');
axis square
set(gca, 'FontSize', 16, 'FontName','Ariel');


% plot beginning vs end of each 
bsl_change = baseline_epochs(:,2) - baseline_epochs(:,1);
ret_change = ret24_epochs(:,2) - ret24_epochs(:,1);

%Plot learning inset
x_jitter_bsl = 0.95 + (1.05-0.95)*rand(length(bsl_change),1);
x_jitter_24 = 1.95 + (2.05-1.95)*rand(length(ret_change),1);

figure; hold on 
plot(0:3,zeros(4,1),'k--','LineWidth',1);
line([0.75, 1.25],[mean(bsl_change), mean(bsl_change)],'LineWidth',4,'Color','k');
line([1.75, 2.25],[mean(ret_change), mean(ret_change)],'LineWidth',4,'Color','k');
s1 = scatter(x_jitter_bsl, bsl_change,'o','MarkerFaceColor','k', 'MarkerEdgeColor','w');
s2 = scatter(x_jitter_24, ret_change,'o','MarkerFaceColor','k', 'MarkerEdgeColor','w');
plot(1:2, [bsl_change ret_change],'k')
alpha(s1,.5); alpha(s2,.5); 
title('Baseline and Retention differences','FontWeight','normal');
set(gca,'XTick',[1,2], 'XtickLabels', {'Baseline', '24-hr retention'},'FontName','Ariel','FontSize',16);
ylabel('Late - Early');


dot_size = 100;

% Is perception related to accuracy? 
%5 minutes
figure('Position',[10,500,800,500],'Color','w'); 
subplot(1,2,1); hold on
for a = 1:3

        rpe_data = total_success(percept_idx==a & GrpIdx==1);
        x_start_rpe = a-0.3;
        x_jitter_rpe = x_start_rpe + (x_start_rpe+0.1-x_start_rpe)*rand(length(rpe_data),1);

        line([x_start_rpe a-0.1],[mean(rpe_data), mean(rpe_data)],'LineWidth',4,'Color',rpe_color);
        errorbar(a-0.2, mean(rpe_data), SEM(rpe_data,1),'LineWidth',2,'Color', rpe_color, 'CapSize',cap_size_eb)
        s1 = scatter(x_jitter_rpe, rpe_data,'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor' ,'w', 'SizeData',dot_size);
        
        te_data = total_success(percept_idx==a & GrpIdx==2);
        x_start_te = a+0.1;
        x_jitter_te = x_start_te + (x_start_te+0.1-x_start_te)*rand(length(te_data),1);

        line([x_start_te, a+0.3],[mean(te_data), mean(te_data)],'LineWidth',4,'Color',te_color);
        errorbar(a+0.2, mean(te_data), SEM(te_data,1),'LineWidth',2,'Color', te_color, 'CapSize',cap_size_eb)
        s2 = scatter(x_jitter_te, te_data,'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData',dot_size);
        alpha(s1,.5); alpha(s2,.5); 
end
xlim([0.5 3.5]); ylim([0 100]);
ylabel('% Success','FontSize',20,'FontName','Ariel'); 
xlabel('Step length Perception','FontSize',20,'FontName','Ariel'); 
title('% Success during learning','FontSize',25,'FontName','Ariel');
set(gca, 'Xtick',1:3, 'XtickLabel',{'"Longer"', '"Slightly Longer"', '"Not Longer"'},'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);

%24 - hour
subplot(1,2,2); hold on
for a = 1:3

        rpe_data = mean_learn_err(percept_idx==a & GrpIdx==1);
        x_start_rpe = a-0.3;
        x_jitter_rpe = x_start_rpe + (x_start_rpe+0.1-x_start_rpe)*rand(length(rpe_data),1);

        line([x_start_rpe a-0.1],[mean(rpe_data), mean(rpe_data)],'LineWidth',4,'Color',rpe_color);
        errorbar(a-0.2, mean(rpe_data), SEM(rpe_data,1),'LineWidth',2,'Color', rpe_color, 'CapSize',cap_size_eb)
        s1 = scatter(x_jitter_rpe, rpe_data,'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor' ,'w', 'SizeData',dot_size);
        
        te_data = mean_learn_err(percept_idx==a & GrpIdx==2);
        x_start_te = a+0.1;
        x_jitter_te = x_start_te + (x_start_te+0.1-x_start_te)*rand(length(te_data),1);

        line([x_start_te, a+0.3],[mean(te_data), mean(te_data)],'LineWidth',4,'Color',te_color);
        errorbar(a+0.2, mean(te_data), SEM(te_data,1),'LineWidth',2,'Color', te_color, 'CapSize',cap_size_eb)
        s2 = scatter(x_jitter_te, te_data,'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData',dot_size);
        alpha(s1,.5); alpha(s2,.5); 
end
xlim([0.5 3.5]); ylim([0 10]);
ylabel('Error','FontSize',20,'FontName','Ariel'); 
xlabel('Step length Perception','FontSize',20,'FontName','Ariel'); 
title('Error during learning','FontSize',25,'FontName','Ariel');
set(gca, 'Xtick',1:3, 'XtickLabel',{'"Longer"', '"Slightly Longer"', '"Not Longer"'},'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);





%Make table
results_T = table;
results_T.EndLrn = EndLrn;
results_T.mean_learn_err = mean_learn_err;
results_T.total_success = total_success;
results_T.GrpIdx = GrpIdx;




end