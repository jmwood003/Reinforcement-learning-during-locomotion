function  ST = IndividualPlot_e1(ST)

%Colors for plotting
miss_color = '#67a9cf';
hit_color = '#ef8a62';

%Extracts the subject ID as a string for plotting titles and saving
Subject_id = ST.SID{1};
Save_name = strrep(Subject_id,'_',' ');

%Index the phases
bslIdx = find(strcmp(ST.phase,'baseline')==1);
lrnIdx = find(strcmp(ST.phase,'learning')==1);
wshIdx = find(strcmp(ST.phase,'washout')==1);

%Make sure the successful trials are accurate
%In reward zone but counted as miss
ErrHit = find(ST.LSL(lrnIdx) < ST.TrgtHi_SL(lrnIdx) & ST.LSL(lrnIdx) > ST.TrgtLo_SL(lrnIdx) & ST.Success(lrnIdx)==0);
%Outside reward zone but counted as hit
ErrMiss = find(ST.LSL(lrnIdx) > ST.TrgtHi_SL(lrnIdx) & ST.LSL(lrnIdx) < ST.TrgtLo_SL(lrnIdx) & ST.Success(lrnIdx)==1);
%Display the findings
if isempty(ErrHit)==0
    disp('Warning: These steps in the reward zone are counted as misses: ');
    disp(ErrHit);
%     ST.Success(lrnIdx(ErrHit)) = 1;
end
if isempty(ErrMiss)==0
    disp(['Warning: These steps outside the reward zone are counted as hits: ', ErrMiss]);
%     ST.Success(lrnIdx(ErrMiss)) = 0;
end
if isempty(ErrMiss)==1 && isempty(ErrHit)==1
    disp('All steps during learning were accurately rewarded');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%PrctSL change
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%SL change
prctLSL = ST.prctLSL;

%High and low targets
HiPrct = ST.TrgtHi_prct;
LoPrct = ST.TrgtLo_prct;

%Hits and misses 
Hitidx = find(ST.Success==1);
Missidx = find(ST.Success==0);

%Success
TotalSuccess = nansum(ST.Success(lrnIdx));
PrctSuccess = (TotalSuccess/length(lrnIdx))*100;

%Variability
LrnLSL = prctLSL(lrnIdx);
LrnLSL(isnan(LrnLSL)==1) = [];

%demean
WindowLen = 10; 
movingMean = movmean(LrnLSL,WindowLen);
DetrendLSL = LrnLSL - movingMean;
LrnVar = std(DetrendLSL);

%Error
LrnTrgt = ST.Trgt_prct(lrnIdx(1:length(LrnLSL)));
absError = mean(abs(LrnTrgt - LrnLSL));

%Plot
LSLprctFig = figure('Color','w', 'Position',[100, 500, 1000, 400]); hold on
rectangle('Position',[-1, -40, length(bslIdx)+1, 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[wshIdx(1), -40, length(wshIdx), 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
plot(prctLSL,'o','MarkerFaceColor','k','MarkerEdgeColor','w');
p1 = plot(Hitidx, prctLSL(Hitidx),'o','MarkerFaceColor',hit_color,'MarkerEdgeColor','w');
p2 = plot(Missidx, prctLSL(Missidx),'o','MarkerFaceColor',miss_color,'MarkerEdgeColor','w');
plot(HiPrct,'k--','LineWidth',2);
plot(LoPrct,'k--','LineWidth',2);
plot(1:(height(ST)),zeros(1,height(ST)),'k-');
ylim([-20 35]); xlim([-1 height(ST)+1]);
legend([p1, p2], 'Hit', 'Miss','Location','South');
title([Save_name ' Percent SL Change']);
xlabel('Strides'); ylabel('%SL change from baseline');
text(125,30,'Baseline','FontSize',16, 'FontName','Arial', 'HorizontalAlignment','center');
text(750,30,'Learning','FontSize',16, 'FontName','Arial', 'HorizontalAlignment','center');
text(1700,30,'Washout','FontSize',16, 'FontName','Arial', 'HorizontalAlignment','center');
text(1200,25,['Percent Success = ', num2str(round(PrctSuccess,1)), '%'],'FontSize',16, 'FontName','Arial', 'HorizontalAlignment','left');
text(1200,22,['SL Variability (SD) = ', num2str(round(LrnVar,2))],'FontSize',16, 'FontName','Arial', 'HorizontalAlignment','left');
text(1200,19,['Mean Abs Error = ', num2str(round(absError,2))],'FontSize',16, 'FontName','Arial', 'HorizontalAlignment','left');
set(gca,'FontSize',20, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 

%Save
saveas(LSLprctFig,[Subject_id '_PrctLSL.fig']);
disp('Plots Saved');

end