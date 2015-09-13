# Script performs linear discriminant analysis for the formatted csv file.
# The grouping factor is in the first column. It is a symbol of positive swing (peak), 
# negative swing (peak) or trend continuation.

#install.packages("sda")
#install.packages("MASS")
#install.packages("entropy")
#install.packages("corpcor")
#install.packages("fdrtool")
#install.packages("lda")
#install.packages("vioplot")

#### Libraries needed ####

library(MASS)
library(sda)
# library(ggplot2)
library(vioplot)

#library(entropy)
#library(corpcor)
#library(fdrtool)
#library(lda)

# function to hold on
readkey <- function()
{
  cat ("\nPress [enter] to continue...")
  line <- readline()
}

#### Home directory ####
# homedir <-"C://Users//Neal//Documents//R"
homedir <-"~/Desktop/dm/free/09_september/hl_classification/"
setwd(homedir)

#### Choosing the file to open ####
file.to.open <- file.choose()

# Data frame from the chosen file
raw.data <- read.csv(file.to.open, header = T)

# Watch the import results. 
# Some data manipulation needed to get the correct values
# Problems as data imports as string values
# rowMeans(is.na(data)*1)
# colMeans(is.na(data)*1)

source("constants.R")
source("scritps/data_info.R")
source("scritps/discriminant_analysis.R")
if (nr.of.most.relevant){
  source("scritps/predictions.R")  
  source("scritps/messages.R")
  source("scritps/histograms.R")
}
print(lda.results)
