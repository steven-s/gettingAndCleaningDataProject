library(plyr)
library(dplyr)

downloadAndExtractRawDataset <- function(destdir) {
  if (!dir.exists(destdir)) {
    dir.create(destdir)
  }
  
  zipFileDest <- file.path(destdir, "uci_har_dataset.zip")

  if (!file.exists(zipFileDest)) {
    print(paste("Downloading UCI HAR dataset to", zipFileDest))
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = zipFileDest)
  } else {
    print("UCI HAR dataset zip already exists")
  }
  
  extractedFilesDest <- file.path(destdir, "UCI HAR Dataset")
  
  if (!dir.exists(extractedFilesDest)) {
    print(paste("Extracting UCI HAR dataset to", extractedFilesDest))
    unzip(zipFileDest, exdir = destdir)
  } else {
    print("UCI HAR dataset directory already exists")
  }
  
  extractedFilesDest
}

cleanFeatureName <- function(featureNameString) {
  splitName <- strsplit(featureNameString, "[-,()]")[[1]]
  splitName <- splitName[nchar(splitName) > 0]
  paste(splitName, collapse = ".")
}

loadDatasetXY <- function(rootDir, X, y, subject, featureNames, activityNames, featureNamePrefix) {
  #datasetFeatureNames <- lapply(featureNames, paste, featureNamePrefix, collapse=".")
  
  # Read Test X and y datasets
  datasetX <- read.table(file.path(rootDir, X), col.names =featureNames)
  datasetY <- read.table(file.path(rootDir, y), col.names = c("activity"))
  datasetSubjects <- read.table(file.path(rootDir, subject), col.names = c("subject"))
  
  # Convert activity into factor
  datasetY$activity <- factor(datasetY$activity, levels = activityNames$activityFactor, labels = activityNames$activityName)
  
  # merge together test dataset columns
  datasetX$subject <- datasetSubjects$subject
  datasetX$activity <- datasetY$activity
  datasetX
}

loadAndMergeDatasets <- function(datasetDir) {
  print("Loading test and train datasets")
  testDir <- file.path(datasetDir, "test")
  trainDir <- file.path(datasetDir, "train")
  
  # Read feature and activity names
  featureNames <- read.table(file.path(datasetDir, "features.txt"), col.names = c("featureIndex", "featureName"))
  activityNames <- read.table(file.path(datasetDir, "activity_labels.txt"), col.names = c("activityFactor", "activityName"))
  
  # Fix feature names to follow easier to read format
  featureNames$featureName <- lapply(featureNames$featureName, cleanFeatureName)
  
  testDataset <- loadDatasetXY(testDir, "X_test.txt", "y_test.txt", "subject_test.txt", featureNames$featureName, activityNames, featureNamePrefix = "test")
  print(paste("Loaded test dataset:", nrow(testDataset), "obs. of", ncol(testDataset), "variables"))
  trainDataset <- loadDatasetXY(trainDir, "X_train.txt", "y_train.txt", "subject_train.txt", featureNames$featureName, activityNames, featureNamePrefix = "train")
  print(paste("Loaded train dataset:", nrow(trainDataset), "obs. of", ncol(trainDataset), "variables"))
  
  print("Joining test and train datasets")
  join(testDataset, trainDataset)
}

extractMeanAndStd <- function(dataset) {
  print("Filtering dataset for mean, std, activity, and subject columns")
  filteredColumns <- grep("(\\.std$|\\.mean$|\\.std\\.|\\.mean\\.|^subject$|^activity$)", names(dataset))
  dataset[,filteredColumns]
}

runAnalysis <- function(destdir=getwd()) {
  extractedDatasetDir <- downloadAndExtractRawDataset(destdir)
  dataset <- loadAndMergeDatasets(extractedDatasetDir)
  filteredDataset <- extractMeanAndStd(dataset)
}

createTidyDataset <- function(dataset) {
  tidyDataset <- dataset %>% group_by(subject, activity) %>% summarise(across(starts_with("t") | starts_with("f"), mean))
}
