# -*- coding: utf-8 -*-
"""
Stimulation Bar Plot - social-norms - Participant 005 
"""
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def find(f, seq):
  """Return first item in sequence where f(item) == True."""
  for item in seq:
    if f(item): 
      return item

class conditionPermutation(object):
    def __init__(self,location=None,partnerType=None,
                 framingType=None,offerType=None):
        self.location    = location
        self.partnerType = partnerType
        self.framingType = framingType
        self.offerType   = offerType
        self.accepted    = 0
        self.rejected    = []

locations = ['rTPJ','rDLPFC','rTPJ + rDLPFC']
partnerTypes = ['5/5','3/5','None']
framingTypes = ['Accepted','Rejected']
offerTypes = ['Keep $9, Give $1','Keep $8, Give $2','Keep $7, Give $3',
              'Keep $6, Give $4','Keep $5, Give $5']
ACTPJBLOCK = 1; ACDLPFCBLOCK = 2; ACSYNCBLOCK = 3
                     

myDir = r"C:\Users\mslip\OneDrive\Documents\MATLAB\tacs-social-norms\experiments-master\Matt\fairness\output"
os.chdir(myDir)

df = pd.read_csv("ben_pilot_data.tsv", sep="\t")   

allConditionPermutation = []

# Initialize all uniqueConditionPermutations
for i in range(len(locations)):
    for j in range(len(partnerTypes)):    
        for k in range(len(framingTypes)):
            for l in range(len(offerTypes)):
                allConditionPermutation.append(
                        conditionPermutation(locations[i],partnerTypes[j],
                                             framingTypes[k],offerTypes[l]))   
# Populate allConditionPermutations with data row by row
for row in df.itertuples():
    if getattr(row, "StimulationCondition") == ACTPJBLOCK: # 1
        location = "rTPJ"
    elif getattr(row, "StimulationCondition") == ACDLPFCBLOCK: # 2
        location = "rDLPFC"
    elif getattr(row, "StimulationCondition") == ACSYNCBLOCK: # 3
        location = "rTPJ + rDLPFC"
    
    if getattr(row, "PartnerType") == "Rating 5/5": 
        partnerType = "5/5"
    elif getattr(row, "PartnerType") == "Rating: 3/5": 
        partnerType = "3/5"
    else: # No rating
        partnerType = "None"
        
    offerType = getattr(row, "OfferType")
    playerChoice = getattr(row, "PlayerChoice")
    
    
    for i in range(0,len(allConditionPermutation)):
        if (allConditionPermutation[i].location == location 
                and allConditionPermutation[i].partnerType == partnerType
                and allConditionPermutation[i].offerType == offerType):
            if (playerChoice == "Accept"):
                allConditionPermutation[i].rejected.append(0)
            elif (playerChoice == "Reject"):
                allConditionPermutation[i].rejected.append(1)

highRejects = []
lowRejects = []
noneRejects  = []
for i in range(0,len(allConditionPermutation)):
    if (allConditionPermutation[i].partnerType == "5/5"
            and allConditionPermutation[i].offerType != 'Keep $5, Give $5'):
        highRejects = highRejects + allConditionPermutation[i].rejected
    elif (allConditionPermutation[i].partnerType == "3/5"
            and allConditionPermutation[i].offerType != 'Keep $5, Give $5'):
        lowRejects = lowRejects + allConditionPermutation[i].rejected
    elif (allConditionPermutation[i].partnerType == "None"
            and allConditionPermutation[i].offerType != 'Keep $5, Give $5'):
        noneRejects = noneRejects + allConditionPermutation[i].rejected


highRejects1  = np.array(highRejects)
lowRejects1   = np.array(lowRejects)
noneRejects1  = np.array(noneRejects)

high_mean = np.mean(highRejects1)     
low_mean  = np.mean(lowRejects1) 
none_mean = np.mean(noneRejects1)

high_std = np.std(highRejects1)
low_std  = np.std(lowRejects1)
none_std = np.std(noneRejects1)

high_std_error = high_std / np.sqrt(8)
medium_std_error = low_std / np.sqrt(8)
low_std_error = none_std / np.sqrt(8)

means = [high_mean,low_mean,none_mean]
std_errors = [high_std_error,medium_std_error,low_std_error]

print(means)
print(std_errors)

