%% Experiment 1 - Individual analysis 

%Input the subject(s) you want to analyze

clear all; close all; clc;

%Single subject
Subjects = {'RewardFB_01'};
% % % All Subjects
% Subjects = {'RewardFB_01','RewardFB_03', 'VisualFB_04','VisualFB_05',...
% 'RewardFB_06','RewardFB_07','VisualFB_08','RewardFB_09','VisualFB_10',...
% 'VisualFB_11','RewardFB_12','VisualFB_14','RewardFB_15', 'VisualFB_16',...
% 'RewardFB_17','RewardFB_18','VisualFB_19', 'VisualFB_20','RewardFB_21',...
% 'VisualFB_22','VisualFB_23','VisualFB_24','RewardFB_25','VisualFB_26',...
% 'RewardFB_27','VisualFB_29','RewardFB_30','VisualFB_31','VisualFB_32',...
% 'RewardFB_33','RewardFB_34'};

%Jonathans laptop
GroupDir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Data/E1_individual_data'; %Set the directory
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Code/IndividualAnalysis');
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Code/IndividualAnalysis/Functions');
cd(GroupDir);


%% Load and organize the raw data

for subject_i = 1:length(Subjects)

    tic
    
    %Index the current subject
    subject_id = Subjects{subject_i};
    Current_dir = [GroupDir '/' subject_id];
    
    %Import and create table
    rawT = ImportData(Current_dir); 
    %filter markers
    rawT = FilterMarkers(rawT);

    %Save table
    save([subject_id '_rawDataTable'],'rawT');
    disp('Raw Data Table Saved');

    clear rawT

    toc

end

%% Event detection
    
for subject_i = 1:length(Subjects)

    tic
    
    %Index the current subject
    subject_id = Subjects{subject_i};
    cd([GroupDir '/' subject_id]);
    
    %Load data
    load([subject_id '_rawDataTable.mat']);

    %Calculcate events
    eventT = EventDetection(rawT);

    %Save table
    save([subject_id '_EventTable'],'eventT');
    disp('Tables Saved');

    clear eventT

    toc

end

%% Organize individual data

for subject_i = 1:length(Subjects)

    tic
    
    %Index the current subject
    subject_id = Subjects{subject_i};
    cd([GroupDir '/' subject_id]);
    
    load([subject_id '_rawDataTable.mat']);
    load([subject_id '_EventTable.mat']);

    %Subject table
    ST = DataAnalysis_e1(eventT,rawT);

    %Save table
    save([subject_id '_SubjectTable'],'ST');
    disp('Table Saved');

    clear ST rawT eventT

    toc

end


%% Plot individual data

for subject_i = 1:length(Subjects)

    tic
    
    %Index the current subject
    subject_id = Subjects{subject_i};
    cd([GroupDir '/' subject_id]);
    
    load([subject_id '_SubjectTable.mat']);

    %Plot
    ST = IndividualPlot_e1(ST);

    %Save table
    save([subject_id '_SubjectTable'],'ST');
    disp('Table Saved');

    clear ST 

    toc

end

%% Remove data and combine into a large table 

Subjects = {'RewardFB_01','RewardFB_03', 'VisualFB_04','VisualFB_05',...
'RewardFB_06','RewardFB_07','VisualFB_08','RewardFB_09','VisualFB_10',...
'VisualFB_11','RewardFB_12','VisualFB_14','RewardFB_15', 'VisualFB_16',...
'RewardFB_17','RewardFB_18','VisualFB_19', 'VisualFB_20','RewardFB_21',...
'VisualFB_23','VisualFB_24','RewardFB_25','VisualFB_26','RewardFB_27',...
'VisualFB_29','RewardFB_30','VisualFB_31','VisualFB_32', 'RewardFB_33',...
'RewardFB_34'};

GroupDir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Data/E1_individual_data'; %Set the directory
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Code/IndividualAnalysis');
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Code/IndividualAnalysis/Functions');
cd(GroupDir);

ET1 = [];
for subject_i = 1:length(Subjects)
    
    %Index the current subject
    subject_id = Subjects{subject_i};
    cd([GroupDir '/' subject_id]);
    
    load([subject_id '_SubjectTable.mat']);

    ET1 = [ET1; ST];

    clear ST 

end

cd('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Data');
save('E1data.mat','ET1');

