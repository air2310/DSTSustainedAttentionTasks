# Neurofeedback training of sustained visual attention - Tasks
Contact person: Angela Renton
Email: angie.renton23@gmail.com
ORCID: 0000-0003-4815-9056

Data License: CC-By Attribution 4.0 International
## Background.
In this project, we aimed to develop a neurofeedback protocol to enhance sustained visual attention. Lapses in sustained attention are common for healthy individuals monitoring visual displays for rare targets (e.g. proofreading, scanning blocks of code for discrepancies, monitoring radar), and have been shown to increase significantly in frequency and duration as time on task increases. Over the course of two studies we developed a neurofeedback protocol to alert participants of upcoming lapses in sustained attention, with the aim to determine if neurofeedback might enhance sustained attention. In Study 1, we developed a novel, engaging sustained attention task, and gathered data on how participants performed on this novel task without intervention. We used electroencephalography (EEG) data from this study to train a machine learning classifier to identify lapses in sustained attention. This machine learning classier was used to deliver task-contingent neurofeedback on participants current attentional state during Study 2. 

These folders contain the Matlab scripts used to present the sustained attention tasks for Studies 1 & 2.

## Study 1. 
The scripts used in Study 1 are in /DSTSustainedAttention1. In the top level of this folder, the Instructions.m file runs through the task instructions, and the DST_Study1.m file plays the task. There are two sub-folders; /stimuli contains the stimuli presented during the task, while /functions contained functions used throughout the task. 

The script functions/setupSettings.m can be used to change various task settings such as relative directories for results storage, monitor refresh rates and sizes, participant ID for counterbalancing, etc. 

## Study 2. 
The scripts used in Study 1 are in /DSTSustainedAttention2. In the top level of this folder, the DST_Study2_Instructions.m file runs through the task instructions. The DST_Study2_PrePostNF.m file plays the neurofeedback-free version of the task delivered before and after neurofeedback. The DST_Study2_Task.m file plays the neurofeedback version of the task. Note that this should be run together with the readEEG.py scripts for real-time EEG recording and neurofeedback generation found at https://github.com/air2310/ReadEEG. Finally, the Mackworth clock test delivered after neurofeedback is contained within DST_Study2_PostNFMackworth.m

There are two sub-folders; /stimuli contains the stimuli presented during the task, while /functions contained functions used throughout the task. 
The script functions/setupSettings.m can be used to change various task settings such as relative directories for results storage, monitor refresh rates and sizes, participant ID for counterbalancing, etc. 

## Dependencies
All task scripts rely on Psychtoolbox: http://psychtoolbox.org/ 

Note that both studies features eye-tracking and all task scripts are currently setup to connect to this eye tracker at a remote IP address. This will fail outside of the lab where the task was originally run. To disable this, set options.eyetracking=0 in functions/setupSettings.m
