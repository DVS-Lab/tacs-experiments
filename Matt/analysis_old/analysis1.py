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
                 framingType=None,offerType=None,conformity=None):
        self.location    = location
        self.herdType    = herdType
        self.framingType = framingType
        self.offerType   = offerType
        self.conformity  = conformity

locations = ['rTPJ','rDLPFC']
herdTypes = ['High','Medium','Low']
framingTypes = ['Accepted','Rejected']
offerTypes = ['Keep $9, Give $1','Keep $8, Give $2','Keep $7, Give $3',
              'Keep $6, Give $4','Keep $5, Give $5']
allConditionPermutation = []

# Initialize all uniqueConditionPermutations
for i in range(len(locations)):
    for j in range(len(herdTypes)):    
        for k in range(len(framingTypes)):
            for l in range(len(offerTypes)):
                allConditionPermutation.append(
                        conditionPermutation(locations[i],herdTypes[j],
                                             framingTypes[k],offerTypes[l],0))                        

ACTPJBLOCK = 1; ACDLPFCBLOCK = 2

myDir = r"C:\Users\mslip\OneDrive\Documents\MATLAB\tacs-social-norms\experiments-master\Matt\herding\output"
os.chdir(myDir)
df = pd.read_csv("014_results.tsv", sep="\t")   
  
# Populate allConditionPermutations with data row by row
for row in df.itertuples():
    if getattr(row, "StimulationCondition") == ACTPJBLOCK:
            location = "rTPJ"
    elif getattr(row, "StimulationCondition") == ACDLPFCBLOCK:
        location = "rDLPFC"
    
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
    
    playerChoice = getattr(row, "PlayerChoice")
    
    
    for i in range(0,len(allConditionPermutation)):
        if (allConditionPermutation[i].location == location 
                and allConditionPermutation[i].herdType == herdType
                and allConditionPermutation[i].framingType == framingType
                and allConditionPermutation[i].offerType == offerType):
            if (allConditionPermutation[i].framingTypes ==  "Accepted" 
                    and playerChoice == "Accept"):
                allConditionPermutation[i].conformity = 1
            elif (allConditionPermutation[i].framingTypes ==  "Rejected" 
                    and playerChoice == "Reject"):
                allConditionPermutation[i].conformity = 1
            else:
                allConditionPermutation[i].conformity = 0

rTPJconformityValues = 0
rTPJcount = 0
rDLPFCconformityValues = 0
rDLPFCcount = 0
for i in range(0,len(allConditionPermutation)):
    if allConditionPermutation[i].location == "rTPJ":
        rTPJconformityValues += allConditionPermutation[i].conformity
        rTPJcount += 1
    if allConditionPermutation[i].location == "rDLPFC":
        rDLPFCconformityValues += allConditionPermutation[i].conformity
        rDLPFCcount += 1
        
objects = ('rTPJ', 'rDLPFC')

rTPJPercentage         = rTPJconformityValues / rTPJcount
rDLPFCPercentage = rDLPFCconformityValues / rDLPFCcount

# data to plot
n_groups = 2

# create plot
fig, ax = plt.subplots()
index = np.arange(n_groups)
bar_width = 0.35
opacity = 0.8
 
rects1 = plt.bar(index, rTPJPercentage, bar_width,
                 alpha=opacity,
                 color='#9e1c35',
                 label='rTPJ')

rects2 = plt.bar(index + bar_width, rDLPFCconformityValues, bar_width,
                 alpha=opacity,
                 color='R',
                 label='rDLPFC')

plt.xlabel('Condition')
plt.ylabel('Conformity(%)')
plt.title('% of herd decisions mimiced x tACS Stimulation Location')
plt.xticks(index + bar_width, objects)
plt.legend()
plt.tight_layout()
plt.show()
