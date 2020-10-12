# Coursera - Getting and Cleaning Data - Course Final Project

The code contained within the `run_analysis.R` script provides functions to perform the following actions as described as part of the assignment:

- Merges the training and the test sets to create one data set
- Extracts only the measurements on the mean and standard deviation for each measurement
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names

These functions can all be performed at once with the `runAnalysis` function.

It also will optionally download and extract the original data to the location of a users choosing if it is not already present.

A function is also provided to create a "tidy" version of the dataset with the function `createTidyDataset`, as described in step #5 of the assignment:

> From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
