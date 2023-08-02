function  T = ImportData( S_dir )

%Put raw motion monitor data into a table

%Initialize table
T = table;

%Call all the files .csv
cd(S_dir);
all_files = dir('*.txt');

%Get the subjects ID using find the last '/' 
slash_idx = strfind(S_dir,'/');
last_slash = slash_idx(end);
subject_id = S_dir(last_slash+1:end);

%Loop through all the files for one subject
for all_files_i = 1:length(all_files)
    
    %Index file name and inport data
    filename = all_files(all_files_i).name;
    file = importdata(filename);
    
    %Index the current phase name
    undidx = strfind(filename,'_');
    dashidx = strfind(filename,'-');
    currentphase = filename(undidx(end)+1:dashidx-2);
    
    %Loop through each column and put data into table
    Columns = file.colheaders;
    DT = table;
    for cols_i = 1:length(Columns)
        currentname = Columns{cols_i};
        currentname = strrep(currentname,' #','');
        currentname = strrep(currentname,' ','');
        DT.(currentname) = file.data(:,cols_i);
    end
    
    %Extract some extra information from the file 
    %Date and time
    date_str = file.textdata{3,1};
    date_str = strrep(date_str,[subject_id '_' currentphase],'');
    dshidx = strfind(date_str,'-');
    slhidx = strfind(date_str,'/');
    date = date_str(1:dshidx(end)+4);
    time = date_str(dshidx(end)+5:slhidx(1)-1);
    Date = datetime([date 'T' time],'InputFormat','dd-MM-yyyy''T''HH:mm:ss:SSS');

    %Sample rate
    SRstr = file.textdata{4,1};
    slhidx = strfind(SRstr,'/');
    Sample_Ratenum = str2double(SRstr(1:slhidx(1)-1));
    Sample_Rate = ones(height(DT),1)*Sample_Ratenum;
    
    %Phase time in seconds
    PTstr = file.textdata{5,1};
    slhidx = strfind(PTstr,'/');
    PhaseDurationNum = str2double(PTstr(1:slhidx(1)-1));
    PhaseDuration = ones(height(DT),1)*PhaseDurationNum;
    
    %Target margin of error
    MOEstr = file.textdata{6,1};
    slhidx = strfind(MOEstr,'/');
    MOEnum = str2double(MOEstr(1:slhidx(1)-1));
    MOE = ones(height(DT),1)*MOEnum;
    
    %Baseline step lengths calculated during live data collection in motion
    %monitor
    BslLstr = file.textdata{7,1};
    slhidx = strfind(BslLstr,'/');
    MMbslLeftnum = str2double(BslLstr(1:slhidx(1)-1));
    MMbslLeft = ones(height(DT),1)*MMbslLeftnum;

    %Baseline step lengths calculated during live data collection in motion
    %monitor
    BslRstr = file.textdata{8,1};
    slhidx = strfind(BslRstr,'/');
    MMbslRightnum = str2double(BslRstr(1:slhidx(1)-1));
    MMbslRight = ones(height(DT),1)*MMbslRightnum;
    
    %Make phsae name and date into tables
    for i = 1:height(DT)
        phase{i,1} = currentphase;
        DateTime(i,1) = Date;
        SID{i,1} = subject_id;
    end
    
    %Save into table
    phaseT = table;
    phaseT = [array2table(SID), array2table(DateTime), cell2table(phase)...
        array2table(PhaseDuration), array2table(Sample_Rate),...
        array2table(MOE), array2table(MMbslLeft), array2table(MMbslRight), DT];

    T = [T; phaseT];
    phaseT = [];
    
   clear phase sessionID DateTime SID
   
end

%The first baseline phase will be incorrect so correct it
MMbslRight = T.MMbslRight(end);
MMbslLeft = T.MMbslLeft(end);
T.MMbslRight = ones(height(T),1)*MMbslRight;
T.MMbslLeft = ones(height(T),1)*MMbslLeft;

end