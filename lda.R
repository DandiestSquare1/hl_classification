# Script performs linear discriminant analysis for the formatted csv file.
# The grouping factor is in the first column. It is a symbol of positive swing (peak), 
# negative swing (peak) or trend continuation.

install.packages("sda")
install.packages("MASS")
install.packages("entropy")
install.packages("corpcor")
install.packages("fdrtool")
install.packages("lda")

library(sda)
library(MASS)
library(entropy)
library(corpcor)
library(fdrtool)
library(lda)

# function to hold on
readkey <- function()
{
  cat ("\nPress [enter] to continue...")
  line <- readline()
}

# Home directory 
homedir <-"C://Users//Neal//Documents//R"
setwd(homedir)

# Choosing the file to open 
file.to.open <- file.choose()

# Data frame from the chosen file
raw.data <- read.csv(file.to.open, header = T)

# Watch the import results. 
# Some data manipulation needed to get the correct values
# Problems as data importes as string values
# rowMeans(is.na(data)*1)
# colMeans(is.na(data)*1)

# Some transformations of the raw dataset

data<-raw.data

# Check for missing values
Any.NAs<- sum(colSums(is.na(data)*1))
if (Any.NAs) {
  cat("There are missing values")
  readkey()}

# rowSums(is.na(data)*1)
# char.data<-lapply(data,as.character)
# nr.data<-lapply(data,numeric)


column_names<-names(raw.data)


new_names<-sub(pattern="*.indRange.RightStrength.",".",column_names)
new_names[4:84]=substr(column_names[4:84],1,7)

names(data)<-new_names




data.numeric<-as.data.frame(lapply(data,as.integer))

#peaks<-lapply(subset(data, select=1),as.factor)

#peaks<-data[,1]

train.set<-1:round(2/3*nrow(data.numeric))
ranking.DDA <- sda.ranking(as.matrix(data.numeric[train.set,c(2,4:287)]), data.numeric[train.set,1], diagonal=TRUE)

nr.of.most.relevant<-nrow(ranking.DDA[ranking.DDA[,"lfdr"]<0.01,])
most.relevant=ranking.DDA[1:nr.of.most.relevant,1]

lda_formula<- paste(
  names(data.numeric[1]),"~",
  paste(names(most.relevant),collapse=" + "),
  sep=" "  )

# lda.results<-lda(formula = lda_formula, data=data)

lda.results<-lda(data.numeric[,names(most.relevant)]*1,grouping=data.numeric[,1],subset = train.set)

swing.predictions1<-predict(lda.results, data.numeric[train.set,names(most.relevant)]*1)
swing.predictions2<-predict(lda.results, data.numeric[-train.set,names(most.relevant)]*1)

train.correct<-sum((swing.predictions1$class== data.numeric[train.set,1])*1)
train.incorrect<-length(train.set)-train.correct
test.correct<-sum((swing.predictions2$class== data.numeric[-train.set,1])*1)
test.incorrect<-nrow(data.numeric)-length(train.set)-test.correct
train.correctness<-train.correct/length(train.set)
test.correctness<-test.correct/(nrow(data.numeric)-length(train.set))
cat(paste0("\nCorrect classifications in the traing set: ",format(train.correctness*100,digits=4),"%\n"))
cat(paste0("Correct classifications in the test set: ",format(test.correctness*100,digits=4),"%\n"))

# show column names and their ordinality sorted by "importance" 
ranking.DDA

# show "important" column names and their ordinality 
most.relevant 

# show avg. values for each "important" column/variable for all predicted classes 
lda.results