#! /usr/bin/env Rscript
library(rmr2)
library(randomForest)

acres <-10
number.trees <- 10
model.formula <- survived ~ pclass + sex + age + sibsp + parch + fare
column.names <- c("survived","pclass","sex","age","sibsp","parch","fare")

titanic.input.format = 
  make.input.format(
  	"csv",
  	sep=",",
  	quote="\"",
  	row.names=NULL,
  	col.names=column.names,
  	fill=TRUE,
  	na.strings=c("NA"),
  	colClasses=c(
  					survived="factor",
  					pclass="factor",
  					sex="factor",
  					age="numeric",
  					sibsp="factor",
  					parch="factor",
  					fare="numeric"))
  					




#mapper function
mapper <- function (k,v) {
  keyval(1:acres, v)
}

reducer <- function (k,v) {
  rf <- randomForest(formula=model.formula,
                   data=v,
  			   na.action=na.roughfix,
                   ntree=number.trees,
  			   do.trace=TRUE
  			   )
  
  keyval(k,list(forest=rf))
}
mapreduce(input="train_clean.csv",
               input.format=titanic.input.format,
               map=mapper,
               reduce=reducer,
  		   output.format="native",
  		   output="titanic-out")
