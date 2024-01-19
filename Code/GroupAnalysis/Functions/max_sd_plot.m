function max_sd_plot(T, BinSize)

%Find subjects
subjs = unique(T.SID);

%pre-allocate
%Loop through subject
max_bin = zeros(2,ceil(900/BinSize));
for s = 1:length(subjs)

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

    %Remove nans
    nan_idx = find(isnan(lrn_lsl)==1);
    lrn_lsl(nan_idx) = [];

    %Calculate variability bins
    binned_sd = Bin(lrn_lsl,BinSize,2,'std');
    [~, max_idx] = max(binned_sd);

    %Make an indexing variable for the group
    if strcmp(subjs{s}(1),'V')==1
        grp_idx(s,1) = 2;
        max_bin(2,max_idx) = max_bin(2,max_idx)+1;
    elseif strcmp(subjs{s}(1),'R')==1
        grp_idx(s,1) = 1;
        max_bin(1,max_idx) = max_bin(1,max_idx)+1;
    end

end

%Set colors for plotting
rpe_color = '#c51b7d';
te_color = '#276419';

figure('Color','w','Position',[100,500,1000,500]); hold on
b = bar(max_bin');
b(1).FaceColor = rpe_color;
b(2).FaceColor = te_color;
text(7, 6, 'RPE', 'FontSize', 20, 'FontWeight','bold', 'color', rpe_color);
text(7, 5.5, 'TE', 'FontSize', 20, 'FontWeight','bold', 'color', te_color);
xlabel('Bin num.');
ylabel('Subject count');
title('Max LSL standard deviation during learning');
set(gca,'XTick', 1:length(max_bin), 'FontSize',20, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 


end