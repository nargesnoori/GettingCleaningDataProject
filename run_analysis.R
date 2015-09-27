# download the file
file<-'data.zip'
url<-'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

if(!file.exists(file)){
  download.file(url,file)  
}


# unzips the data into the current folder
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}
# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# extract data for mean and std
desiredFeatures <- grep(".*mean.*|.*std.*", features[,2])
desiredFeatures.names <- features[desiredFeatures,2]
desiredFeatures.names = gsub('-mean', 'Mean', desiredFeatures.names)
desiredFeatures.names = gsub('-std', 'Std', desiredFeatures.names)
desiredFeatures.names <- gsub('[-()]', '', desiredFeatures.names)


# Load the datasets 
train <- read.table("UCI HAR Dataset/train/X_train.txt")[desiredFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[desiredFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# now merge the data
all_train_test <- rbind(train,test)
colnames(all_train_test) <- c("Subject", "Activity", desiredFeatures.names)

# turn activities & subjects into factors
all_train_test$Activity <- factor(all_train_test$Activity, levels = activityLabels[,1], labels = activityLabels[,2])
all_train_test$Subject <- as.factor(all_train_test$Subject)
library(reshape2)
all_train_test.melted <- melt(all_train_test, id = c("Subject", "Activity"))
all_train_test.mean <- dcast(all_train_test.melted, Subject + Activity ~ variable, mean)

write.table(all_train_test.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
