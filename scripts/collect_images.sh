#!/bin/bash
# collect images matching pattern and 
# glob mean is read from the orig images
# brain mean is from the normalized images
source=/home/torgil/tmp/rotte/git_base/img/crop_whs/
dest=/home/torgil/tmp/rotte/git_base/img/stats/stack/
# collect images
files=$(find $source -type f -name "*SPECT_cropWarped.nii.gz")


for fi in ${files[@]}; do
    fn=$(basename $fi)
    cp $fi ${dest}/${fn}
done

    
