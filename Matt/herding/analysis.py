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

rTPJconformityValues = []
rDLPFCconformityValues = []
for i in range(0,len(allConditionPermutation)):
    if allConditionPermutation[i].location == "rTPJ":
        rTPJconformityValues += allConditionPermutation[i].conformities
    if allConditionPermutation[i].location == "rDLPFC":
        rDLPFCconformityValues += allConditionPermutation[i].conformities
        
rTPJconformityValues1   = np.array(rTPJconformityValues)
rDLPFCconformityValues1 = np.array(rDLPFCconformityValues)

rTPJconformity_mean    = np.mean(rTPJconformityValues1)     
rDLPFCconformity_mean  = np.mean(rDLPFCconformityValues1) 

rTPJconformity_std    = np.std(rTPJconformityValues1)     
rDLPFCconformity_std  = np.std(rDLPFCconformityValues1) 

rTPJconformity_std_error   = rTPJconformity_std / np.sqrt(8)
rDLPFCconformity_std_error = rDLPFCconformity_std / np.sqrt(8)

means = [rTPJconformity_mean,rDLPFCconformity_mean]
std_errors = [rTPJconformity_std_error,rDLPFCconformity_std_error]

print(means)
print(std_errors)
