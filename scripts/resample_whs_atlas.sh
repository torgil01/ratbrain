#!/bin/bash

# Resample WHS atlas to 0.2 mm iso using ants:ResampleImageBySpacing

atlasDir=/home/torgil/tmp/rotte/atlas/whs/

# use nearest neighbor interpolation for these files
nnFiles=(WHS_rat_atlas_hemi.nii.gz \
	 WHS_SD_rat_atlas_v2.nii.gz  \
	 WHS_SD_v2_brainmask_bin.nii.gz \
	 WHS_SD_v2_white_gray_mask_clipped.nii.gz)

# trilinear for this
intFiles=(WHS_SD_rat_T2star_v1.01.nii.gz \
	 WHS_SD_rat_T2star_v1.01_brain.nii.gz)


for f in ${nnFiles[@]}; do
    fn=$(remove_ext $f)
    inputFile=${atlasDir}/${f}
    outputFile=${atlasDir}/${fn}"_02mm.nii.gz"
    ResampleImageBySpacing 3 $inputFile $outputFile 0.2 0.2 0.2 0 0 1 
done

for f in ${intFiles[@]}; do
    fn=$(remove_ext $f)
    inputFile=${atlasDir}/${f}
    outputFile=${atlasDir}/${fn}"_02mm.nii.gz"
    ResampleImageBySpacing 3 $inputFile $outputFile 0.2 0.2 0.2 0 0 0
done


