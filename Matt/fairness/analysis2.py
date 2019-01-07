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
                 framingType=None,offerType=None,accepted=None,rejected=None):
        self.location    = location
        self.partnerType = partnerType
        self.framingType = framingType
        self.offerType   = offerType
        self.accepted    = accepted
        self.rejected    = rejected

locations = ['rTPJ','rDLPFC','rTPJ + rDLPFC']
partnerTypes = ['5/5','3/5','None']
framingTypes = ['Accepted','Rejected']
offerTypes = ['Keep $9, Give $1','Keep $8, Give $2','Keep $7, Give $3',
              'Keep $6, Give $4','Keep $5, Give $5']
ACTPJBLOCK = 1; ACDLPFCBLOCK = 2; ACSYNCBLOCK = 3
                      

myDir = r"C:\Users\mslip\OneDrive\Documents\MATLAB\tacs-social-norms\experiments-master\Matt\fairness\output"
os.chdir(myDir)

def getSubjectData(fileName):
    df = pd.read_csv(fileName, sep="\t")   
    
    allConditionPermutation = []
    
    # Initialize all uniqueConditionPermutations
    for i in range(len(locations)):
        for j in range(len(partnerTypes)):    
            for k in range(len(framingTypes)):
                for l in range(len(offerTypes)):
                    allConditionPermutation.append(
                            conditionPermutation(locations[i],partnerTypes[j],
                                                 framingTypes[k],offerTypes[l],0,0))  
    
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
                    allConditionPermutation[i].accepted = 1
                    allConditionPermutation[i].rejected = 0
                elif (playerChoice == "Reject"):
                    allConditionPermutation[i].accepted = 0
                    allConditionPermutation[i].rejected = 1
    
    highAccepted    = 0; highCount = 0
    mediumAccepted  = 0; mediumCount = 0
    noneAccepted    = 0; noneCount = 0
    highRejected    = 0;
    mediumRejected  = 0;
    noneRejected    = 0;
    for i in range(0,len(allConditionPermutation)):
        if (allConditionPermutation[i].partnerType == "5/5"
                and allConditionPermutation[i].offerType != 'Keep $5, Give $5'):
            if (allConditionPermutation[i].accepted == 1):
                highAccepted += allConditionPermutation[i].accepted
                highCount += 1
            else:
                highRejected += allConditionPermutation[i].rejected
                highCount += 1
        elif (allConditionPermutation[i].partnerType == "3/5"
                and allConditionPermutation[i].offerType != 'Keep $5, Give $5'):
            if (allConditionPermutation[i].accepted == 1):
                mediumAccepted += allConditionPermutation[i].accepted
                mediumCount += 1
            else:
                mediumRejected += allConditionPermutation[i].rejected
                mediumCount += 1
        elif (allConditionPermutation[i].partnerType == "None"
                and allConditionPermutation[i].offerType != 'Keep $5, Give $5'):
            if (allConditionPermutation[i].accepted == 1):
                noneAccepted += allConditionPermutation[i].accepted
                noneCount += 1
            else:
                noneRejected += allConditionPermutation[i].rejected
                noneCount += 1
    
    
    highPercentRejected  = (highRejected   / highCount)  * 100
    mediumPercentRejected = (mediumRejected / mediumCount) * 100
    nonePercentRejected   = (noneRejected   / noneCount)  * 100
    return [highPercentRejected,mediumPercentRejected,nonePercentRejected]


files = ["006_results.tsv","009_results.tsv","010_results.tsv","011_results.tsv",
         "013_results.tsv","014_results.tsv","015_results.tsv","016_results.tsv",]
netRTPJPercentRejected = 0
netRDLPFCPercentRejected = 0
netSyncPercentRejected = 0
for file in files:
    subjectData = getSubjectData(file)
    netRTPJPercentRejected   += subjectData[0]
    netRDLPFCPercentRejected += subjectData[1]
    netSyncPercentRejected   += subjectData[2]
    
averageRTPJPercentageRejected   = netRTPJPercentRejected   / len(files)
averageRDLPFCPercentageRejected = netRDLPFCPercentRejected / len(files)
averageSyncPercentRejected  = netSyncPercentRejected   / len(files)



values = [averageRTPJPercentageRejected,averageRDLPFCPercentageRejected,averageSyncPercentRejected]
# data to plot
# plot
objects = ('5/5', '3/5', 'None')

plt.rcParams.update({'font.size': 18})
plt.bar(objects,values, color='#9e1c35')
plt.legend()
plt.xlabel('Partner Rating')
plt.ylabel('Rejected Unfair Offers(%)')

plt.title('Percentage of Unfair Offers Rejected with Respect to Partner Rating')
plt.show()

## data to plot
#n_groups = 3
#
## create plot
#fig, ax = plt.subplots()
#index = np.arange(n_groups)
#bar_width = 0.35
#opacity = 0.8
# 
#rects1 = plt.bar(index, rTPJvalues, bar_width,
#                 alpha=opacity,
#                 color='#9e1c35',
#                 label='Punishment')
# 
#rects2 = plt.bar(index + bar_width, rDLPFCvalues, bar_width,
#                 alpha=opacity,
#                 color='#939393',
#                 label='Baseline')
#
#plt.xlabel('Condition')
#plt.ylabel('Transfers')
#plt.title('Transfers x Condition')
#plt.xticks(index + bar_width, objects)
#plt.legend()
#plt.tight_layout()
#plt.figure(figsize=(5,15))
#plt.show()




