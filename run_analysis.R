library(reshape2)

filename <- "getdata_dataset.zip"


##downloading and unzipping the dataset
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

## load activity labels and features
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## extracting mean and standard deviation
meansd<-grep(".*mean.*|.*std.*", features[,2])
meansd.names <- features[meansd,2]
meansd.names = gsub('-mean', 'mean', meansd.names)
meansd.names = gsub('-std', 'std', meansd.names)
meansd.names <- gsub('[-()]', '', meansd.names)

# Load the datasets
train<-read.table("UCI HAR Dataset/train/X_train.txt")[meansd]
trainactivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainsubjects, trainactivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[meansd]
testactivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testsubjects, testactivities, test)

# merge datasets and add labels
alldata <- rbind(train, test)
colnames(alldata) <- c("subject", "activity", meansd.names)

# turn activities & subjects into factors
alldata$activity <- factor(alldata$activity, levels = activitylabels[,1], labels = activitylabels[,2])
alldata$subject <- as.factor(alldata$subject)

alldata.melted <- melt(alldata, id = c("subject", "activity"))
alldata.mean <- dcast(alldata.melted, subject + activity ~ variable, mean)

write.table(alldata.mean, "tidy.txt", row.names = FALSE, quote = FALSE)