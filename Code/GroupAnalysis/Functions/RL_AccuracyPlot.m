function RL_AccuracyPlot(T)

phases = unique(T.phase, 'stable');
subjs = unique(T.SID);

%Calculate the shortest phase for all subjects to truncate
phaselength = []; 
for i = 1:length(subjs)
    for j = 1:length(phases)
        idx = find(strcmp(subjs{i},T.SID)==1 & strcmp(phases{j},T.phase)==1);
        LSL = T.LSL(idx);
        LSL(isnan(LSL)==1) = [];
        phaselength(i,j) = length(LSL);
    end
end
short_phase = nanmin(phaselength);

%Pre-allocate
grp_error = [];  
for s = 1:length(subjs)

    %Make an indexing variable for the group
    if strcmp(subjs{s}(1),'V')==1
        GrpIdx(s) = 2;
    elseif strcmp(subjs{s}(1),'R')==1
        GrpIdx(s) = 1;
    end

    temp_grp_error = []; idx_phases = [];
    for p = 1:length(phases)
    
        %Index phases
        phase_idx = find(strcmp(subjs{s},T.SID)==1 & strcmp(phases{p},T.phase)==1);

        lsl = T.prctLSL(phase_idx);

        if strcmp(phases{p},'baseline')==1
            target = zeros(length(lsl),1);
        elseif strcmp(phases{p},'learning')==1
            
            target = T.Trgt_prct(phase_idx);
            all_lrn = T.prctLSL(phase_idx);
            all_lrn(isnan(all_lrn)==1) = [];
            end_lrn = mean(all_lrn(end-49:end));

        elseif strcmp(phases{p},'washout')==1
