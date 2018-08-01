#!/bin/bash
# collect global mean and brain mean from spect and write to csv file
# glob mean is read from the orig images
# brain mean is from the normalized images
meanValFile=mean_val.csv
origDir=/home/torgil/tmp/rotte/git_base/img/nii_whs/
warpDir=/home/torgil/tmp/rotte/git_base/img/crop_whs/
brainMask=/home/torgil/tmp/rotte/atlas/whs/WHS_SD_v2_brainmask_bin_02mm.nii.gz
# collect images
origSPECT=$(find $origDir -type f -name "*SPECT*.nii.gz")

echo "filename,globMean,brainMean" > $meanValFile
for fi in ${origSPECT[@]}; do
    globMean=$(fslstats $fi -M) #nonzero mean
    # find corr warp file
    fnFull=$(basename $fi)
    fnStem=$(remove_ext $fnFull)
    warpedImage=${warpDir}/${fnStem}_cropWarped.nii.gz
    brainMean=$(fslstats $warpedImage -k $brainMask -M) #nonzero mean
    echo "$fnStem,$globMean,$brainMean" >>  $meanValFile
done

