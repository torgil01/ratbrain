#!/bin/bash

dcmDir=$1
niiDir=$2

dcmFiles=$(find $dcmDir -type f -name \*)

for file in ${dcmFiles[@]}; do
    echo "$file"
    filename=$(basename $file)
    #echo $filename
    # baseDir=$(dirname $file)
    
    dcm2niix -f ${filename} -s y -o ${niiDir} $file 
    # fix orientation issue
    niiFile="${niiDir}/${filename}.nii.gz"
    tmpFile="$(tempfile).nii.gz"  
    fslorient -deleteorient $niiFile # delete orientation info
    fslswapdim $niiFile -x z y  $tmpFile # swap dims so that they are correct in fslview
    fslorient -setsformcode 1 $tmpFile # set correct header
    # the following two line shifts the origin such that roughly it matches the Schwartz atlas
    fslorient -setqform -0.177 0 0 12 0 0.177 0 -9 0 0 0.177 -16 0 0 0 1 $tmpFile
    fslorient -setsform -0.177 0 0 12 0 0.177 0 -9 0 0 0.177 -16 0 0 0 1 $tmpFile
    rm $niiFile
    mv $tmpFile $niiFile
done

