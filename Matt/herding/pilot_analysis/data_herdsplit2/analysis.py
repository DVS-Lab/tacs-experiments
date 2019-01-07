# -*- coding: utf-8 -*-
"""
Created on Sun Nov 11 18:51:17 2018

@author: mslip
"""

# -*- coding: utf-8 -*-
"""
Created on Fri Nov  9 19:40:04 2018

@author: mslip
"""
import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

tsv_files = glob.glob('*.tsv')
#print csv_files which is a list of filenames
print(tsv_files)
 
#intialize empty list that we will append dataframes to
subjects_df = []

#write a for loop that will go through each of the file name through globbing and the end result will be the list of dataframes
for filename in tsv_files:
    subjects_df.append(pd.read_csv(filename, delimiter='\t'))

stim_location_means = []
subjects_stim_location_rejection_means = []
subjects_herd_type_rejection_means = []
subjects_offer_type_rejection_means = []

for subject_ind in range(12):
    stim_location_means = []
    herd_type_means = []
    offer_type_means = []
    
    conditions = [
    (subjects_df[subject_ind]['FramingType'] == 1) & (subjects_df[subject_ind]['PlayerChoice'] == 1),
    (subjects_df[subject_ind]['FramingType'] == 1) & (subjects_df[subject_ind]['PlayerChoice'] == 0),
    (subjects_df[subject_ind]['FramingType'] == 0) & (subjects_df[subject_ind]['PlayerChoice'] == 1),
    (subjects_df[subject_ind]['FramingType'] == 0) & (subjects_df[subject_ind]['PlayerChoice'] == 0)]
    choices = [1,0,0,1]
    
##    for stim_ind in range(3):
##        for partner_ind in range(3):
##            for offer_ind in range(5):
    subjects_df[subject_ind]['Conformity'] = np.select(conditions, choices)
    
    perm_mean_rtpj_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                                & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_rtpj_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                                & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_rtpj_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                                & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_rtpj_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([1])
                                & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    perm_mean_rdlpfc_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                                & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_rdlpfc_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                                & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_rdlpfc_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                                & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_rdlpfc_high = subjects_df[subject_ind][subjects_df[subject_ind].StimulationCondition.isin([2])
                                & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    stim_location_means.append(perm_mean_rtpj_low)
    stim_location_means.append(perm_mean_rtpj_medium_low)
    stim_location_means.append(perm_mean_rtpj_medium_high)
    stim_location_means.append(perm_mean_rtpj_high)
    stim_location_means.append(perm_mean_rdlpfc_low)
    stim_location_means.append(perm_mean_rdlpfc_medium_low)
    stim_location_means.append(perm_mean_rdlpfc_medium_high)
    stim_location_means.append(perm_mean_rdlpfc_high)
    subjects_stim_location_rejection_means.append(stim_location_means)
    
    
    perm_mean_low = subjects_df[subject_ind][subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_high = subjects_df[subject_ind][subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    herd_type_means.append(perm_mean_low)
    herd_type_means.append(perm_mean_medium_low)
    herd_type_means.append(perm_mean_medium_high)
    herd_type_means.append(perm_mean_high)
    subjects_herd_type_rejection_means.append(herd_type_means)
    
    perm_mean_offer_1_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_offer_1_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_offer_1_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_offer_1_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([1])
                            & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    perm_mean_offer_2_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_offer_2_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_offer_2_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_offer_2_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([2])
                            & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    perm_mean_offer_3_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_offer_3_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_offer_3_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_offer_3_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([3])
                            & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    perm_mean_offer_4_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_offer_4_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_offer_4_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_offer_4_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([4])
                            & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    perm_mean_offer_5_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].HerdType.isin([1.0])]['Conformity'].mean()
    perm_mean_offer_5_medium_low = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].HerdType.isin([2.0])]['Conformity'].mean()
    perm_mean_offer_5_medium_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].HerdType.isin([3.0])]['Conformity'].mean()
    perm_mean_offer_5_high = subjects_df[subject_ind][subjects_df[subject_ind].OfferType.isin([5])
                            & subjects_df[subject_ind].HerdType.isin([4.0])]['Conformity'].mean()
    offer_type_means.append(perm_mean_offer_1_low)
    offer_type_means.append(perm_mean_offer_1_medium_low)
    offer_type_means.append(perm_mean_offer_1_medium_high)
    offer_type_means.append(perm_mean_offer_1_high)
    offer_type_means.append(perm_mean_offer_2_low)
    offer_type_means.append(perm_mean_offer_2_medium_low)
    offer_type_means.append(perm_mean_offer_2_medium_high)
    offer_type_means.append(perm_mean_offer_2_high)
    offer_type_means.append(perm_mean_offer_3_low)
    offer_type_means.append(perm_mean_offer_3_medium_low)
    offer_type_means.append(perm_mean_offer_3_medium_high)
    offer_type_means.append(perm_mean_offer_3_high)
    offer_type_means.append(perm_mean_offer_4_low)
    offer_type_means.append(perm_mean_offer_4_medium_low)
    offer_type_means.append(perm_mean_offer_4_medium_high)
    offer_type_means.append(perm_mean_offer_4_high)
    offer_type_means.append(perm_mean_offer_5_low)
    offer_type_means.append(perm_mean_offer_5_medium_low)
    offer_type_means.append(perm_mean_offer_5_medium_high)
    offer_type_means.append(perm_mean_offer_5_high)
    subjects_offer_type_rejection_means.append(offer_type_means)