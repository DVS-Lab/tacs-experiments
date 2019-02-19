# -*- coding: utf-8 -*-
"""
Created on Sun Nov 11 10:38:14 2018

@author: mslip
"""
import os
import csv

pathName = os.getcwd()

numFiles = []
fileNames = os.listdir(pathName)

for i in numFiles:
    file = open(os.path.join(pathName, i), "rU")
    reader = csv.reader(file, delimiter='\t')
    for row in reader:
        for column in row:
            print(column)
            if column=="SPECIFIC VALUE":
                #do stuff