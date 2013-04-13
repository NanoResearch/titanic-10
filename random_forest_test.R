library(randomForest)

load("C:/Dev/titanic/data/train_clean.RData")
load("C:/Dev/titanic/data/test_clean.RData")

train_error <- function(survived_pred) {
  # Check to see which predictions our model gets wrong
  which(train$survived_pred != train$survived)
  
  # Calculate our % accuracy on the TRAIN data set
  ((length(which(train$survived_pred == train$survived))) /
     length(train$survived)) * 100 
}




#rf <- randomForest(survived ~ pclass + sex + age + sibsp + parch + fare + pricegroup,
#                   data=train,
#                   importance=TRUE,
#                   ntree=1000
#                   )

rf <- randomForest(survived ~ sex + age + sibsp + parch + fare,
                   data=train,
                   importance=TRUE,
                   ntree=5000
)


#predict against train to calc error
train$survived_pred <- predict(rf, train)

auc <- train_error(train$survived_pred)
print (auc)

#predict against test
test$survived <- predict(rf, test)

#write out csv submission
write.csv(test, "c:/dev/titanic/data/randomForest-in-r.csv")



