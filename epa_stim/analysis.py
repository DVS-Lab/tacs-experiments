# -*- coding: utf-8 -*-
"""
Created on Fri Nov  9 19:40:04 2018

@author: mslip
"""
import glob
import pandas as pd
import matplotlib.pyplot as plt

tsv_files = glob.glob('*.tsv')
#print csv_files which is a list of filenames
print(tsv_files)
 
#intialize empty list that we will append dataframes to
subjects_df = []

#write a for loop that will go through each of the file name through globbing and the end result will be the list of dataframes
for filename in tsv_files:
    subjects_df.append(pd.read_csv(filename, delimiter='\t'))

stimulation_cond = [0,1,2] # tacs 1 -rTPJ, 2 - rDLPFC, 3 - Sync (both)
partner_cond     = [0,1,2] # 1 - neutral, 2 - 3/5, 3 - 5/5
offer_type_cond  = [0,1,2,3,4] # 1 - Keep $9, Give $1, 2 - Keep $8, Give $2,...
stim_location_means = []
subjects_stim_location_rejection_means = []
subjects_partner_type_rejection_means = []
subjects_offer_type_rejection_means = []
subjects_offer_type_partner_rejection_means = []
subjects_stim_location_partner_rejection_means = []
subjects_offer_type_stim_rejection_means = []

for subject_ind in range(12):
    offer_type_partner_means = []
    offer_type_stim_means = []
    partner_type_means = []
    stim_location_means = []
    offer_type_means = []
##    for stim_ind in range(3):
##        for partner_ind in range(3):
##            for offer_ind in range(5):
    perm_mean_rtpj_neutral = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                        & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_rtpj_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                        & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_rtpj_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                        & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_rdlpfc_neutral = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                        & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_rdlpfc_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                        & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_rdlpfc_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                        & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_sync_neutral = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([3])
                        & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_sync_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([3])
                        & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_sync_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([3])
                        & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    stim_location_means.append(perm_mean_rtpj_neutral)
    stim_location_means.append(perm_mean_rtpj_low)
    stim_location_means.append(perm_mean_rtpj_high)
    stim_location_means.append(perm_mean_rdlpfc_neutral)
    stim_location_means.append(perm_mean_rdlpfc_low)
    stim_location_means.append(perm_mean_rdlpfc_high)
    stim_location_means.append(perm_mean_sync_neutral)
    stim_location_means.append(perm_mean_sync_low)
    stim_location_means.append(perm_mean_sync_high)
    subjects_stim_location_partner_rejection_means.append(stim_location_means)
    
    perm_mean_neutral = subjects_df[subject_ind][subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_low = subjects_df[subject_ind][subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_high = subjects_df[subject_ind][subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    partner_type_means.append(perm_mean_neutral)
    partner_type_means.append(perm_mean_low)
    partner_type_means.append(perm_mean_high)
    subjects_partner_type_rejection_means.append(partner_type_means)
    
    perm_mean_offer_1_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_1_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_1_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_2_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_2_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_2_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_3_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_3_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_3_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_4_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_4_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_4_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_5_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].PartnerType.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_5_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].PartnerType.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_5_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].PartnerType.isin([3])]['PlayerChoice'].mean()
    offer_type_partner_means.append(perm_mean_offer_1_neutral)
    offer_type_partner_means.append(perm_mean_offer_1_low)
    offer_type_partner_means.append(perm_mean_offer_1_high)
    offer_type_partner_means.append(perm_mean_offer_2_neutral)
    offer_type_partner_means.append(perm_mean_offer_2_low)
    offer_type_partner_means.append(perm_mean_offer_2_high)
    offer_type_partner_means.append(perm_mean_offer_3_neutral)
    offer_type_partner_means.append(perm_mean_offer_3_low)
    offer_type_partner_means.append(perm_mean_offer_3_high)
    offer_type_partner_means.append(perm_mean_offer_4_neutral)
    offer_type_partner_means.append(perm_mean_offer_4_low)
    offer_type_partner_means.append(perm_mean_offer_4_high)
    offer_type_partner_means.append(perm_mean_offer_5_neutral)
    offer_type_partner_means.append(perm_mean_offer_5_low)
    offer_type_partner_means.append(perm_mean_offer_5_high)
    subjects_offer_type_partner_rejection_means.append(offer_type_partner_means)
    
    perm_mean_offer_1_rtpj = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].StimulationCondition.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_1_rdlpfc = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].StimulationCondition.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_1_sync = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].StimulationCondition.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_2_rtpj = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].StimulationCondition.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_2_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].StimulationCondition.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_2_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].StimulationCondition.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_3_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].StimulationCondition.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_3_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].StimulationCondition.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_3_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].StimulationCondition.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_4_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].StimulationCondition.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_4_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].StimulationCondition.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_4_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].StimulationCondition.isin([3])]['PlayerChoice'].mean()
    perm_mean_offer_5_neutral = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].StimulationCondition.isin([1])]['PlayerChoice'].mean()
    perm_mean_offer_5_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].StimulationCondition.isin([2])]['PlayerChoice'].mean()
    perm_mean_offer_5_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].StimulationCondition.isin([3])]['PlayerChoice'].mean()
    offer_type_stim_means.append(perm_mean_offer_1_neutral)
    offer_type_stim_means.append(perm_mean_offer_1_low)
    offer_type_stim_means.append(perm_mean_offer_1_high)
    offer_type_stim_means.append(perm_mean_offer_2_neutral)
    offer_type_stim_means.append(perm_mean_offer_2_low)
    offer_type_stim_means.append(perm_mean_offer_2_high)
    offer_type_stim_means.append(perm_mean_offer_3_neutral)
    offer_type_stim_means.append(perm_mean_offer_3_low)
    offer_type_stim_means.append(perm_mean_offer_3_high)
    offer_type_stim_means.append(perm_mean_offer_4_neutral)
    offer_type_stim_means.append(perm_mean_offer_4_low)
    offer_type_stim_means.append(perm_mean_offer_4_high)
    offer_type_stim_means.append(perm_mean_offer_5_neutral)
    offer_type_stim_means.append(perm_mean_offer_5_low)
    offer_type_stim_means.append(perm_mean_offer_5_high)
    subjects_offer_type_stim_rejection_means.append(offer_type_stim_means)