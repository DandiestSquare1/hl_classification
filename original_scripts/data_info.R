#### Some info about the dataset ####

data<-raw.data
column_names<-names(data)
No.of.columns<-ncol(data)
No.of.rows<-nrow(data)
cat("Number of columns: ", No.of.columns,"\n")
cat("Number of rows: ", No.of.rows,"\n")
readkey()

#### Check for missing values ####
Any.NAs<- sum(colSums(is.na(data)*1))
if (Any.NAs) {
  cat("There are missing values")
  readkey()}

# rowSums(is.na(data)*1)
# char.data<-lapply(data,as.character)
# nr.data<-lapply(data,numeric)

#### Changing data types to numeric ####
# Some False/True values can be read as a factor due to spaces in csv file 
classes<-sapply(data,class)
if (any(classes=="factor")){
  data.numeric<-as.data.frame(lapply(data,as.numeric))
  cat("Some of columns has been read as factors.\nData changed to numeric format.\n")
  readkey()
  }else {
    data.numeric<-data
  }


#### Column names in the csv file are somewhat long ####
# Obsolete piece of code that dealt with that:
# new_names<-sub(pattern="*.indRange.RightStrength.",".",column_names)
# new_names[3:83]=substr(column_names[3:83],1,7)

new_names<-c("y",paste0("x",1:(No.of.columns-1)))
# Replecement of original column names
names(data.numeric)<-new_names
# Names of column_names are "y", "x1", "x2",... but values are names of columns of raw.data
names(column_names)<-new_names
