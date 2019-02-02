# -*- coding: utf-8 -*-
"""
Stimulation Bar Plot - social-norms - Participant 005 
"""
import os
import pandas as pd
import numpy as np
import seaborn as sb
import matplotlib.pyplot as plt

def find(f, seq):
  """Return first item in sequence where f(item) == True."""
  for item in seq:
    if f(item): 
      return item

class conditionPermutation(object):
    def __init__(self,location=None,stimType=None,partnerType=None,
                 punishmentChoice=None,nonPunishmentChoice=None,conformity=None,
                 nonPunishmentCount=None,punishmentCount=None,punishmentMean=None,
                 nonPunishmentMean=None):
        self.location             = location
        self.stimType             = stimType
        self.partnerType          = partnerType
        self.punishmentChoice     = punishmentChoice
        self.nonPunishmentChoice   = nonPunishmentChoice
        self.conformity           = conformity
        self.nonPunishmentCount    = nonPunishmentCount
        self.punishmentCount      = punishmentCount
        self.punishmentMean    = punishmentMean
        self.nonPunishmentMean = nonPunishmentMean


locations = ['rTPJ','rDLPFC']
stimTypes = ['tACS','tRNS']  
opponentTypes = ['Person','PC']  
allConditionPermutation = []     

# Initialize all uniqueConditionPermutations
for i in range(len(locations)):
    for j in range(len(stimTypes)):    
        for k in range(len(opponentTypes)):
            allConditionPermutation.append(
                    conditionPermutation(locations[i],stimTypes[j],
                                         opponentTypes[k],0,0,0,0,0,0,0))                        
allConditionPermutation.append(
                    conditionPermutation('Sync','tACS','Person',0,0,0,0,0,0,0))
allConditionPermutation.append(
                    conditionPermutation('Sync','tACS','PC',0,0,0,0,0,0,0))
allConditionPermutation.append(
                    conditionPermutation('n/a','n/a','Person',0,0,0,0,0,0,0))
allConditionPermutation.append( 
                    conditionPermutation('n/a','n/a','PC',0,0,0,0,0,0,0))

ACTPJBLOCK = 1; ACDLPFCBLOCK = 2; ACSYNCBLOCK = 3
RNTPJBLOCK = 4; RNDLPFCBLOCK = 5; SHAMBLOCK = 6
stimConditions = [ACTPJBLOCK,ACDLPFCBLOCK,ACSYNCBLOCK,RNTPJBLOCK,RNDLPFCBLOCK,SHAMBLOCK]


myDir = r"C:\Users\mslip\OneDrive\Documents\MATLAB\tacs-social-norms\experiments-master\Matt\socialnorms\output"
os.chdir(myDir)

df = pd.read_csv("lindsey_pilot_data.tsv", sep="\t")  
  
# Populate allConditionPermutations with data row by row
for row in df.itertuples():
    if getattr(row, "Condition") == ACTPJBLOCK:
            location = 'rTPJ';stimType = 'tACS'
    elif getattr(row, "Condition") == ACDLPFCBLOCK:
        location = 'rDLPFC';stimType = 'tACS'
    elif getattr(row, "Condition") == ACSYNCBLOCK:
        location = 'Sync';stimType = 'tACS'
    elif getattr(row, "Condition") == RNTPJBLOCK:
        location = 'rTPJ';stimType = 'tRNS'
    elif getattr(row, "Condition") == RNDLPFCBLOCK:
        location = 'rDLPFC';stimType = 'tRNS'
    elif getattr(row, "Condition") == SHAMBLOCK:
        location = 'n/a';stimType = 'n/a'
    
    partnerType = getattr(row, "OpponentType")
    
    #permutation = find(lambda currentPerm:
    #    currentPerm.location == location & currentPerm.stimTypes == stimType
    #    & currentPerm.partnerType == partnerType, allConditionPermutation)
    
    for i in range(0,len(allConditionPermutation)):
        if (allConditionPermutation[i].location == location 
                and allConditionPermutation[i].stimType == stimType
                and allConditionPermutation[i].partnerType == partnerType):
            if getattr(row, "GameType") == 'Dictator' and getattr(row, "PlayerChoice") >= 0:
                allConditionPermutation[i].nonPunishmentChoice += getattr(row, "PlayerChoice")
                allConditionPermutation[i].nonPunishmentCount += 1
                break
            elif getattr(row, "GameType") == 'Ultimatum' and getattr(row, "PlayerChoice") >= 0:
                allConditionPermutation[i].punishmentChoice += getattr(row, "PlayerChoice")
                allConditionPermutation[i].punishmentCount += 1
                break
    
# Determine the conformity for allConditionPermutations
for i in range(0,len(allConditionPermutation)):
        punishmentMean = allConditionPermutation[i].punishmentChoice / allConditionPermutation[i].punishmentCount
        nonPunishmentMean = allConditionPermutation[i].nonPunishmentChoice / allConditionPermutation[i].nonPunishmentCount
        allConditionPermutation[i].punishmentMean = punishmentMean
        allConditionPermutation[i].nonPunishmentMean = nonPunishmentMean
        allConditionPermutation[i].conformity = punishmentMean - nonPunishmentMean

punishmentTransfers = []
nonPunishmentTransfers = []
for i in range(0,len(allConditionPermutation)):
    if (allConditionPermutation[i].location == "rTPJ"
            and allConditionPermutation[i].stimType == "tACS"):
        punishmentTransfers.append(allConditionPermutation[i].punishmentMean)
        nonPunishmentTransfers.append(allConditionPermutation[i].nonPunishmentMean)

averagePunishmentTransfer = np.mean(punishmentTransfers)
averageNonPunishmentTransfer = np.mean(nonPunishmentTransfers)
# data to plot
n_groups = 1

# create plot
fig, ax = plt.subplots()
index = np.arange(n_groups)
bar_width = 0.15
opacity = 0.8
 
rects1 = plt.bar(index, averagePunishmentTransfer, bar_width,
                 alpha=opacity,
                 color='#9e1c35',
                 label='Punishment')
 
rects2 = plt.bar(index + bar_width, averageNonPunishmentTransfer, bar_width,
                 alpha=opacity,
                 color='#939393',
                 label='Baseline')

plt.xlabel('Stimulation Location')
plt.ylabel('Average Transfer')
plt.title('Average Transfer with Respect to tACS Applied to the rTPJ')
plt.xticks(index + bar_width/2, 'rTPJ tACS')
plt.legend()
plt.tight_layout()
plt.show()
