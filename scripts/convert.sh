#!/bin/bash

# parse args
while getopts "hd:n:t:" flag
do
  case "$flag" in
      d)
	  # t1w input volume
	  dcmDir=$(readlink -f  "$OPTARG")
	  ;;
      n)
	  # id for current input
	  niiDir=$(readlink -f  "$OPTARG")
	  ;;
      t) 
	  # destination dir for FS output
	  target=${OPTARG,,} # convert to lowercase
	  case  "$target" in
	      whs)
		  ox=43
		  oy=-45
		  oz=-51		  
		  ;;
	      schwarz)
		  ox=12
		  oy=-9
		  oz=-16
		  ;;
	      ?)
	      echo "Unknown target $target, exiting"
	      exit 2
	      ;;
	  esac	  
	  ;;
      h)
	  echo "Usage: $0 -d <dicom-dir> -n <nii-dir> -t <Schwarz | whs> "
	  exit 0
	  ;;
      ?)    
      echo Unknown input flag $flag
      echo "Usage: $0 -d <dicom-dir> -n <nii-dir> -t <Schwarz | whs> "
      exit 2
      ;;
  esac
done


dcmFiles=$(find $dcmDir -type f -name \*)

for file in ${dcmFiles[@]}; do
    echo "$file"
    filename=$(basename $file)
    # baseDir=$(dirname $file)    
    dcm2niix -f ${filename} -s y -o ${niiDir} $file 
    # fix orientation issue
    niiFile="${niiDir}/${filename}.nii.gz"
    tmpFile="$(tempfile).nii.gz"  
    fslorient -deleteorient $niiFile # delete orientation info
    fslswapdim $niiFile -x z y  $tmpFile # swap dims so that they are correct in fslview
    fslorient -setsformcode 1 $tmpFile # set correct header
    # the following two line shifts the origin such that roughly it matches the target atlas
    fslorient -setqform -0.177 0 0 $ox 0 0.177 0 $oy 0 0 0.177 $oz 0 0 0 1 $tmpFile
    fslorient -setsform -0.177 0 0 $ox 0 0.177 0 $oy 0 0 0.177 $oz 0 0 0 1 $tmpFile
    rm $niiFile
    mv $tmpFile $niiFile
done

