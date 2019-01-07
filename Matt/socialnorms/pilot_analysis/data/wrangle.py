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
data = pd.read_csv('006_results.tsv', delimiter='\t')

# Select column (can be A,B,C,D)


col = 'GameType';
# Values to find and their replacements
findL = ['Dictator','Ultimatum']
replaceL = [1,2]
# Find and replace values in the selected column
data[col] = data[col].replace(findL, replaceL)

col = 'OpponentType';
# Values to find and their replacements
findL = ['Person','PC']
replaceL = [1,2]
# Find and replace values in the selected column
data[col] = data[col].replace(findL, replaceL)

data.to_csv('006_results.tsv', sep='\t', index=False)
