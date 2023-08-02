function  ST = IndividualPlot_e2(ST)

%Colors for plotting
miss_color = '#67a9cf';
hit_color = '#ef8a62';

%Extracts the subject ID as a string for plotting titles and saving
Subject_id = ST.SID{1};
Save_name = strrep(Subject_id,'_',' ');

%Index the phases
bslIdx = find(strcmp(ST.phase,'baseline')==1);
lrnIdx = find(strcmp(ST.phase,'learning')==1);
imm_retention_idx = find(strcmp(ST.phase,'Retention5min')==1);
d2_idx = find(strcmp(ST.phase,'Retention24Hr')==1);
d1_trgt_idx = find(strcmp(ST.phase,'learning')==1 | strcmp(ST.phase,'Retention5min')==1);

%Make sure the successful trials are accurate
%In reward zone but counted as miss
ErrHit = find(ST.LSL(d1_trgt_idx) <= ST.TrgtHi_SL(d1_trgt_idx) & ST.LSL(d1_trgt_idx) >= ST.TrgtLo_SL(d1_trgt_idx) & ST.Success(d1_trgt_idx)==0);
%Outside reward zone but counted as hit
ErrMiss_Hi = find((ST.LSL(d1_trgt_idx) > ST.TrgtHi_SL(d1_trgt_idx)) & (ST.Success(d1_trgt_idx)==1));
ErrMiss_Lo = find((ST.LSL(d1_trgt_idx) < ST.TrgtLo_SL(d1_trgt_idx)) & (ST.Success(d1_trgt_idx)==1));
%Display the findings
if isempty(ErrMiss_Hi)==1 && isempty(ErrMiss_Lo)==1 && isempty(ErrHit)==1
    disp('All steps for day 1 were accurately rewarded');
else
    disp('Warning: Steps during day 1 not properly rewarded');
    disp(d1_trgt_idx(ErrMiss_Hi));     disp(d1_trgt_idx(ErrMiss_Lo));     disp(d1_trgt_idx(ErrHit));

end

%In reward zone but counted as miss
ErrHit = find(ST.LSL(d2_idx) <= ST.TrgtHi_SL(d2_idx) & ST.LSL(d2_idx) >= ST.TrgtLo_SL(d2_idx) & ST.Success(d2_idx)==0);
%Outside reward zone but counted as hit
ErrMiss_Hi = find((ST.LSL(d2_idx) > ST.TrgtHi_SL(d2_idx)) & (ST.Success(d2_idx)==1));
ErrMiss_Lo = find((ST.LSL(d2_idx) < ST.TrgtLo_SL(d2_idx)) & (ST.Success(d2_idx)==1));
%Display the findings
if isempty(ErrMiss_Hi)==1 && isempty(ErrMiss_Lo)==1 && isempty(ErrHit)==1
    disp('All steps for day 2 were accurately rewarded');
else

    disp('Warning: Steps during day 2 not properly rewarded');

    %Correct
    correced_success = zeros(length(d2_idx),1);
    success_idx = find(ST.LSL(d2_idx) <= ST.TrgtHi_SL(d2_idx) & ST.LSL(d2_idx) >= ST.TrgtLo_SL(d2_idx));
    correced_success(success_idx) = 1;
    ST.Success(d2_idx) = correced_success;
    disp('Corrected');

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
rectangle('Position',[imm_retention_idx(1), -40, length(d2_idx)+length(imm_retention_idx), 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
xline(imm_retention_idx(end),'LineWidth',2);
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
text(1160,25,'5 Min','Rotation',90,'FontSize',16, 'FontName','Arial');
text(1300,30,'24 Hour Retention','FontSize',16, 'FontName','Arial', 'HorizontalAlignment','center');
set(gca,'FontSize',20, 'FontName','Arial', 'XColor', 'k', 'YColor','k', 'Layer', 'top', 'Color', 'none', 'LineWidth', 1); 
text(300,30,['Percent Success = ', num2str(round(PrctSuccess,1)), '%'],'FontSize',16, 'FontName','Arial');
text(300,27,['SL Variability (SD) = ', num2str(round(LrnVar,2))],'FontSize',16, 'FontName','Arial');
text(300,24,['Mean Abs Error = ', num2str(round(absError,2))],'FontSize',16, 'FontName','Arial');

%Save
saveas(LSLprctFig,[Subject_id '_PrctLSL.fig']);
disp('Plots Saved');

end