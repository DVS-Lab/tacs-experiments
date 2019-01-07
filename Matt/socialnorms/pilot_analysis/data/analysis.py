# -*- coding: utf-8 -*-
"""
Created on Sun Nov 11 18:51:17 2018

@author: mslip
"""
import glob
import pandas as pd
import numpy as np

ACTPJBLOCK = 1
ACDLPFCBLOCK = 2
ACSYNCBLOCK = 3
RNTPJBLOCK = 4
RNDLPFCBLOCK = 5
SHAMBLOCK = 6

tsv_files = glob.glob('*.tsv')
#print csv_files which is a list of filenames
print(tsv_files)
 
#intialize empty list that we will append dataframes to
subjects_df = []

#write a for loop that will go through each of the file name through globbing and the end result will be the list of dataframes
for filename in tsv_files:
    subjects_df.append(pd.read_csv(filename, delimiter='\t'))

subjects_means = []
subjects_game_type_transfer_means                = []
subjects_game_rtpj_rdlpfc_sham_transfer_means    = []
subjects_game_rn_rtpj_rdlpfc_sham_transfer_means = []
subjects_game_partner_transfer_means             = []
subjects_game_sync_sham_transfer_means = []
subjects_tacs_sync_rtpj_rdlpfc_sham_transfer_means = []
subjects_game_sync_rtpj_rdlpfc_sham_transfer_means = []
subjects_trns_sync_rtpj_rdlpfc_sham_transfer_means = []
subjects_game_transfer_means = []

stim_conds = [1,2,3,4,5,6]
game_conds = [1,2]
partner_conds = [1,2] # 1 - person
offer_conds = [1,2,3,4,5]

stim_cond_strings = ["tACS_rTPJ","tACS_rDLPFC","tACS_Sync","tRNS_rTPJ","tRNS_rDLPFC","Sham"]
game_cond_strings = ["Baseline","Punishment"]
partner_cond_strings = ["Person","PC"]

header = ""

for stim_ind in range(6):
        for game_ind in range(2):
            for partner_ind in range(2):
                    header = header + stim_cond_strings[stim_ind] + "_" + game_cond_strings[game_ind] + "_" + partner_cond_strings[partner_ind] + ", "

for subject_ind in range(13):
#    subject_means = []
    game_means = []
    stim_location_means = []
    
    game_partner_type_means = []
    game_stim_type_means = []
    game_stim_type_rn_means = []
    game_stim_type_sync_means = []
    stim_tacs_location_all_conditions_means = []
    stim_trns_location_all_conditions_means = []
