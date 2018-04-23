# Normalize rat SPECT scans to MRI atlas

Documentation on how to warp SPECT scans to a MRI rat atlas. 

## Info
Each animal have a SPECT and a CT scan. These scans are in alignment.

The SPECT scans have voxel dimensions 0.177 x 0.177 x 0.177 mm (from dicom header). We want the
images in NIFTI format for subsequent processing and warping to atlas. In this example we use the
Schwarz atlas. 

## Image conversion and cropping

### Naming issue
Files are named like "Control_1033_Scan 1_SPECT". The problem here is that there is a space in the name, which may
cause some problems on Linux systems. The easiest solution is replace the space with a underscore.

```
find /image_dir/ -type f -name "* *" | rename 's/ /_/g'
``` 

## Data organization

>    base
>     |------- img
>               |------ raw_data (Dicom files)
>               |------ nii  (Dicom files converted to nii format)
>               |------ crop (Cropped image files)
>     |------- scripts
>     |------- doc


### DICOM to nifti conversion
Conversion with `dcm2niix` works, but the coordinate system is
incorrect. The anatomical directions (head-feet, anterior-posterior, right - left) encoded in the DICOM file
does not match the anatomy. (The faulty coordinate system appear to be created by PMOD.) 

DICOM to NIFTI conversion and header correction is done with the `convert.sh` script. 

The reorientation issue is solved using FSL tools. We use `flsorient` to delete the image hader, then `fslswapdim` to swap image dimensions to "-x z y" (right-left encoding is unaffected). The first call to  `fslorient` sets the "sform code" to 1 which just means that the affine transform in the header is to be used to map the coordinates.
Then we specify the actual affine matrix in the next two calls to `flsorient`. We set this to be a translation that aligns the data roughly to the MRI template. (We use the same translation as in the header in the atlas files.)

Code in `convert.sh`.

```
fslorient -deleteorient $im
fslswapdim blank.nii -x z y $out
fslorient -setsformcode 1 $out
fslorient -setqform -0.177 0 0 12 0 0.177 0 -9 0 0 0.177 -16 0 0 0 1 $tmpFile
fslorient -setsform -0.177 0 0 12 0 0.177 0 -9 0 0 0.177 -16 0 0 0 1 $tmpFile
```

### Cropping
The SPECT/CT images had a large field of view, covering head and forebody of the animal.

To reliabley warp the images to a brain template we need to isolate the part of the image that contain the brain. 

Cropping is done semi-automatically by first finding the approximate voxel coordinates for the center of the brain manually using an image viewer. The fileame and x,y,z voxel coordinates needs to be saved in a csv file as in the example below.

Example csv file

> Control_1033_Scan_1_SPECT.nii.gz,261,245,273
> Control_1034_Scan_1_SPECT.nii.gz,255,251,282
> Control_1039_Scan_1_SPECT.nii.gz,246,254,259
> Control_1040_Scan_1_SPECT.nii.gz,256,253,274

Based on these coordinates the `crop.sh` script extract a "box" around the coordinates for the center for the brain. A box with 140 x 140 x 126 voxels (RL,PA,IS) centered over the brain seems to work well. 

The crop scrip is called with the csv fie as argumnet.
```
crop.sh coord.csv
```

## Warping the SPECT images to the MRI template
Visually the SPECT images have a similar contrast to a T2-weighted image. We therefore used the T2 image as target for the warping. We use the `ANTS` toolkit for warping (https://github.com/ANTsX/ANTs). Warping is done by the `warp.sh`script. We use the Schwarz template (Schwarz et al. 2006; doi: 10.1371/journal.pone.0122363) distributed with the SAMIT software (http://mic-umcg.github.io/samit/) in this example. The WHS template (https://www.nitrc.org/projects/whs-sd-atlas) is also an alternative, but it should probably be downsampled before using. Note that the brainmask in the Schwarz temlpate has incorrect dimension compared to the other template images (96x120x97 compared to 96x102x96). This is fixed by removing a slize in the z-dim `fslroi Schwarz_intracranialMask.nii brainmask  0 96 0 120 0 96`.


The `warp.sh`script does the following

1. compute warp between SPECT image and the the *T2_intra* Schwarz template.
2. warp the SPECT image to template space
3. as a quality control, the corresponding CT image is also warped to the template using the SPECT -> T2 transform.

A number of files are created in the `crop` directory by the warp script. As an example, for the input file `Control_1033_Scan_1_SPECT_crop.nii.gz`, the following files will be created:

> Control_1033_Scan_1_SPECT_crop0GenericAffine.mat    (the affine transform)
> Control_1033_Scan_1_SPECT_crop1Warp.nii.gz          (the nonlinear warp field)
> Control_1033_Scan_1_SPECT_crop1InverseWarp.nii.gz   (inverse warp field)
> Control_1033_Scan_1_SPECT_cropInverseWarped.nii.gz  (inverse warp)
> Control_1033_Scan_1_CT_cropWarped.nii.gz            (warped CT image)


**Note**: The warping also resample the images in the template space, meaning that the warped images will have the same field of view and resolution as the template. (The Schwarz template is 0.2 mm isotropic.)

## SPECT signal normalization
SPECT data is not absolute, and total signal may fluctuate from scan to scan. Standard practice is to "center" the signal. This can be doine several ways. One may normalize the signal to the whole brain or whole image. The latter approach may be less sensitive to large signal flucuations in the brain due to the tracer.

Example

**ID**|**whole image**|**brain**
:-----:|:-----:|:-----:
C1033| 81| 723
C1034|74|765

Here we see that ID 1033 has a larger mean signal in the whole image compared to ID 1034, but a smaller mean signal in the brain. This suggest that the global signal is a better value to scale the signal to. We then simply scale the signal in the warped images by the nonzero mean in the original imgages.

$$ S = 100 * S_{0}/M $$






