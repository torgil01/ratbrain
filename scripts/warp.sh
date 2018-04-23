startDir=$(pwd)
imDir=/home/torgil/tmp/rotte/git_base/img/crop
ctDir=/home/torgil/tmp/rotte/git_base/img/nii
imFiles=$(find $imDir -type f -name "*SPECT_crop.nii.gz")
target=/home/torgil/tmp/rotte/atlas/Schwarz_T2w_Intra.nii

for fi in ${imFiles[@]}; do
    cd $imDir
    moving=$fi
    warpName=$(basename $fi .nii.gz)

    antsRegistration --verbose 1\
    		 --dimensionality 3\
    		 --float 0\
    		 --output [${warpName},${warpName}Warped.nii.gz,${warpName}InverseWarped.nii.gz]\
    		 --interpolation Linear\
    		 --use-histogram-matching 0\
    		 --winsorize-image-intensities [0.005,0.995]\
    		 --initial-moving-transform [${target},${moving},1]\
    		 --transform Rigid[0.1]\
    		 --metric MI[${target},${moving},1,32,Regular,0.25]\
    		 --convergence [1000x500x250x10,1e-6,10]\
    		 --shrink-factors 8x4x2x1\
    		 --smoothing-sigmas 3x2x1x0vox\
    		 --transform Affine[0.1]\
    		 --metric MI[${target},${moving},1,32,Regular,0.25]\
    		 --convergence [1000x500x250x10,1e-6,10]\
    		 --shrink-factors 8x4x2x1\
    		 --smoothing-sigmas 3x2x1x0vox\
    		 --transform SyN[0.1,3,0]\
    		 --metric MI[${target},${moving},1,32]\
    		 --convergence [100x70x50x10,1e-6,10]\
    		 --shrink-factors 8x4x2x1\
    		 --smoothing-sigmas 3x2x1x0vox


    # apply warp on CT if we find a corresp CT
    fiext=$(remove_ext $fi)
    fiext=$(basename $fiext)
    ctFile=${ctDir}/${fiext/SPECT_crop/CT}.nii.gz
    ctFileWarped=${imDir}/${fiext/SPECT/CT}Warped.nii.gz
    if [ -e "$ctFile" ]; then
    
	antsApplyTransforms -d 3 \
			    -i $ctFile \
			    -o $ctFileWarped \
			    -r ${warpName}Warped.nii.gz \
			    -t ${warpName}1Warp.nii.gz \
			    -t ${warpName}0GenericAffine.mat
   fi
    
done
cd  $startDir

    
