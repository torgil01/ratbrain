getData <- function(){
  # get csv files from github
  
  require(tidyverse)
  
  atlasLabels <- read_csv('https://raw.githubusercontent.com/torgil01/ratbrain/master/scripts/table_WHS.csv')
  meanVals <- read_csv('https://raw.githubusercontent.com/torgil01/ratbrain/master/scripts/mean_val.csv')
  
  # mean val contain only filename,globMean, brainMena
  # need to parse filename to get id groupand session
  # format is "group_id_xxx_sessID_xx[_yy]"
  # we just
  
  for (i in 1:nrow(atlasLabels)){
    row <- unlist(strsplit(atlasLabels$Filename[i],'/'))
    atlasLabels$Filename[i] <- unlist(strsplit(row[9],'_cropWarped.nii.gz'))
  }
 
  names(meanVals)[names(meanVals) == 'filename'] <- 'Filename'
 
  # merge 
  atlasLabels <- atlasLabels %>% merge(meanVals, by = 'Filename')
  # rfemove these labels
  atlasLabels$Right_Clear_Label <- NULL
  atlasLabels$Left_Clear_Label <- NULL
  # also these since they are not labeled in the atlas
  atlasLabels$Right_central_canal  <- NULL
  atlasLabels$Left_central_canal  <- NULL
  atlasLabels$Right_medial_lemniscus_decussation  <- NULL
  

  return(atlasLabels)
}