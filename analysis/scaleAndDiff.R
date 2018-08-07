scaleAndDiff <- function(rawData){
  # scale data and compute difference between t1 and t2 for each id
  # return scaled diff dataframe 
  # "rawData" is in long format
  
  require(tidyverse)
  
  normVariable <- "globMean"  # "brainMean"
  normVariable <- "brainMean"
  
  scaledData <- rawData
  roiLabels <- names(rawData %>% select(matches("^Right|^Left")))
  # loop over labels ... should be vectorized but have not figured an elegant solution
  for (i in 1:length(roiLabels)){
    scaledData[[roiLabels[i]]] <- scaledData[[roiLabels[i]]]/scaledData[[normVariable]]
  }

  # get unique ids
  idList <- unique(scaledData$id)
  numVar <- length(roiLabels)
  group <- vector()
  d <- matrix(nrow = length(idList), ncol=length(roiLabels))
  
  for (i in 1:length(idList)){
    t1 <- as.matrix(scaledData[(scaledData$id == idList[i]) & (scaledData$sess == 1),roiLabels])
    t2 <- as.matrix(scaledData[(scaledData$id == idList[i]) & (scaledData$sess == 2),roiLabels])
    grp <- scaledData[(scaledData$id == idList[i]) & (scaledData$sess == 1),]$group
    d[i,] <- t2 - t1
    group[i] <- grp
  }
  
  diffValues <- data.frame(idList,group,d)
  colnames(diffValues) <- c("id","group",roiLabels)
  return(diffValues)
}