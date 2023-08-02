%% Experiment 2 - Individual analysis 

%Input the subject(s) you want to analyze

clear all; close all; clc;

%Input the subject(s) you (want to analyze
%Single subject
Subjects = {'RewardFB_ER_24'};
% % All Subjects
% Subjects = {'VisualFB_ER_01', 'VisualFB_ER_02', 'RewardFB_ER_03', 'VisualFB_ER_04',...
% 'RewardFB_ER_05','RewardFB_ER_06','VisualFB_ER_07','RewardFB_ER_08','VisualFB_ER_09',...
% 'RewardFB_ER_10','RewardFB_ER_11','RewardFB_ER_12','RewardFB_ER_13','VisualFB_ER_14',...
% 'RewardFB_ER_15','VisualFB_ER_16', 'VisualFB_ER_17','RewardFB_ER_18','RewardFB_ER_19',...
% 'VisualFB_ER_20','RewardFB_ER_21','VisualFB_ER_22','VisualFB_ER_23','RewardFB_ER_24',...
% 'VisualFB_ER_25','RewardFB_ER_26'};

%Jonathans laptop
GroupDir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Data/E2_individual_data'; %Set the directory
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
    ST = DataAnalysis_e2(eventT,rawT);

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
    ST = IndividualPlot_e2(ST);

    %Save table
    save([subject_id '_SubjectTable'],'ST');
    disp('Table Saved');

    clear ST 
    
    toc

end

%% Combine data into a large table 

Subjects = {'VisualFB_ER_01', 'VisualFB_ER_02', 'VisualFB_ER_04',...
'RewardFB_ER_05','RewardFB_ER_06','VisualFB_ER_07','VisualFB_ER_09',...
'RewardFB_ER_10','RewardFB_ER_11','RewardFB_ER_12','RewardFB_ER_13',...
'VisualFB_ER_14','RewardFB_ER_15','VisualFB_ER_16', 'VisualFB_ER_17',...
'RewardFB_ER_18','RewardFB_ER_19','VisualFB_ER_20','RewardFB_ER_21',...
'VisualFB_ER_22','VisualFB_ER_23','RewardFB_ER_24','VisualFB_ER_25',...
'RewardFB_ER_26'};

%Jonathans laptop
GroupDir = '/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Data/E2_individual_data'; %Set the directory
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Code/IndividualAnalysis');
addpath('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Code/IndividualAnalysis/Functions');
cd(GroupDir);

ET2 = [];
for subject_i = 1:length(Subjects)
    
    %Index the current subject
    subject_id = Subjects{subject_i};
    cd([GroupDir '/' subject_id]);
    
    load([subject_id '_SubjectTable.mat']);

    ET2 = [ET2; ST];

    clear ST 

end

cd('/Users/jonathanwood/Documents/GitHub/Reinforcement-learning-in-locomotion/Data');
save('E2data.mat','ET2');
