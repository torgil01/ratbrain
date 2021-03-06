#!/bin/bash
# reads the crop coordinates from a csv file
# and crop the images according to the parameters
#
# The csv file must have the following format
#
# filename,cx,cy,cz
#
# filename is the name for files in "readDir" no path
# cx is the x voxel coordinate for the center of the brain
# etc


function usage {
    echo "this script reads the crop coordinates from a csv file"
    echo "and crop the images according to the parameters"
     echo "Usage:  "
    echo "$0  -i <source directory> -o <dir for crop files> -c <input-csv-file>"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi


# parse args
while getopts "hi:o:c:" flag
do
  case "$flag" in
    i)
      readDir=$OPTARG
      ;;
    o)
      cropDir=$OPTARG
      ;;
    c)
      csvFile=$OPTARG
      ;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done


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
    echo "processing $inputFile"
    bname=$(remove_ext $fn) # fsl util
    inputFile=${readDir}/${fn}
    cropFile=${cropDir}/${bname}_crop.nii.gz
    fslroi $inputFile $cropFile $(($x - $xs)) $dx $(($y - $ys)) $dy $(($z - $zs)) $dz
done < ${csvFile}






