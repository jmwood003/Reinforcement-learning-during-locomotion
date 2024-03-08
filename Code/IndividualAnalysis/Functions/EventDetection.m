function ET = EventDetection(T)

%This function detects heel strike and toe off events using the derivative
%of the marker as it crosses 0. Moving from negative to positive equals 
%toe off. Moving from postive to negative equals heel strike. Also cross 
%references this detection method with the peaks of the marker positions
%using 'findpeaks'.

%Set the find peaks variables
MinPeakProminence = 0.1; 
MinPeakDistance = 75; 
MaxPeakWidth = 100;

%Pre-allocate
Events = [];
phaseT = [];
Missing_Steps = struct;

%Loop through each phase
phases = unique(T.phase);
for phase_i = 1:length(phases)
    
    %Index current phase
    phaseidx = find(strcmp(phases{phase_i},T.phase)==1);
            
    %Index motion monitor live detected events (stride changes). Used as
    %the start/end points for event detection
    %Index the strides and step lengths for this experimental phase
    strides = T.StrideCount(phaseidx);
    %Index when the stride changes (LSL) and make sure they are not too
    %close
    MMstri = find(diff(strides)>0);
    tooclose_idx = find(diff(MMstri)<50);
    MMstri(tooclose_idx) = [];
    if isempty(tooclose_idx)==0
        warning('removed >0 strides from LSL because they were too close');
    end
    endframe = MMstri(end);

    %Extract the current trial's marker data, heel markers and toe markers
    %Y direction only
    RHLB = T.RHLBY_filt(phaseidx);
    LHLB = T.LHLBY_filt(phaseidx);
    RMEL = T.RMELY_filt(phaseidx);
    LMEL = T.LMELY_filt(phaseidx);

    %Find the derivative of the markers
    samplerate = T.Sample_Rate(1);
    fs = 1/samplerate;
    RheelD = diff(RHLB)./fs;
    LheelD = diff(LHLB)./fs;
    RtoeD = diff(RMEL)./fs;
    LtoeD = diff(LMEL)./fs;
    
    %Filter the derivative to make it easier to detect the events
    filtRheelD = lowpassfilter(RheelD,6,4,100);
    filtLheelD = lowpassfilter(LheelD,6,4,100);
    filtRtoeD = lowpassfilter(RtoeD,6,4,100);
    filtLtoeD = lowpassfilter(LtoeD,6,4,100);
    
    %Find the heel strikes and toe offs by finding the local maxima and minima
    [~, RHSpos_idx] = findpeaks(RHLB,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);
    [~, LHSpos_idx] = findpeaks(LHLB,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);
    [~, RTOpos_idx] = findpeaks(-RMEL,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);
    [~, LTOpos_idx] = findpeaks(-LMEL,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);

    %Detect Right heel strike
    RheelDchange = diff(filtRheelD>0);
    RHS_idx = find(RheelDchange == -1); 
    RHS_idx = RHS_idx(RHS_idx > RHSpos_idx(1)-5);
    RHS_idx = RHS_idx((RHS_idx < endframe+5));
    
    %Detect Left heel strike
    LheelDchange = diff(filtLheelD>0);
    LHS_idx = find(LheelDchange == -1);
    LHS_idx = LHS_idx(LHS_idx > LHSpos_idx(1)-10);
    LHS_idx = LHS_idx((LHS_idx < endframe+5));
    
    %Detect Right toe off
    RtoeDchange = diff(filtRtoeD>0);
    RTO_idx = find(RtoeDchange == 1);
    RTO_idx = RTO_idx(RTO_idx > RTOpos_idx(1)-5);
    RTO_idx = RTO_idx((RTO_idx < endframe+5));
    
    %Detect Left toe off
    LtoeDchange = diff(filtLtoeD>0);
    LTO_idx = find(LtoeDchange == 1);
    LTO_idx = LTO_idx(LTO_idx > LTOpos_idx(1)-5);
    LTO_idx = LTO_idx((LTO_idx < endframe+5)); 
    
    %Find any missing step lengths 
    %Left
    LcompareIdx = 1; 
    AddArray = 1;
    LmissingIdx = [];
    for Lpeaks_i = 1:length(LHS_idx)
        Ldifference = abs(LHS_idx(Lpeaks_i) - MMstri(LcompareIdx));
        if Ldifference > 50
            LmissingIdx(AddArray) = LHS_idx(Lpeaks_i);
            AddArray = AddArray+1;
        else
            LcompareIdx = LcompareIdx+1;
        end
    end
    %Save missing steps into a structure 
    phase_string = phases{phase_i};
    if strcmp(phase_string(1),'2')==1 
        phase_string = 'Retention24Hr';
    elseif strcmp(phase_string(1),'5')==1 
        phase_string = 'Retention5Min';
    end
    Missing_Steps.(phase_string) = LmissingIdx;

    %Determine which stride is first and remove the first step
    if LHS_idx(1) < RHS_idx(1) %Left step was first
        LHS_idx(1) = [];
        MMstri(1) = [];
    elseif RHS_idx(1) < LHS_idx(1) %Right step was first
        RHS_idx(1) = [];
    end    
    
    %Plot Events on Heel marker data
    EventsOnMarkers_fig = figure;
    %Right
    subplot(2,1,1); hold on
    plot(RHLB,'b');
    scatter(RHS_idx,RHLB(RHS_idx),'*','k');
    scatter(RTO_idx,RHLB(RTO_idx),'o','k');  
    title(['Right Heel Marker Y and Events - ', phases{phase_i}]);
    xlabel('Frames');
    ylabel('Meters');
    %Left  
    subplot(2,1,2); hold on
    plot(LHLB,'b');
    scatter(LHS_idx,LHLB(LHS_idx),'*','k');
    scatter(LTO_idx,LHLB(LTO_idx),'o','k');  
    scatter(MMstri,LHLB(MMstri),'d','m'); 
    plot(LmissingIdx,LHLB(LmissingIdx),'r*');
    title(['Left Heel Marker Y and Events - ', phases{phase_i}]);
    xlabel('Frames');
    ylabel('Meters');    
    legend('Heel Marker','HS','TO','MM LHS','Missing');
       
    %Save if desired
    saveas(EventsOnMarkers_fig, [phases{phase_i} '_EventsOnMarkers.fig']);

    %Create new event table
    lengths = [length(RHSpos_idx),length(RTOpos_idx),length(LHSpos_idx),length(LTOpos_idx),...
        length(RHS_idx),length(RTO_idx),length(LHS_idx),length(LTO_idx),...
        length(MMstri)];
    longest = max(lengths);
    
    %Save in table   
    PhaseEvents = nan(longest,5);
    PhaseEvents(1:length(RHS_idx),1) = RHS_idx;
    PhaseEvents(1:length(RTO_idx),2) = RTO_idx;
    PhaseEvents(1:length(LHS_idx),3) = LHS_idx;
    PhaseEvents(1:length(LTO_idx),4) = LTO_idx;
    PhaseEvents(1:length(MMstri),5) = MMstri;
    
    Events = [Events; PhaseEvents];
    phaseT = [phaseT; T(phaseidx(1:length(PhaseEvents)),1:8)];
    
end

%Save back into new table
TempT = array2table(Events,'VariableNames',{'RHS_frames','RTO_frames',...
    'LHS_frames','LTO_frames','StrideChange'});
ET = [phaseT, TempT];

save('Missing_steps','Missing_Steps');

end

