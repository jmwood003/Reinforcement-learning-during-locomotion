function [anova_T] = plot_e2_data(T, fig_dir, post_T, hdi_T)

phases = unique(T.phase,'stable');
subjs = unique(T.SID);

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

%loop through subjects
prctSL_change = [];  Target = [];
prct_retention_5 = []; prct_retention_24 = [];
retention_err_5 = []; retention_err_24 = [];
for subj_i = 1:length(subjs)
    
    %Make an indexing variable for the group
    if strcmp(subjs{subj_i}(1),'V')==1
        GrpIdx(subj_i,1) = 2;
    elseif strcmp(subjs{subj_i}(1),'R')==1
        GrpIdx(subj_i,1) = 1;
    end

    %loop through each phase
    AllStrides_temp = [];  Target_temp = [];
    for phase_i = 1:length(phases)

        %Index all steps for this phase
        phase_idx = find(strcmp(subjs{subj_i},T.SID)==1 & strcmp(phases{phase_i},T.phase)==1);
        current_pLSL = T.prctLSL(phase_idx);
        current_trgt = T.Trgt_prct(phase_idx);

        %Compile each phase
        AllStrides_temp = [AllStrides_temp, current_pLSL(1:short_phase(phase_i))'];
        Target_temp = [Target_temp, current_trgt(1:short_phase(phase_i))'];

        if strcmp('learning',phases{phase_i})==1

            %Index %LSL and remove nans
            LrnPC = T.prctLSL(phase_idx);
            nan_idx = find(isnan(LrnPC)==1);
            LrnPC(nan_idx)= [];

            %Error
            learning_error = abs(T.prctLSL(phase_idx) - T.Trgt_prct(phase_idx));
            learning_error(nan_idx)= [];

            %Success
            learning_success = T.Success(phase_idx);
            learning_success(nan_idx)= [];

            %Index early learning
            target = T.Trgt_prct(phase_idx);
            target(nan_idx)= [];
            maxPerturbIdx = find(target==10);
            ErlyLrnidx = maxPerturbIdx(1:50);

            %Calculcate outcome measures
            EndLrn(subj_i,1) = mean(LrnPC(end-49:end));
            error(subj_i,1:2) = [mean(learning_error(ErlyLrnidx)), mean(learning_error(end-49:end))];
            success(subj_i,1:2) = [(sum(learning_success(ErlyLrnidx))/length(ErlyLrnidx))*100, (sum(learning_success(end-49:end))/50)*100];
            
        end      
        
    end
    prctSL_change = [prctSL_change; AllStrides_temp];  
    Target = [Target; Target_temp];

    %Index specific phases to calculate retention
    lrn_idx = find(strcmp(subjs{subj_i},T.SID)==1 & strcmp('learning',T.phase)==1);
    R5m_idx = find(strcmp(subjs{subj_i},T.SID)==1 & strcmp('Retention5min',T.phase)==1);
    R24_idx = find(strcmp(subjs{subj_i},T.SID)==1 & strcmp('Retention24Hr',T.phase)==1);

    %calculate end of learning
    lrn_pLSL = T.prctLSL(lrn_idx);
    lrn_pLSL(isnan(lrn_pLSL)==1) = [];
    late_lrn(subj_i,1) = mean(lrn_pLSL(end-49:end));

    %calculate retention as a percentage of learning 
    R5_pLSL = T.prctLSL(R5m_idx)';
    R5_pLSL(isnan(R5_pLSL)==1) = [];
    mean_pR5(subj_i,1) = (mean(R5_pLSL)./late_lrn(subj_i,1))*100;

    R24_pLSL = T.prctLSL(R24_idx)';
    R24_pLSL(isnan(R24_pLSL)==1) = [];
    mean_pR24(subj_i,1) = (mean(R24_pLSL(1:25))./late_lrn(subj_i,1))*100;

    prct_retention_5 = [prct_retention_5; R5_pLSL(1:short_phase(3))./late_lrn(subj_i,1)*100];
    prct_retention_24 = [prct_retention_24; R24_pLSL(1:short_phase(4))./late_lrn(subj_i,1)*100];

    %calculate retention as the absolute difference from  learning 
    Mean_absR5(subj_i,1) = abs(mean(R5_pLSL) - late_lrn(subj_i,1));
    Mean_absR24(subj_i,1) = abs(mean(R24_pLSL(1:25)) - late_lrn(subj_i,1));

    retention_err_5 = [retention_err_5; abs(R5_pLSL(1:short_phase(3)) - late_lrn(subj_i,1))]; 
    retention_err_24 = [retention_err_24; abs(R24_pLSL(1:short_phase(4)) - late_lrn(subj_i,1))];

end

retention_prct = [mean_pR5, mean_pR24];
retention_error = [Mean_absR5, Mean_absR24];

%Group indexing variables
rpe_idx = find(GrpIdx==1);
te_idx = find(GrpIdx==2);

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';
outline_c1 = '#1f78b4';
outline_c2 = '#d95f02';

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%plot
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

figure('Position',[0,200,1300,800],'Color','w'); 
axes('Position', [0.15, 0.55, 0.7, 0.4]); hold on
rectangle('Position',[1, -40, short_phase(1), 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
rectangle('Position',[sum(short_phase(1:2)), -40, sum(short_phase(3:4))+25, 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
rectangle('Position',[sum(short_phase(1:3))+1, -5, 23, 25], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','k', 'LineWidth', 1.5);
s1 = shadedErrorBar(1:sum(short_phase(1:3)), nanmean(prctSL_change(rpe_idx,1:sum(short_phase(1:3)))), SEM(prctSL_change(rpe_idx,1:sum(short_phase(1:3))),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:sum(short_phase(1:3)), nanmean(prctSL_change(te_idx,1:sum(short_phase(1:3)))), SEM(prctSL_change(te_idx,1:sum(short_phase(1:3))),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none');
plot(1:sum(short_phase(1:2)),mean(Target(:,1:sum(short_phase(1:2)))),'k--','linewidth',1.5);
s3 = shadedErrorBar(sum(short_phase(1:3))+25:length(idxphases)+24,nanmean(prctSL_change(rpe_idx,sum(short_phase(1:3))+1:end)),SEM(prctSL_change(rpe_idx,sum(short_phase(1:3))+1:end),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s4 = shadedErrorBar(sum(short_phase(1:3))+25:length(idxphases)+24,nanmean(prctSL_change(te_idx,sum(short_phase(1:3))+1:end)),SEM(prctSL_change(te_idx,sum(short_phase(1:3))+1:end),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s3.edge,'LineStyle','none'); set(s4.edge,'LineStyle','none');
plot(1:length(idxphases)+25,zeros(1,length(idxphases)+25),'k','linewidth',1.5);
xlim([0 length(idxphases)]); ylim([-5 20]);

text(1000, 16, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
text(1000, 14.5, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
text(median(find(idxphases==1)),19,'Baseline','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
text(median(find(idxphases==2)),19,'Learning','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
text(median(find(idxphases==4)),19,'Retention','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
text(sum(short_phase(1:3))+12, 10, '24-hour break', 'Rotation',90, 'FontSize', 15,'Color','k', 'HorizontalAlignment','center','VerticalAlignment','middle');
set(gca,'FontSize',18, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title('Experiment 2','FontSize',25,'FontName','Ariel');
xlabel('Strides','FontSize',25,'FontName','Ariel');
ylabel('%LSL change','FontSize',25,'FontName','Ariel');

space = 40;

%Retention percent all strides
axes('Position', [0.05, 0.05, 0.35, 0.35]); hold on
rectangle('Position',[0, 0, short_phase(3), 200], 'FaceColor','none','EdgeColor','k', 'LineWidth', 1.5);
rectangle('Position',[space+1, 0, 25, 200], 'FaceColor','none','EdgeColor','k', 'LineWidth', 1.5);
s1 = shadedErrorBar(1:short_phase(3), nanmean(prct_retention_5(rpe_idx,:)), SEM(prct_retention_5(rpe_idx,:),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:short_phase(3), nanmean(prct_retention_5(te_idx,:)), SEM(prct_retention_5(te_idx,:),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none');
plot(1:short_phase(3),ones(1,short_phase(3))*100,'k--','linewidth',1.5);
s3 = shadedErrorBar([1:short_phase(4)]+space, nanmean(prct_retention_24(rpe_idx,:)), SEM(prct_retention_24(rpe_idx,:),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s4 = shadedErrorBar([1:short_phase(4)]+space, nanmean(prct_retention_24(te_idx,:)), SEM(prct_retention_24(te_idx,:),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s3.edge,'LineStyle','none'); set(s4.edge,'LineStyle','none');
plot([1:short_phase(4)]+space,ones(1,short_phase(4))*100,'k--','linewidth',1.5);
xlim([0, short_phase(4)+space+100]); ylim([0, 200]);
set(gca,'Box', 'off', 'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
ylabel('Percent retention (%)','FontSize',18,'FontName','Ariel', 'FontWeight','normal');
title('Retention Phase','FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
text(short_phase(3)+8, 100, '24-hour break', 'Rotation',90, 'FontSize', 15,'Color','k', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle');

%Plot retention percent epoch
x_jitter_rpe = normrnd(0.7,0.01,length(rpe_idx),1);
x_jitter_te = normrnd(1.1,0.01,length(rpe_idx),1);
dot_size = 25; lw = 2; cap_size_eb = 5;

axes('Position', [0.34, 0.12, 0.15, 0.2]); hold on
plot(0:4,ones(5,1)*100,'k--','LineWidth',1.5);
line([0.65, 0.95],[mean(mean_pR5(rpe_idx)), mean(mean_pR5(rpe_idx))],'LineWidth',lw,'Color',rpe_color);
line([1.05, 1.35],[mean(mean_pR5(te_idx)), mean(mean_pR5(te_idx))],'LineWidth',lw,'Color',te_color);
s1 = scatter(x_jitter_rpe, mean_pR5(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
s2 = scatter(x_jitter_te, mean_pR5(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
errorbar(0.8, mean(mean_pR5(rpe_idx)), SEM(mean_pR5(rpe_idx),1),'LineWidth',1.5,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(1.2, mean(mean_pR5(te_idx)), SEM(mean_pR5(te_idx),1),'LineWidth',1.5,'Color',te_color, 'CapSize',cap_size_eb)
line([0.65, 0.95]+1,[mean(mean_pR24(rpe_idx)), mean(mean_pR24(rpe_idx))],'LineWidth',lw,'Color',rpe_color);
line([1.05, 1.35]+1,[mean(mean_pR24(te_idx)), mean(mean_pR24(te_idx))],'LineWidth',lw,'Color',te_color);
s3 = scatter(x_jitter_rpe+1, mean_pR24(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
s4 = scatter(x_jitter_te+1, mean_pR24(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
errorbar(1.8, mean(mean_pR24(rpe_idx)), SEM(mean_pR24(rpe_idx),1),'LineWidth',1.5,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(2.2, mean(mean_pR24(te_idx)), SEM(mean_pR24(te_idx),1),'LineWidth',1.5,'Color',te_color, 'CapSize',cap_size_eb)
alpha(s1,.5); alpha(s2,.5); alpha(s3,.5); alpha(s4,.5); 
xlim([0.5, 2.5]); ylim([0, 250]);
set(gca,'XTick',[1,2],'XTickLabel',{'Immediate', '24-hour'},'Box', 'off', 'FontName','Ariel','FontSize',14, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
title('Epochs','FontSize',16,'FontName','Ariel', 'FontWeight', 'normal');

line([0.8, 1.2],[200, 200],'LineWidth',1,'Color','k');
line([1.8, 2.2],[200, 200],'LineWidth',1,'Color','k');
difference_prob_im = round((sum(post_T.e2_retprct_immediate<0)/height(post_T))*100,1);
text(1, 230, [num2str(difference_prob_im) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1, 210, ['[' num2str(round(hdi_T.e2_retprct_immediate(1),1)) ' ' num2str(round(hdi_T.e2_retprct_immediate(2),1)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

difference_prob_24 = round((sum(post_T.e2_retprct_24hr<0)/height(post_T))*100,1);
text(2, 230, [num2str(difference_prob_24) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(2, 210, ['[' num2str(round(hdi_T.e2_retprct_24hr(1),1)) ' ' num2str(round(hdi_T.e2_retprct_24hr(2),1)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

%Retention error all strides
axes('Position', [0.55, 0.05, 0.35, 0.35]); hold on
rectangle('Position',[0, 0, short_phase(3), 10], 'FaceColor','none','EdgeColor','k', 'LineWidth', 1.5);
rectangle('Position',[space+1, 0, 25, 10], 'FaceColor','none','EdgeColor','k', 'LineWidth', 1.5);
s1 = shadedErrorBar(1:short_phase(3), nanmean(retention_err_5(rpe_idx,:)), SEM(retention_err_5(rpe_idx,:),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s2 = shadedErrorBar(1:short_phase(3), nanmean(retention_err_5(te_idx,:)), SEM(retention_err_5(te_idx,:),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none');
s3 = shadedErrorBar([1:short_phase(4)]+space, nanmean(retention_err_24(rpe_idx,:)), SEM(retention_err_24(rpe_idx,:),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
s4 = shadedErrorBar([1:short_phase(4)]+space, nanmean(retention_err_24(te_idx,:)), SEM(retention_err_24(te_idx,:),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
set(s3.edge,'LineStyle','none'); set(s4.edge,'LineStyle','none');
xlim([0, short_phase(4)+space+100]); ylim([0, 10]);
set(gca,'Box', 'off', 'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
ylabel('Error (%LSL change)','FontSize',18,'FontName','Ariel'); 
title('Retention Phase','FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
text(short_phase(3)+8, 5, '24-hour break', 'Rotation',90, 'FontSize', 15,'Color','k', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle');

%Plot retention error epochs
x_jitter_rpe = normrnd(0.7,0.01,length(rpe_idx),1);
x_jitter_te = normrnd(1.1,0.01,length(rpe_idx),1);
dot_size = 25; lw = 2; cap_size_eb = 5;

axes('Position', [0.84, 0.12, 0.15, 0.2]); hold on
line([0.65, 0.95],[mean(Mean_absR5(rpe_idx)), mean(Mean_absR5(rpe_idx))],'LineWidth',lw,'Color',rpe_color);
line([1.05, 1.35],[mean(Mean_absR5(te_idx)), mean(Mean_absR5(te_idx))],'LineWidth',lw,'Color',te_color);
s1 = scatter(x_jitter_rpe, Mean_absR5(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
s2 = scatter(x_jitter_te, Mean_absR5(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
errorbar(0.8, mean(Mean_absR5(rpe_idx)), SEM(Mean_absR5(rpe_idx),1),'LineWidth',1.5,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(1.2, mean(Mean_absR5(te_idx)), SEM(Mean_absR5(te_idx),1),'LineWidth',1.5,'Color',te_color, 'CapSize',cap_size_eb)
line([0.65, 0.95]+1,[mean(Mean_absR24(rpe_idx)), mean(Mean_absR24(rpe_idx))],'LineWidth',lw,'Color',rpe_color);
line([1.05, 1.35]+1,[mean(Mean_absR24(te_idx)), mean(Mean_absR24(te_idx))],'LineWidth',lw,'Color',te_color);
s3 = scatter(x_jitter_rpe+1, Mean_absR24(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
s4 = scatter(x_jitter_te+1, Mean_absR24(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
errorbar(1.8, mean(Mean_absR24(rpe_idx)), SEM(Mean_absR24(rpe_idx),1),'LineWidth',1.5,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(2.2, mean(Mean_absR24(te_idx)), SEM(Mean_absR24(te_idx),1),'LineWidth',1.5,'Color',te_color, 'CapSize',cap_size_eb)
alpha(s1,.5); alpha(s2,.5); alpha(s3,.5); alpha(s4,.5); 
xlim([0.5, 2.5]); ylim([0, 12]);
set(gca,'XTick',[1,2],'XTickLabel',{'Immediate', '24-hour'},'Box', 'off', 'FontName','Ariel','FontSize',14, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
title('Epochs','FontSize',16,'FontName','Ariel', 'FontWeight', 'normal');

line([0.8, 1.2],[10, 10],'LineWidth',1,'Color','k');
line([1.8, 2.2],[10, 10],'LineWidth',1,'Color','k');
difference_prob_im = round((sum(post_T.e2_retacc_immediate<0)/height(post_T))*100,1);
text(1, 11.5, [num2str(difference_prob_im) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1, 10.5, ['[' num2str(round(hdi_T.e2_retacc_immediate(1),2)) ' ' num2str(round(hdi_T.e2_retacc_immediate(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

difference_prob_24 = round((sum(post_T.e2_retacc_24hr<0)/height(post_T))*100,1);
text(2, 11.5, [num2str(difference_prob_24) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(2, 10.5, ['[' num2str(round(hdi_T.e2_retacc_24hr(1),2)) ' ' num2str(round(hdi_T.e2_retacc_24hr(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

annotation('textbox',[0, 0.81, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0, 0.27, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.5, 0.27, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);

cd(fig_dir);
print('Figure_5','-dtiff', '-r300');

%Supplmental figure 1.
dot_size = 75; lw = 4; cap_size_eb = 5;

x_jitter_rpe = 0.8 + (0.9-0.8)*rand(length(rpe_idx),1);
x_jitter_te = 1.8 + (1.9-1.8)*rand(length(te_idx),1);

figure('Position',[0,200,1000,400],'Color','w'); 
axes('Position', [0.1, 0.1, 0.2, 0.8]); hold on
plot(0:3,ones(4,1)*10,'k--','LineWidth',2);
line([0.75, 1.25],[mean(EndLrn(rpe_idx)), mean(EndLrn(rpe_idx))],'LineWidth',4,'Color',rpe_color);
line([1.75, 2.25],[mean(EndLrn(te_idx)), mean(EndLrn(te_idx))],'LineWidth',4,'Color',te_color);
errorbar(1, mean(EndLrn(rpe_idx)), SEM(EndLrn(rpe_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(2, mean(EndLrn(te_idx)), SEM(EndLrn(te_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
s1 = scatter(x_jitter_rpe, EndLrn(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
s2 = scatter(x_jitter_te, EndLrn(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
alpha(s1,.5); alpha(s2,.5); 
xlim([0.5, 2.5]); ylim([0, 15]);
set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'Box', 'off', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
title('Late Learning','FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
ylabel('%LSL change','FontSize',18,'FontName','Ariel'); 

line([1, 2],[13, 13],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_lrn_diff<0)/height(post_T))*100,1);
text(1.5, 13.9, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 13.3, ['[' num2str(round(hdi_T.e2_lrn_diff(1),2)) ' ' num2str(round(hdi_T.e2_lrn_diff(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

line([1.3, 1.3],[0, mean(EndLrn(rpe_idx))],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_lrn_rpe>0)/height(post_T))*100,1);
text(1.52, mean(EndLrn(rpe_idx))/2, [num2str(difference_prob) '%'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', -90, 'VerticalAlignment','middle');
text(1.4, mean(EndLrn(rpe_idx))/2, ['[' num2str(round(hdi_T.e2_lrn_rpe(1),2)) ' ' num2str(round(hdi_T.e2_lrn_rpe(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel', 'rotation', -90, 'VerticalAlignment','middle');

%Early and late error
axes('Position', [0.4, 0.1, 0.2, 0.8]); hold on
plot(1:2, error(rpe_idx,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, error(te_idx,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(error(rpe_idx,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(error(te_idx,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 15]); 
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('|%LSL change - Target|','FontSize',18,'FontName','Ariel');
title('Error','FontWeight','normal','FontSize',20,'FontName','Ariel');

line([1, 2],[13, 13],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_error_interact>0)/height(post_T))*100,1);
text(1.5, 13.9, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 13.3, ['[' num2str(round(hdi_T.e2_error_interact(1),2)) ' ' num2str(round(hdi_T.e2_error_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

%Early and late percent success
axes('Position', [0.7, 0.1, 0.2, 0.8]); hold on
plot(1:2, success(rpe_idx,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, success(te_idx,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(success(rpe_idx,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(success(te_idx,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 110]);
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('% Target Hits','FontSize',18,'FontName','Ariel');
title('Percent Success','FontWeight','normal','FontSize',20,'FontName','Ariel'); 

line([1, 2],[100, 100],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e2_success_interact>0)/height(post_T))*100,1);
text(1.5, 107, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 102, ['[' num2str(round(hdi_T.e2_success_interact(1),2)) ' ' num2str(round(hdi_T.e2_success_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

annotation('textbox',[0.03, 0.8, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.33, 0.8, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.62, 0.8, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);

print('Figure_S1','-dtiff', '-r300');


%Make table for stats
anova_T = table;
anova_T.ret_prct = [retention_prct(:,1); retention_prct(:,2)];
anova_T.late_lrn = [late_lrn; nan(length(late_lrn),1)];
anova_T.error = [error(:,1); error(:,2)];
anova_T.ret_error = [Mean_absR5; Mean_absR24];
anova_T.success = [success(:,1); success(:,2)];
anova_T.subj_id = [subjs; subjs];
for i = 1:height(GrpIdx)
    time1{i,1} = 'Early';
    time2{i,1} = 'Late';
    time_ret1{i,1} = 'Immediate';
    time_ret2{i,1} = '24hr';

    if GrpIdx(i) == 1
        group{i,1} = 'RPE';
    else
        group{i,1} = 'TE';
    end
end
anova_T.time_ret = [time_ret1; time_ret2];
anova_T.group = [group; group];
anova_T.time = [time1; time2];

end