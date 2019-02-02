# -*- coding: utf-8 -*-
"""
Stimulation Bar Plot - social-norms - Participant 005 
"""
import os
import csv
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
    def __init__(self,location=None,stimType=None,partnerType=None):
        self.location               = location
        self.stimType               = stimType
        self.partnerType            = partnerType
        self.punishmentChoices      = []
        self.nonPunishmentChoices   = []
        self.conformities           = []
        self.nonPunishmentCount     = 0
        self.punishmentCount        = 0
        self.punishmentTransfers    = []
        self.nonPunishmentTransfers = []


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
                                         opponentTypes[k]))                        
allConditionPermutation.append(
                    conditionPermutation('Sync','tACS','Person'))
allConditionPermutation.append(
                    conditionPermutation('Sync','tACS','PC'))
allConditionPermutation.append(
                    conditionPermutation('n/a','n/a','Person'))
allConditionPermutation.append( 
                    conditionPermutation('n/a','n/a','PC'))

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
    # Append punishment and nonpunishment transfers to each condition
    for i in range(0,len(allConditionPermutation)):
        if (allConditionPermutation[i].location == location 
                and allConditionPermutation[i].stimType == stimType
                and allConditionPermutation[i].partnerType == partnerType):
            if getattr(row, "GameType") == 'Dictator' and getattr(row, "PlayerChoice") >= 0:
                allConditionPermutation[i].nonPunishmentChoices.append(getattr(row, "PlayerChoice"))
                break
            elif getattr(row, "GameType") == 'Ultimatum' and getattr(row, "PlayerChoice") >= 0:
                allConditionPermutation[i].punishmentChoices.append(getattr(row, "PlayerChoice"))
                break
    
tACS_sync_punishment_transfers = []
tACS_sync_non_punishment_transfers = []
sham_punishment_transfers = []
sham_non_punishment_transfers = []
for i in range(0,len(allConditionPermutation)):
    if (allConditionPermutation[i].stimType == "tACS"
            and allConditionPermutation[i].location == "Sync"):
        tACS_sync_punishment_transfers = tACS_sync_punishment_transfers + allConditionPermutation[i].punishmentChoices
        tACS_sync_non_punishment_transfers = tACS_sync_non_punishment_transfers + allConditionPermutation[i].nonPunishmentChoices
    elif (allConditionPermutation[i].stimType == "n/a"
            and allConditionPermutation[i].location == "n/a"):
        sham_punishment_transfers = sham_punishment_transfers + allConditionPermutation[i].punishmentChoices
        sham_non_punishment_transfers = sham_non_punishment_transfers + allConditionPermutation[i].nonPunishmentChoices

# Enter in the raw data
tACS_sync_punishment_transfers1       = np.array(tACS_sync_punishment_transfers)
tACS_sync_non_punishment_transfers1   = np.array(tACS_sync_non_punishment_transfers)
sham_punishment_transfers1            = np.array(sham_punishment_transfers)
sham_non_punishment_transfers1        = np.array(sham_non_punishment_transfers)

tACS_sync_punishment_mean = np.mean(tACS_sync_punishment_transfers1)
tACS_sync_non_punishment_mean = np.mean(tACS_sync_non_punishment_transfers1)
sham_punishment_mean = np.mean(sham_punishment_transfers1)
sham_non_punishment_mean = np.mean(sham_non_punishment_transfers1)

tACS_sync_punishment_std = np.std(tACS_sync_punishment_transfers1)
tACS_sync_non_punishment_std = np.std(tACS_sync_non_punishment_transfers1)
sham_punishment_std = np.std(sham_punishment_transfers1)
sham_non_punishment_std = np.std(sham_non_punishment_transfers1)

tACS_sync_punishment_std_error = tACS_sync_punishment_std         / 3
tACS_sync_non_punishment_std_error = tACS_sync_non_punishment_std / 3
sham_punishment_std_error = sham_punishment_std                   / 3
sham_non_punishment_std_error = sham_non_punishment_std           / 3

means = [tACS_sync_punishment_mean,sham_punishment_mean,
         tACS_sync_non_punishment_mean, sham_non_punishment_mean]
std_errors = [tACS_sync_punishment_std_error,sham_punishment_std_error,
             tACS_sync_non_punishment_std_error,sham_non_punishment_std_error]

print(means)
print(std_errors)








