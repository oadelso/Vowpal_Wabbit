#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 27 07:46:15 2017

@author: oseasa
"""
import sys
import re
from datetime import datetime

# input comes from STDIN
def read_trump_data(file,separator='\t'):
    for line in file:
        yield line.rstrip().split(separator,2)



def main(separator='\t'):  
   #replicate
   data=read_trump_data(sys.stdin,separator=separator)
   
   for line in data:

        #Start with assigning the label per tweet
        #need to be 1 and -1 for logit regression
        if line[0] == 'Staff':
            vw_label = '-1'
            label = "'Staff"
        elif line[0] == 'Trump':
            vw_label = '1'
            label = "'Trump"
        else:
            continue 
        
        #get time information, in our case, we will focus on:
            #1) hour, and
            #2) quarter of the hour
        time = datetime.strptime(line[1], "%Y-%m-%d %H:%M:%S")
        hour = time.hour
        
         #report which quarter of the hour the tweet was written
        minute=int(time.minute)
        quarter=1
        
        if minute>=45:
            quarter=4
        elif minute>=30:
            quarter=3
        elif minute>=15:
            quarter=2
              
        # Get the percetage that words like 'my' 'mine' and 'i; make up
        #of the entire text in the tweet
        number_words = len(line[2].strip().split(' '))
        #lower case
        count_my=len(re.findall(' my ',line[2].lower()))
        count_mine=len(re.findall(' mine ',line[2].lower()))
        count_i=len(re.findall(' i ',line[2].lower()))
        ratio=(count_i+count_mine+count_my)/number_words
        #provide lenght of tweet in characters
        characters = len(line[2])

         #boolean for link present in tweet or not
        boolean = '0'
        if "http" in line[2]:
            boolean = '1'
        
        #exclamation count
        exclamation_count=len(re.findall("!",line[2]))
        
            
        #output in vw-friendly format
        print(vw_label + ' ' + label + ' |tweet_content ' + line[2].replace(':', '') + \
        ' |time_info ' + str(hour) +' ' +str(quarter)+ ' |ratio ' + str(ratio) + \
        ' length:' + str(characters) + ' exclamation_count:' + str(exclamation_count)+ \
        ' boolean:' +boolean)


if __name__ == "__main__":
    main()
