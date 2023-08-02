function T = FilterMarkers(T)

%Extract trial names
Allvars = T.Properties.VariableNames;
CmkrsidxX = find(contains(Allvars,'X')==1);
CmkrsidxY = find(contains(Allvars,'Y')==1);
CmkrsidxZ = find(contains(Allvars,'Z')==1);
MkrIdx = sort([CmkrsidxX, CmkrsidxY, CmkrsidxZ]);
mkr_names = Allvars(MkrIdx);

%Loop through all the markers
for mkr_i = 1:length(mkr_names)

    %Index current marker name
    curmkr = mkr_names{mkr_i};
    newmkrStr = [curmkr '_filt'];
    phases = unique(T.phase);
    
    %Loop through each phase
    filt_mkr = [];
    %Loop through each trial
    for phase_i = 1:length(phases)
        
        %Index marker
        phaseidx = find(strcmp(phases{phase_i},T.phase)==1);
        mkr = T.(curmkr)(phaseidx);
        
        missingvals = find(isnan(mkr)==1);
        interpvals = spline(1:length(mkr),mkr,missingvals);
        mkr(missingvals) = interpvals;
    
        %Filter data
        mkrfilt = lowpassfilter(mkr,10,4,100);
        filt_mkr = [filt_mkr; mkrfilt];
    end
    %Save back into table
    T.(newmkrStr) = filt_mkr;
end
end