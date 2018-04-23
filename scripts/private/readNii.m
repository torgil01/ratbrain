function [V,img] = readNii(file)
% wrapper for spm IO so that SPM can read nii.gz format
if strcmp('.nii.gz',getExt(file)) == true,
    tempdir = tempname;
    gunzip(file,tempdir);
    [~,fName,~] =  fileparts(file);
    unzipFile = fullfile(tempdir,replaceExt(fName,'.nii'));
    V = spm_vol(unzipFile);
    img = spm_read_vols(V);
    V.fname = file;
    rmdir(tempdir,'s');
elseif strcmp('.nii',getExt(file)) == true,
    V = spm_vol(file);
    img = spm_read_vols(V);
else
    error('file %s is not gzip',file);
end