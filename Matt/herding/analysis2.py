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
    def __init__(self,location=None,herdType=None,
                 framingType=None,offerType=None):
        self.location    = location
        self.herdType    = herdType
        self.framingType = framingType
        self.offerType   = offerType
        self.conformities  = []

locations = ['rTPJ','rDLPFC']
herdTypes = ['High','Medium','Low']
framingTypes = ['Accepted','Rejected']
offerTypes = ['Keep $9, Give $1','Keep $8, Give $2','Keep $7, Give $3',
              'Keep $6, Give $4','Keep $5, Give $5']
ACTPJBLOCK = 1; ACDLPFCBLOCK = 2
myDir = r"C:\Users\mslip\OneDrive\Documents\MATLAB\tacs-social-norms\experiments-master\Matt\herding\output"
os.chdir(myDir)

allConditionPermutation = []
                      
df = pd.read_csv("matt_pilot_data.tsv", sep="\t")   

allConditionPermutation = []
          # Initialize all uniqueConditionPermutations
for i in range(len(locations)):
    for j in range(len(herdTypes)):    
        for k in range(len(framingTypes)):
            for l in range(len(offerTypes)):
                allConditionPermutation.append(
                        conditionPermutation(locations[i],herdTypes[j],
                                             framingTypes[k],offerTypes[l]))             
# Populate allConditionPermutations with data row by row
for row in df.itertuples():
    if getattr(row, "StimulationCondition") == ACTPJBLOCK:
        location = "rTPJ"
    elif getattr(row, "StimulationCondition") == ACDLPFCBLOCK:
        location = "rDLPFC"
    else:
        continue
    
    if getattr(row, "HerdType") < 34: # 0-33%
        herdType = "Low"
    elif getattr(row, "HerdType") < 67: # 34-66%
        herdType = "Medium"
    elif getattr(row, "HerdType") < 100: # 67-99%
        herdType = "High"
        
    if getattr(row, "FramingType") == "Accepted":
        framingType = "Accepted"
    elif getattr(row, "FramingType") == "Rejected":
        framingType = "Rejected"
    
    offerType = getattr(row, "OfferType")
    playerChoice = getattr(row, "PlayerChoice")
    
    
    for i in range(0,len(allConditionPermutation)):
        if (allConditionPermutation[i].location == location 
                and allConditionPermutation[i].herdType == herdType
                and allConditionPermutation[i].framingType == framingType
                and allConditionPermutation[i].offerType == offerType):
            if (allConditionPermutation[i].framingType ==  "Accepted" 
                    and playerChoice == "Accept"):
                allConditionPermutation[i].conformities.append(1)
            elif (allConditionPermutation[i].framingType ==  "Rejected" 
                    and playerChoice == "Reject"):
                allConditionPermutation[i].conformities.append(1)
            else:
                allConditionPermutation[i].conformities.append(0)

rtpj_low_conformity = []
rdlpfc_low_conformity = []
rtpj_medium_conformity = []
rdlpfc_medium_conformity = []
rtpj_high_conformity = []
rdlpfc_high_conformity = []
for i in range(0,len(allConditionPermutation)):
    if (allConditionPermutation[i].location == "rTPJ"
            and allConditionPermutation[i].herdType == "Low"):
        rtpj_low_conformity += allConditionPermutation[i].conformities
    elif (allConditionPermutation[i].location == "rTPJ"
          and allConditionPermutation[i].herdType == "Medium"):
        rtpj_medium_conformity += allConditionPermutation[i].conformities
    elif (allConditionPermutation[i].location == "rTPJ"
          and allConditionPermutation[i].herdType == "High"):
        rtpj_high_conformity += allConditionPermutation[i].conformities
    elif (allConditionPermutation[i].location == "rDLPFC"
            and allConditionPermutation[i].herdType == "Low"):
        rdlpfc_low_conformity += allConditionPermutation[i].conformities
    elif (allConditionPermutation[i].location == "rDLPFC"
          and allConditionPermutation[i].herdType == "Medium"):
        rdlpfc_medium_conformity += allConditionPermutation[i].conformities
    elif (allConditionPermutation[i].location == "rDLPFC"
          and allConditionPermutation[i].herdType == "High"):
        rdlpfc_high_conformity += allConditionPermutation[i].conformities
    
    
        
rtpj_low_conformity1   = np.array(rtpj_low_conformity)
rdlpfc_low_conformity1 = np.array(rdlpfc_low_conformity)
rtpj_medium_conformity1   = np.array(rtpj_medium_conformity)
rdlpfc_medium_conformity1 = np.array(rdlpfc_medium_conformity)
rtpj_high_conformity1   = np.array(rtpj_high_conformity)
rdlpfc_high_conformity1 = np.array(rdlpfc_high_conformity)

rtpj_low_mean    = np.mean(rtpj_low_conformity1)     
rdlpfc_low_mean  = np.mean(rdlpfc_low_conformity1)
rtpj_medium_mean    = np.mean(rtpj_medium_conformity1)     
rdlpfc_medium_mean  = np.mean(rdlpfc_medium_conformity1) 
rtpj_high_mean    = np.mean(rtpj_high_conformity1)     
rdlpfc_high_mean  = np.mean(rdlpfc_high_conformity1) 

rtpj_low_std    = np.std(rtpj_low_conformity1)     
rdlpfc_low_std  = np.std(rdlpfc_low_conformity1)
rtpj_medium_std    = np.std(rtpj_medium_conformity1)     
rdlpfc_medium_std  = np.std(rdlpfc_medium_conformity1) 
rtpj_high_std    = np.std(rtpj_high_conformity1)     
rdlpfc_high_std  = np.std(rdlpfc_high_conformity1) 

rtpj_low_std_error   = rtpj_low_std / np.sqrt(8)
rdlpfc_low_std_error = rdlpfc_low_std / np.sqrt(8)
rtpj_medium_std_error   = rtpj_medium_std / np.sqrt(8)
rdlpfc_medium_std_error = rdlpfc_medium_std / np.sqrt(8)
rtpj_high_std_error   = rtpj_high_std / np.sqrt(8)
rdlpfc_high_std_error = rdlpfc_high_std / np.sqrt(8)

means = [rtpj_low_mean,rtpj_medium_mean,rtpj_high_mean,rdlpfc_low_mean,
         rdlpfc_medium_mean,rdlpfc_high_mean]
std_errors = [rtpj_low_std_error,rtpj_medium_std_error,rtpj_high_std_error,
              rdlpfc_low_std_error,rdlpfc_medium_std_error,rdlpfc_high_std_error]

print(means)
print(std_errors)
