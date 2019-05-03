doStats <- function(diffValues){
  # run simple t-tets for group comparision
  require(tidyverse)
  
  roiLabels <- names(rawData %>% select(matches("^Right|^Left")))

  res <- sapply(diffValues[,3:length(diffValues)], function(x) t.test(x ~ diffValues$group)$p.value)

  #tests <- cbind(roiLabels,t)
}