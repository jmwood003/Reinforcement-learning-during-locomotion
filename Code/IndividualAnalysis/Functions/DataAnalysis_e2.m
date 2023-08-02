function newST = DataAnalysis_e2(ST,T)

phases = {'baseline','learning','Retention5min','Retention24Hr'};
newST = table;
for p = 1:length(phases)
    
    %Index the phase
    cp = phases(p);
    Tidx = find(strcmp(T.phase,cp)==1);
    Sidx = find(strcmp(ST.phase,cp)==1);
    
    %Index the left and right kinematic step lengths right step length    
    LHSkin_idx = ST.LHS_frames(Sidx);
    LHSkin_idx(isnan(LHSkin_idx)==1) = [];
    RHSkin_idx = ST.RHS_frames(Sidx);
    RHSkin_idx(isnan(RHSkin_idx)==1) = [];

    Rheel = T.RHLBY_filt(Tidx);
    Lheel = T.LHLBY_filt(Tidx);

    LSLmm_idx = ST.StrideChange(Sidx);
    LSLmm_idx(isnan(LSLmm_idx)==1) = [];
    
    %Calculate LSL
    LSL_kin = nan(length(LHSkin_idx),1);
    for LSLi = 1:length(LHSkin_idx)
        LSL_kin(LSLi,1) = Lheel(LHSkin_idx(LSLi)) - Rheel(LHSkin_idx(LSLi));
    end
    %Calculate RSL
    RSL_kin = nan(length(LHSkin_idx),1);
    for RSLi = 1:length(RHSkin_idx)
        RSL_kin(RSLi,1) = Rheel(RHSkin_idx(RSLi)) - Lheel(RHSkin_idx(RSLi));
    end
    
    %Calculate step length asymmetry
    SLA = nan(length(LHSkin_idx),1);
    for steps_i = 1:length(LSL_kin)-1
        SLA(steps_i,1) = ((LSL_kin(steps_i) - RSL_kin(steps_i))./(LSL_kin(steps_i) + RSL_kin(steps_i)))*100;
    end
    
    %Calculate peak velocity 
    fs = 1/ST.Sample_Rate(1);
    LTOkin_idx = ST.LTO_frames(Sidx);
    LTOkin_idx(isnan(LTOkin_idx)==1) = [];
    if LTOkin_idx(1) < LHSkin_idx(1) %HS should always be first
        LTOkin_idx(1) = [];
    end
    
    %----------------------------------------------------------------------   
    %Index left step length calculated live
    %----------------------------------------------------------------------
    
    MM_LSLs = T.LSLcompare(Tidx);
    
    LSL = nan(length(LHSkin_idx),1);
    StrideNum = nan(length(LHSkin_idx),1);
    for l = 1:length(LSLmm_idx)
        
        %Index all frames in the current stride, 
        %If statement account for the final stride
        if l == length(LSLmm_idx)
            LSLwindow = MM_LSLs(LSLmm_idx(l):end);
        else
            LSLwindow = MM_LSLs(LSLmm_idx(l):LSLmm_idx(l+1));
        end

        %Left step length (find and confirm)-------------------------------
        %Make sure only 1 step length is counted 
        Lidx = find(diff(LSLwindow)>0); %frames that MM registered a step length
        if isempty(Lidx)==1
            LSL(l,1) = nan;
            LSLdataSample(l,1) = LSLmm_idx(l);            
        else
            LSL(l,1) = LSLwindow(Lidx(1)+1);
            LSLdataSample(l,1) = LSLmm_idx(l) + Lidx(1)+1;   
        end
        
        %Sometimes MM registeres more than 1 step, but the SL values should all 
        %be the same, throw an error if this is false
        if sum(diff(LSLwindow(Lidx))) ~= 0 
            error('Differences in the SL detected in the window');
        end

        StrideNum(l) = l;
            
    end
    
    %----------------------------------------------------------------------
    %Index task success and the targets
    %----------------------------------------------------------------------
    Success = nan(length(LHSkin_idx),1);
    Trgt_prct = nan(length(LHSkin_idx),1);
    Trgt_SL = nan(length(LHSkin_idx),1);
    TrgtHi_SL = nan(length(LHSkin_idx),1);
    TrgtLo_SL = nan(length(LHSkin_idx),1);
    TrgtHi_prct = nan(length(LHSkin_idx),1);
    TrgtLo_prct = nan(length(LHSkin_idx),1);
    %Index success 
    if strcmp(cp,'baseline')==1 
        LSLtrue = LSL;
        LSLtrue(isnan(LSLtrue)==1) = [];
        LSL_kin_true = LSL_kin;
        LSL_kin_true(isnan(LSL_kin_true)==1) = [];        
        disp(['Kinematic Baseline calc = ', num2str(mean(LSL_kin_true(end-49:end)))]);
        disp(['Motion Monitor Steps Baseline calc = ', num2str(mean(LSLtrue(end-49:end)))]);
        disp(['Live Baseline calc = ', num2str(ST.MMbslLeft(1))]);

        %Live calculation differences
        bslCalc_diff = mean(LSLtrue(end-49:end)) - ST.MMbslLeft(1);
        

        %Use the baseline we are using for live feedback
%         bslLSL = mean(LSLtrue(end-49:end));
        bslLSL = ST.MMbslLeft(1);

    else
        %Index success
        Hitphase = T.Success(Tidx);
        current_success = Hitphase(LSLdataSample-1);
        %Check for adjacement success that was missed by the current index
        checkSuccess = [-2 0 1];
        for c = 1:length(checkSuccess)
            if LSLdataSample(end)+checkSuccess(c) >= length(Hitphase)
                break
            end
            Hitidx = Hitphase(LSLdataSample+(checkSuccess(c)));
            addsuccess = find(Hitidx==1 & current_success==0);
            current_success(addsuccess) = 1;
        end
        Success(1:length(LSLdataSample)) = current_success;
        
        %Index targets
        %SL target
        SLTphase = (bslLSL*T.Target(Tidx)) + bslLSL;
        if LSLdataSample(end)>length(SLTphase)
            LSLdataSample(end)=length(SLTphase);
        end
        Trgt_SL(1:length(LSLdataSample)) = SLTphase(LSLdataSample);     
        %High taget
        TrgtHi_SL = Trgt_SL + 0.02;
        %Low target
        TrgtLo_SL = Trgt_SL - 0.02;

        %Percent SL change targets
        Trgtphase = T.Target(Tidx)*100;
        Trgt_prct(1:length(LSLdataSample)) = Trgtphase(LSLdataSample);    
        %High
        TrgtHi_prct = ((TrgtHi_SL - bslLSL)./bslLSL)*100;
        %Low
        TrgtLo_prct = ((TrgtLo_SL - bslLSL)./bslLSL)*100;

    end 
    
    %Percent step length 
    prctLSL = ((LSL - bslLSL)./bslLSL)*100;

    %Make table
    tempT = [ST(Sidx(1:length(LSL)),:), array2table(StrideNum), array2table(Trgt_SL), array2table(TrgtHi_SL), array2table(TrgtLo_SL),...
        array2table(Trgt_prct), array2table(TrgtHi_prct), array2table(TrgtLo_prct), array2table(Success),...
        array2table(LSL), array2table(LSL_kin), array2table(RSL_kin), array2table(SLA), array2table(prctLSL)];

    %Make table
    newST = [newST; tempT];
    
    clear LSL LSLdataSample Success Trgt_prct Trgt_SL TrgtHi_SL TrgtLo_SL LSL_kin RSL_kin SLA tempT StrideNum
    
end
end