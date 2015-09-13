# Frequency distributions for relevant variables after
# Linear Discriminant Analysis
# Script makes violing plots 



plot.new()
par(mfrow=c(Nr.of.plots.per.page,1),mfg=c(1,1))

for (chart.nr in 1:ceiling(nr.of.most.relevant/Nr.of.plots.per.page)){
for (i in 1:Nr.of.plots.per.page){
var.nr<-i+Nr.of.plots.per.page*(chart.nr-1)
if (var.nr<=nr.of.most.relevant){
vioplot(data.numeric[data.numeric[,1]==-1,most.relevant[var.nr]+1],
        data.numeric[data.numeric[,1]==0,most.relevant[var.nr]+1],
        data.numeric[data.numeric[,1]==1,most.relevant[var.nr]+1],
        names=c(-1,0,1),col="darkgreen",rectCol="green",colMed="black")
title(paste0(names(most.relevant[var.nr]),"; ",column_names[most.relevant[var.nr]+1]))
}
}
dev.copy(pdf,paste0("distribution_",var.nr-Nr.of.plots.per.page+1,"-",min(var.nr,nr.of.most.relevant),".pdf"))
dev.off()
}

