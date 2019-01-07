# -*- coding: utf-8 -*-
"""
Created on Sun Nov 11 10:38:14 2018

@author: mslip
"""
import os
import csv
import numpy as np
import pandas as pd

pathName = os.getcwd()

numFiles = []
fileNames = os.listdir(pathName)

list_data = []
#write a for loop that will go through each of the file name through globbing and the end result will be the list of dataframes
data = pd.read_csv('023_results.tsv', delimiter='\t')

# Select column (can be A,B,C,D)
col = 'HerdType';

#findL = 0
#replaceL = 1

### 1 - 0-33, 2 - 34-66, 3 - 67-99
## Values to find and their replacements
#findL = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]
#replaceL = np.ones(34)
## Find and replace values in the selected column
#data[col] = data[col].replace(findL, replaceL)
## Values to find and their replacements
#findL = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33] + 33*np.ones(33)
#replaceL = 2*np.ones(33)
## Find and replace values in the selected column
#data[col] = data[col].replace(findL, replaceL)
## Values to find and their replacements
#findL = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33] + 66*np.ones(33)
#replaceL = 3*np.ones(33)
## Find and replace values in the selected column
#data[col] = data[col].replace(findL, replaceL)

## 1 - 0-49, 2 - 50-74, 3 - 75-99 ##
# Values to find and their replacements
findL = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
replaceL = np.ones(25)
# Find and replace values in the selected column
data[col] = data[col].replace(findL, replaceL)
# Values to find and their replacements
findL = [25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49]
replaceL = np.ones(25)
# Find and replace values in the selected column
data[col] = data[col].replace(findL, replaceL)
# Values to find and their replacements
findL = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] + 50*np.ones(25)
replaceL = 2*np.ones(25)
# Find and replace values in the selected column
data[col] = data[col].replace(findL, replaceL)
# Values to find and their replacements
findL = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] + 75*np.ones(25)
replaceL = 3*np.ones(25)
# Find and replace values in the selected column
data[col] = data[col].replace(findL, replaceL)

data.to_csv('023_results_herd_spilt2.tsv', sep='\t', index=False)
