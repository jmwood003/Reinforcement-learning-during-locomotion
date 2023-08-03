function anova_T = plot_e1_data(T, post_T, hdi_T)

phases = {'baseline','learning','washout'};
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
idxphases = [ones(1,short_phase(1)), ones(1,short_phase(2))*2, ones(1,short_phase(3))*3];

PrctSLchange = [];
Target = [];
for s = 1:length(subjs)
    
    %Make an indexing variable for the group
    if strcmp(subjs{s}(1),'V')==1
        GrpIdx(s,1) = 2;
    elseif strcmp(subjs{s}(1),'R')==1
        GrpIdx(s,1) = 1;
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

            %Index %LSL and remove nans
            LrnPC = T.prctLSL(fullidx);
            nan_idx = find(isnan(LrnPC)==1);
            LrnPC(nan_idx)= [];

            %Error
            learning_error = abs(T.prctLSL(fullidx) - T.Trgt_prct(fullidx));
            learning_error(nan_idx)= [];

            %Success
            learning_success = T.Success(fullidx);
            learning_success(nan_idx)= [];

            %Index early learning
            target = T.Trgt_prct(fullidx);
            target(nan_idx)= [];
            maxPerturbIdx = find(target==10);
            ErlyLrnidx = maxPerturbIdx(1:50);

            %Calculcate outcome measures
            EarlyLrn(s,1) = mean(LrnPC(ErlyLrnidx));
            EndLrn(s,1) = mean(LrnPC(end-49:end));
            error(s,1:2) = [mean(learning_error(ErlyLrnidx)), mean(learning_error(end-49:end))];
            success(s,1:2) = [(sum(learning_success(ErlyLrnidx))/length(ErlyLrnidx))*100, (sum(learning_success(end-49:end))/50)*100];
            
            total_var(s,1) = nanstd(LrnPC(maxPerturbIdx));
            total_success(s,1) = (sum(learning_success(maxPerturbIdx))/length(maxPerturbIdx))*100;

        end      
        
        %Washout
        if strcmp('washout',phases{p})==1
            WshPC = T.prctLSL(trunc_idx);
            WshPC(isnan(WshPC)==1) = [];
            Iwsh(s,1) = mean(WshPC(1:5));
            Ewsh(s,1) = mean(WshPC(6:30));

            Iwsh_RP(s,1) = (mean(WshPC(1:5))/EndLrn(s,1))*100;
            Ewsh_RP(s,1) = (mean(WshPC(6:30))/EndLrn(s,1))*100;
            prct_washout(s, 1:length(fullidx)) = (T.prctLSL(fullidx)'./EndLrn(s,1))*100;

        end            
        
        %Learning measures
        Temp_PrctSLchange = [Temp_PrctSLchange, T.prctLSL(trunc_idx)'];
                
        %Targets 
        Temp_Trgt = [Temp_Trgt, T.Trgt_prct(trunc_idx)'];
            
    end
    
    %Combine all phases
    PrctSLchange = [PrctSLchange; Temp_PrctSLchange];
    Target = [Target; Temp_Trgt];

end

%Group indexing variables
rpe_idx = find(GrpIdx==1);
te_idx = find(GrpIdx==2);
stable_idx = find(mean(Target,1)==10);

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';

dot_size = 50; mean_lw = 3; 
error_lw = 1.5; cap_size_eb = 5;

%Plot learning inset
x_jitter_rpe = normrnd(0.8,0.01,length(rpe_idx),1);
x_jitter_te = normrnd(1.8,0.01,length(rpe_idx),1);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Plot stride by stride data
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

figure('Position',[0,200,1300,800],'Color','w'); 
axes('Position', [0.05, 0.45, 0.9, 0.5]); hold on
rectangle('Position',[1, -40, short_phase(1), 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
rectangle('Position',[sum(short_phase(1:2)), -40, short_phase(3), 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
s1 = shadedErrorBar(1:length(idxphases),nanmean(PrctSLchange(rpe_idx,:)),SEM(PrctSLchange(rpe_idx,:),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1});
s2 = shadedErrorBar(1:length(idxphases),nanmean(PrctSLchange(te_idx,:)),SEM(PrctSLchange(te_idx,:),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1});
set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none')
plot(1:length(idxphases),mean(Target),'k--','linewidth',2);
plot(1:length(idxphases),zeros(1,length(idxphases)),'k','linewidth',1.5);
text(median(find(idxphases==1)),19,'Baseline','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
text(median(find(idxphases==2)),19,'Learning','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
text(median(find(idxphases==3)),19,'Washout','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
text(1000, 16, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
text(1000, 14, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
xlim([0 length(idxphases)]); ylim([-5 20]);
set(gca,'FontSize',20, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
title('Experiment 1','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
ylabel('\DeltaLSL (%)','FontSize',25,'FontName','Ariel'); 
xlabel('Strides','FontSize',25,'FontName','Ariel');

rectangle('Position',[sum(short_phase(1:2))-50, 0, 50, 15],'FaceColor','none','EdgeColor','k','LineStyle','-','LineWidth',1);
rectangle('Position',[sum(short_phase(1:2))+1, -7, 30, 17],'FaceColor','none','EdgeColor','k','LineStyle','-','LineWidth',1);
rectangle('Position',[stable_idx(1), 0, 50, 15],'FaceColor','none','EdgeColor','k','LineStyle','-','LineWidth',1);

axes('Position', [0.05, 0.05, 0.15, 0.25]); hold on
plot(0:3,ones(4,1)*10,'k--','LineWidth',2);
line([0.75, 1.25],[mean(EndLrn(rpe_idx)), mean(EndLrn(rpe_idx))],'LineWidth',mean_lw,'Color',rpe_color);
line([1.75, 2.25],[mean(EndLrn(te_idx)), mean(EndLrn(te_idx))],'LineWidth',mean_lw,'Color',te_color);
errorbar(1, mean(EndLrn(rpe_idx)), SEM(EndLrn(rpe_idx),1),'LineWidth',error_lw,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(2, mean(EndLrn(te_idx)), SEM(EndLrn(te_idx),1),'LineWidth',error_lw,'Color',te_color, 'CapSize',cap_size_eb)
s1 = scatter(x_jitter_rpe, EndLrn(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
s2 = scatter(x_jitter_te, EndLrn(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
alpha(s1,.5); alpha(s2,.5); 
xlim([0.5, 2.5]); ylim([0, 16]);
set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'Box', 'off', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
title('Late Learning','FontSize',20,'FontName','Ariel', 'FontWeight', 'normal');
ylabel('\DeltaLSL (%)','FontSize',18,'FontName','Ariel'); 

line([1, 2],[14, 14],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_lrn_diff<0)/height(post_T))*100,1);
text(1.5, 15.5, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 14.5, ['[' num2str(round(hdi_T.e1_lrn_diff(1),2)) ' ' num2str(round(hdi_T.e1_lrn_diff(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

%Early and late error
axes('Position', [0.27, 0.05, 0.15, 0.25]); hold on
plot(1:2, error(rpe_idx,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, error(te_idx,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(error(rpe_idx,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(error(te_idx,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 16]); 
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('|%LSL change - Target|','FontSize',18,'FontName','Ariel');
title('Error','FontWeight','normal','FontSize',20,'FontName','Ariel');

line([1, 2],[14, 14],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_error_interact>0)/height(post_T))*100,1);
text(1.5, 15.5, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 14.5, ['[' num2str(round(hdi_T.e1_error_interact(1),2)) ' ' num2str(round(hdi_T.e1_error_interact(2),2)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

%Early and late percent success
axes('Position', [0.5, 0.05, 0.15, 0.25]); hold on
plot(1:2, success(rpe_idx,:),'Color',rpe_color, 'LineWidth',0.5);
plot(1:2, success(te_idx,:),'Color',te_color, 'LineWidth',0.5);
plot(1:2, mean(success(rpe_idx,:)),'Color',rpe_color, 'LineWidth',4);
plot(1:2, mean(success(te_idx,:)),'Color',te_color, 'LineWidth',4);
xlim([0.5, 2.5]); ylim([0 110]);
set(gca,'FontSize',18, 'FontName','Arial', 'XTick', [1,2], 'XTickLabel', {'Early','Late'}, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
ylabel('% Target Hits','FontSize',18,'FontName','Ariel');
title('Percent Success','FontWeight','normal','FontSize',20,'FontName','Ariel'); 

line([1, 2],[100, 100],'LineWidth',1,'Color','k');
difference_prob = round((sum(post_T.e1_success_interact<0)/height(post_T))*100,1);
text(1.5, 110, [num2str(difference_prob) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1.5, 104, ['[' num2str(round(hdi_T.e1_success_interact(1),1)) ' ' num2str(round(hdi_T.e1_success_interact(2),1)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

%Plot implicit aftereffect
x_jitter_rpe = normrnd(0.7,0.01,length(rpe_idx),1);
x_jitter_te = normrnd(1.1,0.01,length(rpe_idx),1);

axes('Position', [0.75, 0.05, 0.2, 0.25]); hold on
plot(0:4,zeros(5,1),'k-','LineWidth',1);
line([0.65, 0.95],[mean(Iwsh_RP(rpe_idx)), mean(Iwsh_RP(rpe_idx))],'LineWidth',mean_lw,'Color',rpe_color);
line([1.05, 1.35],[mean(Iwsh_RP(te_idx)), mean(Iwsh_RP(te_idx))],'LineWidth',mean_lw,'Color',te_color);
errorbar(0.8, mean(Iwsh_RP(rpe_idx)), SEM(Iwsh_RP(rpe_idx),1),'LineWidth',error_lw,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(1.2, mean(Iwsh_RP(te_idx)), SEM(Iwsh_RP(te_idx),1),'LineWidth',error_lw,'Color',te_color, 'CapSize',cap_size_eb)
s1 = scatter(x_jitter_rpe, Iwsh_RP(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
s2 = scatter(x_jitter_te, Iwsh_RP(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);

line([0.65, 0.95]+1,[mean(Ewsh_RP(rpe_idx)), mean(Ewsh_RP(rpe_idx))],'LineWidth',mean_lw,'Color',rpe_color);
line([1.05, 1.35]+1,[mean(Ewsh_RP(te_idx)), mean(Ewsh_RP(te_idx))],'LineWidth',mean_lw,'Color',te_color);
s3 = scatter(x_jitter_rpe+1, Ewsh_RP(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
s4 = scatter(x_jitter_te+1, Ewsh_RP(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
errorbar(1.8, mean(Ewsh_RP(rpe_idx)), SEM(Ewsh_RP(rpe_idx),1),'LineWidth',error_lw,'Color',rpe_color, 'CapSize',cap_size_eb)
errorbar(2.2, mean(Ewsh_RP(te_idx)), SEM(Ewsh_RP(te_idx),1),'LineWidth',error_lw,'Color',te_color, 'CapSize',cap_size_eb)
alpha(s1,.5); alpha(s2,.5); alpha(s3,.5); alpha(s4,.5); 
xlim([0.5, 2.5]); ylim([-100, 170]);
set(gca,'XTick',[1,2],'XTickLabel',{'Initial', 'Early'},'Box', 'off', 'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
ylabel('Percent retention','FontSize',18,'FontName','Ariel', 'FontWeight','normal');
title('Implicit Aftereffect','FontWeight','normal','FontSize',20,'FontName','Ariel', 'Color', 'k');

line([0.8, 1.2],[140, 140],'LineWidth',1,'Color','k');
line([1.8, 2.2],[140, 140],'LineWidth',1,'Color','k');
difference_prob_im = round((sum(post_T.e1_washout_imm<0)/height(post_T))*100,1);
text(1, 165, [num2str(difference_prob_im) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(1, 150, ['[' num2str(round(hdi_T.e1_washout_imm(1),1)) ' ' num2str(round(hdi_T.e1_washout_imm(2),1)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

difference_prob_erl = round((sum(post_T.e1_washout_early<0)/height(post_T))*100,1);
text(2, 165, [num2str(difference_prob_erl) '%'],'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');
text(2, 150, ['[' num2str(round(hdi_T.e1_washout_early(1),1)) ' ' num2str(round(hdi_T.e1_washout_early(2),1)) ']'],...
    'HorizontalAlignment','center', 'FontSize', 12, 'FontName', 'Ariel');

annotation('textbox',[0, 0.81, 0.2, 0.2], 'String', 'A','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0, 0.18, 0.2, 0.2], 'String', 'B','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.21, 0.18, 0.2, 0.2], 'String', 'C','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.44, 0.18, 0.2, 0.2], 'String', 'D','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);
annotation('textbox',[0.67, 0.18, 0.2, 0.2], 'String', 'E','FontName','Arial','FontWeight', 'bold', 'BackgroundColor','none','EdgeColor','none', 'FontSize', 40);


%Make table for stats
anova_T = table;
anova_T.washout = [Iwsh_RP; Ewsh_RP];
anova_T.error = [error(:,1); error(:,2)];
anova_T.success = [success(:,1); success(:,2)];
anova_T.learning = [EarlyLrn; EndLrn];
anova_T.subj_id = [subjs; subjs];
for i = 1:height(GrpIdx)
    time1{i,1} = 'Early';
    time2{i,1} = 'Late';
    if GrpIdx(i) == 1
        group{i,1} = 'RPE';
    else
        group{i,1} = 'TE';
    end
end
anova_T.group = [group; group];
anova_T.time = [time1; time2];



end