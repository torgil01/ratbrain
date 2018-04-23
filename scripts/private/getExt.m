function ext = getExt(file)
% function ext = getExt(file)
% return extension for file *including* '.'
% handles nii.gz 

[base,fn,ex] = fileparts(file);
file = [fn ex];
[fn,ext] = strtok(file,'.');

