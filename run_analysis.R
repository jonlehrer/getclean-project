#--------------------------------
#This code was used to download the file
#It is no longer needed if the Samsung Data directory is local and in the working directory
#file <- "FUCI_Dataset.zip"
#zip <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#if (!file.exists(zip)) download.file(zip,file,mode="wb")
#unzip(file)
#setwd("./UCI HAR Dataset")
#----------------------------------

#read in and merge the test data, activity labels, and subject ids
x_train <- read.table("./UCI HAR Dataset/train/x_train.txt",header=F)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt",header=F)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=F)
train <- cbind(x_train,y_train,subject_train)

#read in and merge the training data, activity labels, and subject ids
x_test <- read.table("./UCI HAR Dataset/test/x_test.txt",header=F)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt",header=F)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=F)
test <- cbind(x_test,y_test,subject_test)

#combine training and test data into one dataset called "dat"
dat <- rbind(train,test)

#read in and apply the variable names
features <- read.table("./UCI HAR Dataset/features.txt",header=F)
colnames(dat) <- c(as.character(features[,2]),"activity","subject")

#read in and apply the activity names (convert codes into descriptive labels)
activity <- read.table("./UCI HAR Dataset/activity_labels.txt",header=F)
dat$activity <- factor(dat$activity,levels=activity$V1, labels=activity$V2)

#subset the data for only mean and std
meancol <- grep("mean()",colnames(dat),fixed=T,value=T)
stdcol <- grep("std()",colnames(dat),fixed=T,value=T)
dat_trim <- dat[,c("activity","subject",meancol,stdcol)]


#summarize
#install.packages("reshape2") #only necessary the first time
library(reshape2)

#melt the dataset then recast to take the average of all variables by subject and activity
dat_melt <- melt(dat_trim,id.vars=c("subject","activity"))
dat_cast <- dcast(dat_melt,subject+activity ~ variable,mean)
write.table(dcast,'tidy.txt')




#check by using a different approach
#split apply combine
x <- split(dat_trim,list(dat_trim$subject,dat_trim$activity))
x2 <- lapply(x,subset,select=3:68)
x3 <- sapply(x2,colMeans)

#transpose and reorder the two results to align the data
x4 <- t(x3)
dc4 <- as.matrix(dat_cast[order(dat_cast$activity,dat_cast$subject),3:68])

#verify that the data is equal
all.equal(x4,dc4, check.attributes=F)

