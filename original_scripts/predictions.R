# Module responsible for generating forecasts and calulation
# the efficiency of classification.


#### Predictions ####
swing.predictions1<-predict(lda.results, data.numeric[train.set,names(most.relevant)]*1)
swing.predictions2<-predict(lda.results, data.numeric[-train.set,names(most.relevant)]*1)

sets<-c("train","test")

#### Overall correctness ####
#overall.corectness<- function(pred1,pred2){
  for (set.nr in 1:2){
    # train.comparison and  test.comparison formula
  eval(parse(text=paste0(sets[set.nr],".comparison<-data.frame(real=data.numeric[",
                         as.integer(3-set.nr*2),"*","train.set,1]*1 , theoretical=swing.predictions",set.nr,"$class)")))
    # train.correct and test.correct formula
  eval(parse(text=paste0(sets[set.nr],".correct<-sum(",sets[set.nr],".comparison[,1]==",
                         sets[set.nr],".comparison[,2])")))  
    # train.incorrect and test.incorrect formula
  eval(parse(text=paste0(sets[set.nr],".incorrect<-No.of.rows*",as.integer(set.nr-1),"+",
                         as.integer(3-set.nr*2),"*length(train.set)-",sets[set.nr],".correct")))  
    # train.correctness and test.correctness formula
  eval(parse(text=paste0(sets[set.nr],".correctness<-",sets[set.nr],".correct/(",
                         sets[set.nr],".correct+",sets[set.nr],".incorrect)"))) 
  }
#}

#### OBSOLETE ####
#overall.corectness(swing.predictions1,swing.predictions2)
#train.comparison<-data.frame(real=data.numeric[train.set,1]*1 , theoretical=swing.predictions1$class)
#test.comparison<-data.frame(real=data.numeric[-train.set,1]*1 , theoretical=swing.predictions2$class)
#train.correct<-sum(train.comparison[,1]== train.comparison[,2])
#train.incorrect<-length(train.set)-train.correct
#test.correct<-sum(test.comparison[,1]== test.comparison[,2])
#test.incorrect<-No.of.rows-length(train.set)-test.correct
#train.correctness<-train.correct/length(train.set)
#test.correctness<-test.correct/(No.of.rows-length(train.set))

#### Details of correctness ####
states<-c("minus1","zero","plus1")
  
for (set.nr in 1:2){
  for (state.nr in 1:3){
    eval(parse(text=paste0(states[state.nr],".",sets[set.nr],"<-",sets[set.nr],".comparison[(",sets[set.nr],".comparison[,1]==",state.nr-2,"|",
                           sets[set.nr],".comparison[,2]==",state.nr-2,"),]")))
    eval(parse(text=paste0(states[state.nr],".check.",sets[set.nr],"<-data.frame(good.signals=sum(",
                           states[state.nr],".",sets[set.nr],"[,1]==",state.nr-2,"&",states[state.nr],".",sets[set.nr],"[,2]==",state.nr-2,
                           "),bad.signals=sum(",states[state.nr],".",sets[set.nr],"[,1]!=",state.nr-2,"&",states[state.nr],".",sets[set.nr],"[,2]==",state.nr-2,
                           "),undiscovered=sum(",states[state.nr],".",sets[set.nr],"[,1]==",state.nr-2,"&",states[state.nr],".",sets[set.nr],"[,2]!=",state.nr-2,"))"
    )))
  }
}

#### OBSOLETE 2 ####
#minus1.train<-train.comparison[(train.comparison[,1]==-1|train.comparison[,2]==-1),]
#minus1.check.train<-data.frame(good.signals=sum(minus1.train[,1]==-1 & minus1.train[,2]==-1),bad.signals=sum(minus1.train[,1]!=-1 & minus1.train[,2]==-1),undiscovered=sum(minus1.train[,1]==-1 & minus1.train[,2]!=-1))
#zeros.train<-train.comparison[(train.comparison[,1]==0|train.comparison[,2]==0),]
#zeros.check.train<-data.frame(good.signals=sum(zeros.train[,1]==0 & zeros.train[,2]==0),bad.signals=sum(zeros.train[,1]!=0 & zeros.train[,2]==0),undiscovered=sum(zeros.train[,1]==0 &zeros.train[,2]!=0))
#plus1.train<-train.comparison[(train.comparison[,1]==1|train.comparison[,2]==1),]
#plus1.check.train<-data.frame(good.signals=sum(plus1.train[,1]==1 & plus1.train[,2]==1),bad.signals=sum(plus1.train[,1]!=1 & plus1.train[,2]==1),undiscovered=sum(plus1.train[,1]==1 & plus1.train[,2]!=1))
#minus1.test<-test.comparison[(test.comparison[,1]==-1|test.comparison[,2]==-1),]
#minus1.check.test<-data.frame(good.signals=sum(minus1.test[,1]==-1 & minus1.test[,2]==-1),bad.signals=sum(minus1.test[,1]!=-1 & minus1.test[,2]==-1),undiscovered=sum(minus1.test[,1]==-1 & minus1.test[,2]!=-1))
#zeros.test<-test.comparison[(test.comparison[,1]==0|test.comparison[,2]==0),]
#zeros.check.test<-data.frame(good.signals=sum(zeros.test[,1]==0 & zeros.test[,2]==0),bad.signals=sum(zeros.test[,1]!=0 & zeros.test[,2]==0),undiscovered=sum(zeros.test[,1]==0 &zeros.test[,2]!=0))
#plus1.test<-test.comparison[(test.comparison[,1]==1|test.comparison[,2]==1),]
#plus1.check.test<-data.frame(good.signals=sum(plus1.test[,1]==1 & plus1.test[,2]==1),bad.signals=sum(plus1.test[,1]!=1 & plus1.test[,2]==1),undiscovered=sum(plus1.test[,1]==1 & plus1.test[,2]!=1))



