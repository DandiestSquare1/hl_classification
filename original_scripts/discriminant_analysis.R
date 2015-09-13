# Script responsible for discriminant analysis


train.set<-1:round(train.set.fraction*No.of.rows)
ranking.DDA <- sda.ranking(as.matrix(data.numeric[train.set,2:No.of.columns]), 
                           data.numeric[train.set,1], diagonal=TRUE)
nr.of.most.relevant<-nrow(ranking.DDA[ranking.DDA[,"lfdr"]<max.FDR,])
if (nr.of.most.relevant) {
most.relevant=ranking.DDA[1:nr.of.most.relevant,1]
lda_formula<- paste(
  names(data.numeric[1]),"~",
  paste(names(most.relevant),collapse=" + "),
  sep=" "  )
lda.results<-lda(data.numeric[,names(most.relevant)]*1,
                 grouping=data.numeric[,1],subset = train.set)
}else{
  cat("\nThere are no relevant variables according to the set criteria:\n")
  cat("Maximum False Discovery Rate = ",max.FDR,"\n")
  cat("Calculations stopped.\n")
  cat("You can try to increase max.FDR.\n")
  readkey()
}