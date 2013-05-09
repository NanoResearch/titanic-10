#! /usr/bin/env Rscript
options(warn=-1)
sink("/dev/null")

library(rmr2)
library(randomForest)



#rmr.options(backend = "local")


#number of acres to split the forrest into, this corresponds to keyspace / reducers
acres <-2

#number of trees in each forest
number.trees <- 10

#the model that the random forest will use
model.formula <- survived ~ pclass + sex + age + sibsp + parch + fare

#column names for the reducer
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
 mapper <- function(k, v) {
  c.keyval(lapply(1:acres, function(idx) { keyval(idx, v) }))
}


#reduce is called once for each unique map key, so the acres defined above have already done my split work?

reducer <- function (k,v) {
    
  
  #vcount <- nrow(v)
  ##v is going to be a data frame in this case.  
  rf <- randomForest(formula=model.formula,
                   data=v,
  				   ntree=number.trees,
  				   do.trace=FALSE
  				   )
  
  keyval(k, list(forest=rf))
  #keyval(k, vcount)

}







mapreduce(input="train_clean.csv",
               input.format=titanic.input.format,
               map=mapper,
               reduce=reducer,
			   output.format="native",
			   output="titanic-out3")
			   
			   
