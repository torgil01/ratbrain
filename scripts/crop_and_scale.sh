#!/bin/bash
# this script reads the crop coordinates from a csv file
# and crop the images according to the parameters.
# The cropped SPECT image values are then scaled to the mean of the
# original SPECT image and multiplied with 100
# S = 100*(S0/Mean)
#
# The csv file must have the following format
#
# filename,cx,cy,cz
#
# filename is the name for files in "readDir" no path
# cx is the x voxel coordinate for the center of the brain
# etc
#

# files are read from readDir and the cropped fies are written to
# cropDir
# 
readDir=/home/torgil/tmp/rotte/git_base/img/nii
cropDir=/home/torgil/tmp/rotte/git_base/img/crop

xs=70 # neg offset 
ys=70 # neg offset 
zs=60 # neg offset 
dx=140 # box size
dy=140 # box size
dz=126 # box size

# read csv with filenames and coordinates
i=0
while IFS=, read fn x y z
do
    inputFile=${readDir}/${fn}
    bname=$(remove_ext $fn) # fsl util
    inputFile=${readDir}/${fn}
    cropFile=${cropDir}/${bname}_crop.nii.gz
    cmd="fslroi $inputFile $cropFile $(($x - $xs)) $dx $(($y - $ys)) $dy $(($z - $zs)) $dz"
    echo $cmd
done < $1










