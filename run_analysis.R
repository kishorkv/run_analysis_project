## run_analysis.R
## Program to create tidy data by extracting the datasets 
## provided in zipped folder @ https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## ================

## Note: Make sure you have reshape2 installed and loaded in your environment, otherwise you get - could not find function "dcast"

# Dataset file location
datasetZipFileLink =  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# dataset zip file name
datasetZipFile = "project_dataset.zip"

# Download the dataset file
download.file(datasetZipFileLink, datasetZipFile, method="curl")

# Unzip the datasetfile to current working directory
if (file.exists(datasetZipFile)) { 
  unzip(datasetZipFile)
} else {
  print("Error: Unable to extract/download dataset file from "+datasetZipFileLink)
}

## Load activity labels from  UCI HAR Dataset/activity_labels.txt
classActivityNames <- read.table("UCI HAR Dataset/activity_labels.txt")
classActivityNames[,2] <- as.character(classActivityNames[,2])

## Load allFeatures from UCI HAR Dataset/features.txt
allFeatures <- read.table("UCI HAR Dataset/features.txt")
allFeatures[,2] <- as.character(allFeatures[,2])


# Select mean and standard deviation from allFeatures
selectedFeatures <- grep(".*mean.*|.*std.*", allFeatures[,2])
selectedFeatures.names <- allFeatures[selectedFeatures,2]
selectedFeatures.names = gsub('-mean', 'Mean', selectedFeatures.names)
selectedFeatures.names = gsub('-std', 'Std', selectedFeatures.names)
selectedFeatures.names <- gsub('[-()]', '', selectedFeatures.names)

# Load all the datasets for mean and standard (selected features)
trainingSet <- read.table("UCI HAR Dataset/train/X_train.txt")[selectedFeatures]
trainingLabels <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainingSet <- cbind(trainingSubjects, trainingLabels, trainingSet)

testing <- read.table("UCI HAR Dataset/test/X_test.txt")[selectedFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testing <- cbind(testSubjects, testActivities, testing)

# combine training and testting datasets
allData <- rbind(trainingSet, testing)
colnames(allData) <- c("subject", "activity", selectedFeatures.names)

# convert activities & subjects into factors
allData$activity <- factor(allData$activity, levels = classActivityNames[,1], labels = classActivityNames[,2])
allData$subject <- as.factor(allData$subject)

# melt data to get the unique 
allData.melted <- melt(allData, id = c("subject", "activity"))

allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# Write tidy data to a text file.
write.table(allData.mean, "tidydata.txt", row.names = FALSE, quote = FALSE)

if (file.exists("tidydata.txt")) { 
  print("Created tidy data 'tidydata.txt' file in the working directory")
} else {
  print("Error: Unable to create tidydata file")
}
