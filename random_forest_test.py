'''
Created on Apr 10, 2013

@author: Mike Bernico
'''
from sklearn.ensemble import RandomForestClassifier
import csv as csv 
import numpy as np



#open the training train_data set
csv_train_object = csv.reader(open('./data/train.csv', 'rb')) 
header = csv_train_object.next()

#put the file object rows into a list.   Then convert that list to a numpy array
#the array will be [rowsxcolumns] big
train_data=[]
for row in csv_train_object:
    train_data.append(row)
train_data = np.array(train_data)

#open the test train_data set
csv_test_object = csv.reader(open('./data/test.csv', 'rb')) 
header = csv_test_object.next()

#put the file object rows into a list.   Then convert that list to a numpy array
#the array will be [rowsxcolumns] big
test_data=[]
for row in csv_test_object:
    test_data.append(row)
test_data = np.array(test_data)



#randForrest needs floats, so the next step is to float all the train_data and fill missing values

#header is 
#survived    pclass    name    sex    age    sibsp    parch    ticket    fare    cabin    embarked

#example
#for any fare greater than 40, set it to 40
#train_data[train_data[0::,7].astype(np.float) >= fare_ceiling, 7] = fare_ceiling-1.0

#find empty survived and make them 0
train_data[train_data[0::,0] == "",0] = "0"

#find empty pclass and make them 3 (median)
train_data[train_data[0::,1] == "",1] = "3"

#for name we're going to set it to 0 for everyone, since we can't float it.  
#a cleaner way to do this would be to just delete it, but the tutorial says 0 it.
train_data[0::,2] = "0"

#gender  1 = female 2=male  (female is first, very pc of me)  default to female
#future improvement would be check if the survived.  if so, 75% they are female....
train_data[train_data[0::,3] == "",3] = "1"
train_data[train_data[0::,3] == "female",3] = "1"
train_data[train_data[0::,3] == "male",3] = "2"


#find empty ages and fill them with the median age "28"
train_data[train_data[0::,4] == "",4] = "28"

#number of kids/spouses.   Set to 0 (median) if empty
train_data[train_data[0::,5] == "",5] = "0"

#number of parch, median 0
train_data[train_data[0::,6] == "",6] = "0"

#ticket number.   Very dirty train_data, mostly ints, some ascii.   I'll fix this later, 0ing for now
train_data[0::,7] = "0"

#fare
#median is 14.4
#future improvement, this could be estimated based on passenger class
train_data[train_data[0::,8] == "",8] = "14.4"

#cabin
#0ing all these out.   A Better way to do this would be to convert to number categories based on boat geography
#figuring out the titanics floor plan is beyond the scope of my interest at this point
train_data[0::,9] = "0"

#embarked
#options are Cherbourg, Southamption and Queenstown  as CSQ.  I'll make them 1,2,3  0 if empty
train_data[train_data[0::,10] == "",10] = "0"
train_data[train_data[0::,10] == "C",10] = "1"
train_data[train_data[0::,10] == "S",10] = "2"
train_data[train_data[0::,10] == "Q",10] = "3"

#convert everything to floats

train_data[0::,0::].astype(np.float)

#at this point it's all floating and filled





#n_estimators = trees in forest
#everything else is default for now, but for more info see http://scikit-learn.org/dev/modules/generated/sklearn.ensemble.RandomForestClassifier.html
Forest = RandomForestClassifier(n_estimators = 100)

#this is the actual training step.   First input is numpy array of the train_data  Second Argument is the 'answer'
Forest = Forest.fit(train_data[0::,1::],train_data[0::,0])

#so, at this point we have a model, now lets run test against the model and predict.


#format test data, as above.  
#header is #header is 
#pclass    name    sex    age    sibsp    parch    ticket    fare    cabin    embarked


#find empty pclass and make them 3 (median)
test_data[test_data[0::,0] == "",0] = "3"

#for name we're going to set it to 0 for everyone, since we can't float it.  
#a cleaner way to do this would be to just delete it, but the tutorial says 0 it.
test_data[0::,1] = "0"

#gender  1 = female 2=male  (female is first, very pc of me)  default to female
#future improvement would be check if the survived.  if so, 75% they are female....
test_data[test_data[0::,2] == "",2] = "1"
test_data[test_data[0::,2] == "female",2] = "1"
test_data[test_data[0::,2] == "male",2] = "2"


#find empty ages and fill them with the median age "28"
test_data[test_data[0::,3] == "",3] = "28"

#number of kids/spouses.   Set to 0 (median) if empty
test_data[test_data[0::,4] == "",4] = "0"

#number of parch, median 0
test_data[test_data[0::,5] == "",5] = "0"

#ticket number.   Very dirty test_data, mostly ints, some ascii.   I'll fix this later, 0ing for now
test_data[0::,6] = "0"

#fare
#median is 14.4
#future improvement, this could be estimated based on passenger class
test_data[test_data[0::,7] == "",7] = "14.4"

#cabin
#0ing all these out.   A Better way to do this would be to convert to number categories based on boat geography
#figuring out the titanics floor plan is beyond the scope of my interest at this point
test_data[0::,8] = "0"

#embarked
#options are Cherbourg, Southamption and Queenstown  as CSQ.  I'll make them 1,2,3  0 if empty
test_data[test_data[0::,9] == "",9] = "0"
test_data[test_data[0::,9] == "C",9] = "1"
test_data[test_data[0::,9] == "S",9] = "2"
test_data[test_data[0::,9] == "Q",9] = "3"

#convert everything to floats

test_data[0::,0::].astype(np.float)

#predict test_data
output = Forest.predict(test_data)

output.tolist()

open_file_object = csv.writer(open("./data/randomforestoutput.csv", "wb"))

for element in output:
    open_file_object.writerow(element)

