function get_table
% get mean values from atlas lables in a number of files

atlasType = 'Schwarz';
labelsPath = '/home/torgil/tmp/rotte/atlas/Schwarz/SAMIT.txt'; % atlas labels
atlasPath  = '/home/torgil/tmp/rotte/atlas/Schwarz/SAMIT.nii'; % atlas rois 

% find the SPECT files in atlas space
imgDir = '/home/torgil/tmp/rotte/git_base/img/crop/';
files = findFiles(imgDir,'.*\_SPECT_cropWarped.nii.gz');

% read atlas 
[~,atlas] = readNii(atlasPath);

% read atlas labels
% labels is a struct 2 x n struct 
% containing label idex, and label name
labels = read_atlas_labels(atlasType,labelsPath);

nLabels = length(labels{1});
nFiles = length(files);

% allocate table array
tableArray = zeros(nFiles,nLabels);

% allocate temp arrays in loop
dims = size(atlas);
mask = zeros(dims);
tmp =  zeros(dims);
% loop over spect files
for i = 1:length(files),
    [~,img] = readNii(files{i});
    fprintf('read %s\n',files{i});
    for j = 1:length(labels{1}),
        labelNumber = labels{1}(i);
        mask = bsxfun(@eq,atlas,labelNumber);        
        tmp = mask.*img;
        nonzero = tmp(tmp > 0);
        tableArray(i,j) = mean(nonzero(:));                
    end
end

tableFile = 'table.csv';
labs = {'Filename',labels{2}{:}};
% construct table 
vals = cell(nFiles,nLabels+1);
vals(:,1) = files;   
vals(:,2:end)=num2cell(tableArray);
T = cell2table(vals,'VariableNames',labs);

% save table
writetable(T,tableFile);


function labels = read_atlas_labels(atlasType,labelsPath)
fid = fopen(labelsPath);
labels = textscan(fid,'%n %s','MultipleDelimsAsOne',1,'CommentStyle','//');
fclose(fid);









