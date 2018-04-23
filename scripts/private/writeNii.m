function writeNii(V,img)
% wrapper for spm IO so that SPM can write nii.gz format
% input
% V - spm-formatted image header (see spm_vol)
% img - data array
% support for 4D arrays?

if strcmp('.nii.gz',getExt(V.fname)) == true,
    V.fname = replaceExt(V.fname,'.nii');
    spm_write_vol(V,img);    
    gzip(V.fname);
    delete(V.fname);    
elseif strcmp('.nii',getExt(V.fname)) == true,
    spm_write_vol(V,img);    
else
    error('fileformat %s is not supported',file);
end