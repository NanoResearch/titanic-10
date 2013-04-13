library(plyr)

train <- read.csv("C:/Dev/titanic/data/train.csv", stringsAsFactors = FALSE)  # 891 obs
test <- read.csv("C:/Dev/titanic/data/test.csv", stringsAsFactors = FALSE)    # 418 obs


# Create a survived variable in the test data set
# Set "0" (did not survive) as the default value
test$survived <- 0

#convert all categorical variables to factors 

train$survived <- factor(train$survived)
train$sex <- factor(train$sex)
train$pclass <- factor(train$pclass)
#train$parch <- factor(train$parch)
train$sibsp <- factor(train$sibsp)
test$survived <- factor(test$survived)
test$sex <- factor(test$sex)
test$pclass <- factor(test$pclass)
test$embarked <- factor(test$embarked)
#test$parch <- factor(test$parch)
test$sibsp <- factor(test$sibsp)


#this is some clever code I stole from https://github.com/mattdelhey/kaggle-titanic/blob/master/1-clean.R
#join test and train, use linear regression to build a model to predict age and fare for misssing instances.

# Combine the data sets for age/fare modeling
full <- join(test, train, type = "full")

# Multiple Imputation
#library(mi)
#inf <- mi.info(train)
#imp <- mi(train, info = inf, check.coef.convergence = FALSE, n.imp = 2, n.iter = 6, seed = 111)
#plot(imp)

# Create LM models for predicting missing values in AGE and FARE
age.mod <- lm(age ~ pclass + sex +
                sibsp + parch + fare, data = full)
fare.mod<- lm(fare ~ pclass + sex +
                sibsp + parch + age, data = full)

# Replace missing values in AGE and FARE with prediction
train$age[is.na(train$age)] <- predict(age.mod, train)[is.na(train$age)]
test$age[is.na(test$age)] <- predict(age.mod, test)[is.na(test$age)]
test$fare[is.na(test$fare)] <- predict(fare.mod, test)[is.na(test$fare)]


# Replace missing values in embarked with most popular
train$embarked[train$embarked == ""] <- "S"
train$embarked <- factor(train$embarked)

#previous experience tells me fare group categories might be helpful.
#before using this, AUC was about .76 according to kaggle
#> summary(train$fare)
#Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#0.00    7.91   14.45   32.20   31.00  512.30 
#fare groups will be 1= 0-7.91  2 = 7.92 - 30.99  3 = 31+
train$pricegroup[train$fare >= 31] <- 3
train$pricegroup[train$fare <= 30.99] <- 2
train$pricegroup[train$fare <= 7.91] <- 1

#same with test
test$pricegroup[test$fare >= 31] <- 3
test$pricegroup[test$fare <= 30.99] <- 2
test$pricegroup[test$fare <= 7.91] <- 1

#and factorize
test$pricegroup <- factor(test$pricegroup)
train$pricegroup <- factor(train$pricegroup)


# Save files as RData in order to preserve data structures
# Open .RData with load()
save("test", file = "C:/Dev/titanic/data/test_clean.RData")
save("train", file = "C:/Dev/titanic/data/train_clean.RData")