#    for stim_ind in range(6):
#        for game_ind in range(2):
#            for partner_ind in range(2):
#                    perm_mean = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([stim_conds[stim_ind]])
#                                    & subjects_df[subject_ind].GameType.isin([game_conds[game_ind]])
#                                    & subjects_df[subject_ind].OpponentType.isin([partner_conds[partner_ind]])]['PlayerChoice'].mean()
#                    subject_means.append(perm_mean)
#    subjects_means.append(subject_means)
    
    
    
    perm_mean_tacs_sync     = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([ACSYNCBLOCK])]['PlayerChoice'].mean()
    perm_mean_tacs_rtpj     = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([ACTPJBLOCK])]['PlayerChoice'].mean()
    perm_mean_tacs_rdlpfc   = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([ACDLPFCBLOCK])]['PlayerChoice'].mean()
    perm_mean_sham          = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([SHAMBLOCK])]['PlayerChoice'].mean()
    stim_tacs_location_all_conditions_means.append(perm_mean_tacs_sync)
    stim_tacs_location_all_conditions_means.append(perm_mean_tacs_rtpj)
    stim_tacs_location_all_conditions_means.append(perm_mean_tacs_rdlpfc)
    stim_tacs_location_all_conditions_means.append(perm_mean_sham)
    subjects_tacs_sync_rtpj_rdlpfc_sham_transfer_means.append(stim_tacs_location_all_conditions_means)
    
    perm_mean_trns_rtpj     = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([RNTPJBLOCK])]['PlayerChoice'].mean()
    perm_mean_trns_rdlpfc   = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([RNDLPFCBLOCK])]['PlayerChoice'].mean()
    perm_mean_sham          = subjects_df[subject_ind][subjects_df[subject_ind].Condition.isin([SHAMBLOCK])]['PlayerChoice'].mean()
    stim_trns_location_all_conditions_means.append(perm_mean_trns_rtpj)
    stim_trns_location_all_conditions_means.append(perm_mean_trns_rdlpfc)
    stim_trns_location_all_conditions_means.append(perm_mean_sham)
    subjects_trns_sync_rtpj_rdlpfc_sham_transfer_means.append(stim_trns_location_all_conditions_means)
    
        
    perm_mean_baseline   = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1])]['PlayerChoice'].mean()
    perm_mean_punishment = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2])]['PlayerChoice'].mean()
    game_means.append(perm_mean_baseline)
    game_means.append(perm_mean_punishment)
    subjects_game_transfer_means.append(stim_location_means)
    
    perm_mean_baseline_sync = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([ACSYNCBLOCK])]['PlayerChoice'].mean()
    perm_mean_baseline_rtpj = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([ACTPJBLOCK])]['PlayerChoice'].mean()
    perm_mean_baseline_rdlpfc = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([ACDLPFCBLOCK])]['PlayerChoice'].mean()
    perm_mean_baseline_sham = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([SHAMBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_sync = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([ACSYNCBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_rtpj = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([ACTPJBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_rdlpfc = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([ACDLPFCBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_sham = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([SHAMBLOCK])]['PlayerChoice'].mean()
    game_stim_type_means.append(perm_mean_baseline_sync)
    game_stim_type_means.append(perm_mean_baseline_rtpj)
    game_stim_type_means.append(perm_mean_baseline_rdlpfc)
    game_stim_type_means.append(perm_mean_baseline_sham)
    game_stim_type_means.append(perm_mean_punishment_sync)
    game_stim_type_means.append(perm_mean_punishment_rtpj)
    game_stim_type_means.append(perm_mean_punishment_rdlpfc)
    game_stim_type_means.append(perm_mean_punishment_sham)
    subjects_game_sync_rtpj_rdlpfc_sham_transfer_means.append(game_stim_type_means)
    
    perm_mean_baseline_rtpj_rn = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([RNTPJBLOCK])]['PlayerChoice'].mean()
    perm_mean_baseline_rdlpfc_rn = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([RNDLPFCBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_rtpj_rn = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([RNTPJBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_rdlpfc_rn = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([RNDLPFCBLOCK])]['PlayerChoice'].mean()
    game_stim_type_rn_means.append(perm_mean_baseline_rtpj_rn)
    game_stim_type_rn_means.append(perm_mean_baseline_rdlpfc_rn)
    game_stim_type_rn_means.append(perm_mean_baseline_sham)
    game_stim_type_rn_means.append(perm_mean_punishment_rtpj_rn)
    game_stim_type_rn_means.append(perm_mean_punishment_rdlpfc_rn)
    game_stim_type_rn_means.append(perm_mean_punishment_sham)
    subjects_game_rn_rtpj_rdlpfc_sham_transfer_means.append(game_stim_type_rn_means)
    
    perm_mean_baseline_sync = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].Condition.isin([ACSYNCBLOCK])]['PlayerChoice'].mean()
    perm_mean_punishment_sync = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].Condition.isin([ACSYNCBLOCK])]['PlayerChoice'].mean()
    game_stim_type_sync_means.append(perm_mean_baseline_sync)
    game_stim_type_sync_means.append(perm_mean_baseline_sham)
    game_stim_type_sync_means.append(perm_mean_punishment_sync)
    game_stim_type_sync_means.append(perm_mean_punishment_sham)
    subjects_game_sync_sham_transfer_means.append(game_stim_type_sync_means)
    
    perm_mean_baseline_person = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].OpponentType.isin([1])]['PlayerChoice'].mean()
    perm_mean_baseline_pc = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([1]) 
                            & subjects_df[subject_ind].OpponentType.isin([2])]['PlayerChoice'].mean()
    perm_mean_punishment_person = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].OpponentType.isin([1])]['PlayerChoice'].mean()
    perm_mean_punishment_pc = subjects_df[subject_ind][subjects_df[subject_ind].GameType.isin([2]) 
                            & subjects_df[subject_ind].OpponentType.isin([2])]['PlayerChoice'].mean()
    game_partner_type_means.append(perm_mean_baseline_person)
    game_partner_type_means.append(perm_mean_baseline_pc)
    game_partner_type_means.append(perm_mean_punishment_person)
    game_partner_type_means.append(perm_mean_punishment_pc)
    subjects_game_partner_transfer_means.append(game_partner_type_means)