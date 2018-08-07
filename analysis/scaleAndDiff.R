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
  
  # allocate new dataframe for t2 - t1 diff
  # we just use the original to get the labels
  #diffValues <- scaledData[FALSE,]
  #diffValues$sess <- NULL
  #diffValues$Filename <- NULL
  #diffValues$globMean <- NULL
  #diffValues$brainMean <- NULL
  
  numVar <- length(roiLabels)
  group <- vector()
  d <- matrix(nrow = length(idList), ncol=length(roiLabels))
  
  for (i in 1:length(idList)){
    t1 <- as.matrix(scaledData[(scaledData$id == idList[i]) & (scaledData$sess == 1),5:(4+numVar)])
    t2 <- as.matrix(scaledData[(scaledData$id == idList[i]) & (scaledData$sess == 2),5:(4+numVar)])
    grp <- scaledData[(scaledData$id == idList[i]) & (scaledData$sess == 1),]$group
    d[i,] <- t2 - t1
    #diffValues[i,]$id <- idList[i]
    group[i] <- grp
    #diffValues[i,]$group  <- grp
    #diffValues[i,3:3+numVar] <- d
  }
  
  diffValues <- data.frame(idList,group,d)
  colnames(diffValues) <- c("id","group",roiLabels)
  return(diffValues)
}