%             target = zeros(length(lsl),1);
            target = ones(length(lsl),1)*end_lrn;
        elseif strcmp(phases{p},'Retention5min')==1 || strcmp(phases{p},'Retention24Hr')==1
            target = ones(length(lsl),1)*end_lrn;
        end
    
        %Calculate accuracy during learning 
        error = abs(lsl - target);
        error(isnan(error)==1) = [];

        if strcmp(phases{p},'learning')==1
            lrn_error(s,1) = mean(error(end-49:end));
        elseif strcmp(phases{p},'washout')==1
            init_wsh(s,1) = mean(error(1:5));
            early_wsh(s,1) = mean(error(6:30));
        end

        temp_grp_error = [temp_grp_error, error(1:short_phase(p))'];

        %Create indexing variable
        idx_phases = [idx_phases, ones(1,short_phase(p))*p];

    end
    grp_error = [grp_error; temp_grp_error];

   
end

%Group indexing variables
rpe_idx = find(GrpIdx==1);
te_idx = find(GrpIdx==2);

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';

dot_size = 75;
cap_size_eb = 5;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Plot Accuracy Data
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
if contains(T.SID{1},'ER')==1
    
    
    figure('Position',[0,200,1300,800],'Color','w'); 
    axes('Position', [0.05, 0.45, 0.9, 0.5]); hold on
    rectangle('Position',[1, -40, short_phase(1), 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
    rectangle('Position',[sum(short_phase(1:2)), -40, sum(short_phase(3:4))+25, 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
    rectangle('Position',[sum(short_phase(1:3))+1, -40, 23, 80], 'FaceColor','k','EdgeColor','none');
    s1 = shadedErrorBar(1:sum(short_phase(1:3)), nanmean(grp_error(rpe_idx,1:sum(short_phase(1:3)))), SEM(grp_error(rpe_idx,1:sum(short_phase(1:3))),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
    s2 = shadedErrorBar(1:sum(short_phase(1:3)), nanmean(grp_error(te_idx,1:sum(short_phase(1:3)))), SEM(grp_error(te_idx,1:sum(short_phase(1:3))),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
    set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none');
    s3 = shadedErrorBar(sum(short_phase(1:3))+25:length(idx_phases)+24,nanmean(grp_error(rpe_idx,sum(short_phase(1:3))+1:end)),SEM(grp_error(rpe_idx,sum(short_phase(1:3))+1:end),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1.5});
    s4 = shadedErrorBar(sum(short_phase(1:3))+25:length(idx_phases)+24,nanmean(grp_error(te_idx,sum(short_phase(1:3))+1:end)),SEM(grp_error(te_idx,sum(short_phase(1:3))+1:end),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1.5});
    set(s3.edge,'LineStyle','none'); set(s4.edge,'LineStyle','none')
    xlim([0 length(idx_phases)]); ylim([0 15]);
    
    text(median(find(idx_phases==1)),14,'Baseline','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
    text(median(find(idx_phases==2)),14,'Learning','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
    text(median(find(idx_phases==4)),14,'Retention','FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
    text(sum(short_phase(1:3))+12, 10, '24-hour break', 'Rotation',90, 'FontSize', 15,'Color','w');
    text(1000, 12, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
    text(1000, 11, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
    text(sum(short_phase(1:3))+12, 10, '24-hour break', 'Rotation',90, 'FontSize', 15,'Color','w');
    set(gca,'FontSize',18, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
    title('Experiment 2','FontSize',25,'FontName','Ariel');
    xlabel('Strides','FontSize',25,'FontName','Ariel');
    ylabel('%LSL error','FontSize',25,'FontName','Ariel');

    %Plot learning inset
    x_jitter_rpe = 0.8 + (0.9-0.8)*rand(length(rpe_idx),1);
    x_jitter_te = 1.8 + (1.9-1.8)*rand(length(te_idx),1);
    
    axes('Position', [0.25, 0.05, 0.15, 0.25]); hold on
    line([0.75, 1.25],[mean(lrn_error(rpe_idx)), mean(lrn_error(rpe_idx))],'LineWidth',4,'Color',rpe_color);
    line([1.75, 2.25],[mean(lrn_error(te_idx)), mean(lrn_error(te_idx))],'LineWidth',4,'Color',te_color);
    errorbar(1, mean(lrn_error(rpe_idx)), SEM(lrn_error(rpe_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
    errorbar(2, mean(lrn_error(te_idx)), SEM(lrn_error(te_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
    s1 = scatter(x_jitter_rpe, lrn_error(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
    s2 = scatter(x_jitter_te, lrn_error(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
    alpha(s1,.5); alpha(s2,.5); 
    xlim([0.5, 2.5]); ylim([0, 5]);
    set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'Box', 'off', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
    title('Late Learning','FontSize',25,'FontName','Ariel', 'FontWeight', 'normal');
    ylabel('%LSL error','FontSize',20,'FontName','Ariel'); 

else

    figure('Position',[0,200,1300,800],'Color','w'); 
    axes('Position', [0.05, 0.45, 0.9, 0.5]); hold on
    rectangle('Position',[1, -40, short_phase(1), 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
    rectangle('Position',[sum(short_phase(1:2)), -40, short_phase(3), 80], 'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
    s1 = shadedErrorBar(1:length(idx_phases),nanmean(grp_error(rpe_idx,:)),SEM(grp_error(rpe_idx,:),1),'transparent',1,'lineProps',{'Color',rpe_color,'LineWidth',1});
    s2 = shadedErrorBar(1:length(idx_phases),nanmean(grp_error(te_idx,:)),SEM(grp_error(te_idx,:),1),'transparent',1,'lineProps',{'Color',te_color,'LineWidth',1});
    set(s1.edge,'LineStyle','none'); set(s2.edge,'LineStyle','none')
    for p = 1:length(phases)
        text(median(find(idx_phases==p)),14,phases{p},'FontName','Arial','FontSize',25, 'HorizontalAlignment','center'); 
    end
    text(1000, 12, 'RPE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',rpe_color);
    text(1000, 11, 'TE', 'FontName','Arial','FontSize',20, 'FontWeight','bold', 'Color',te_color);
    xlim([0 length(idx_phases)]); ylim([0 15]);
    set(gca,'FontSize',20, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
    title('Experiment 1','FontSize',30,'FontName','Ariel', 'FontWeight', 'bold');
    ylabel('%LSL error','FontSize',25,'FontName','Ariel'); 
    xlabel('Strides','FontSize',25,'FontName','Ariel');
    
    rectangle('Position',[sum(short_phase(1:2))-50, 0, 50, 15],'FaceColor','none','EdgeColor','k','LineStyle','-','LineWidth',1);
    rectangle('Position',[sum(short_phase(1:2))+1, -7, 30, 17],'FaceColor','none','EdgeColor','k','LineStyle','-','LineWidth',1);
    
    %Plot learning inset
    x_jitter_rpe = 0.8 + (0.9-0.8)*rand(length(rpe_idx),1);
    x_jitter_te = 1.8 + (1.9-1.8)*rand(length(te_idx),1);
    
    
    axes('Position', [0.25, 0.05, 0.15, 0.25]); hold on
    line([0.75, 1.25],[mean(lrn_error(rpe_idx)), mean(lrn_error(rpe_idx))],'LineWidth',4,'Color',rpe_color);
    line([1.75, 2.25],[mean(lrn_error(te_idx)), mean(lrn_error(te_idx))],'LineWidth',4,'Color',te_color);
    errorbar(1, mean(lrn_error(rpe_idx)), SEM(lrn_error(rpe_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
    errorbar(2, mean(lrn_error(te_idx)), SEM(lrn_error(te_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
    s1 = scatter(x_jitter_rpe, lrn_error(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w','SizeData',dot_size);
    s2 = scatter(x_jitter_te, lrn_error(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w','SizeData',dot_size);
    alpha(s1,.5); alpha(s2,.5); 
    xlim([0.5, 2.5]); ylim([0, 5]);
    set(gca,'XTick',[],'FontName','Ariel','FontSize',18, 'Box', 'off', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
    title('Late Learning','FontSize',25,'FontName','Ariel', 'FontWeight', 'normal');
    ylabel('%LSL error','FontSize',20,'FontName','Ariel'); 
    
    %Plot implicit aftereffect
    x_jitter_rpe = normrnd(0.75,0.01,length(rpe_idx),1);
    x_jitter_te = normrnd(1.15,0.01,length(rpe_idx),1);
    
    axes('Position', [0.65, 0.05, 0.2, 0.25]); hold on
    line([0.65, 0.95],[mean(init_wsh(rpe_idx)), mean(init_wsh(rpe_idx))],'LineWidth',4,'Color',rpe_color);
    line([1.05, 1.35],[mean(init_wsh(te_idx)), mean(init_wsh(te_idx))],'LineWidth',4,'Color',te_color);
    errorbar(0.8, mean(init_wsh(rpe_idx)), SEM(init_wsh(rpe_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
    errorbar(1.2, mean(init_wsh(te_idx)), SEM(init_wsh(te_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
    s1 = scatter(x_jitter_rpe, init_wsh(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
    s2 = scatter(x_jitter_te, init_wsh(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
    
    line([0.65, 0.95]+1,[mean(early_wsh(rpe_idx)), mean(early_wsh(rpe_idx))],'LineWidth',4,'Color',rpe_color);
    line([1.05, 1.35]+1,[mean(early_wsh(te_idx)), mean(early_wsh(te_idx))],'LineWidth',4,'Color',te_color);
    s3 = scatter(x_jitter_rpe+1, early_wsh(rpe_idx),'o','MarkerFaceColor',rpe_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
    s4 = scatter(x_jitter_te+1, early_wsh(te_idx),'o','MarkerFaceColor',te_color, 'MarkerEdgeColor','w', 'SizeData', dot_size);
    errorbar(1.8, mean(early_wsh(rpe_idx)), SEM(early_wsh(rpe_idx),1),'LineWidth',2,'Color',rpe_color, 'CapSize',cap_size_eb)
    errorbar(2.2, mean(early_wsh(te_idx)), SEM(early_wsh(te_idx),1),'LineWidth',2,'Color',te_color, 'CapSize',cap_size_eb)
    alpha(s1,.5); alpha(s2,.5); alpha(s3,.5); alpha(s4,.5); 
    xlim([0.5, 2.5]); %ylim([-100, 100]);
    set(gca,'XTick',[1,2],'XTickLabel',{'Initial', 'Early'},'Box', 'off', 'FontName','Ariel','FontSize',18, 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1);
    % ylabel('$$\mathrm{\frac{Washout}{Learning}}$$*100\%','interpreter','latex','FontSize',20,'FontName','Ariel', 'FontWeight','normal');
    ylabel('%LSL error','FontSize',20,'FontName','Ariel', 'FontWeight','normal');
    title('Implicit Aftereffect','FontWeight','normal','FontSize',25,'FontName','Ariel', 'Color', 'k');

end

end