function vals = get_table
% get mean values from atlas lables in a number of files

% atlas type can be "Schwarz" or "WHS"
atlasType = 'WHS';

switch atlasType,
    case 'Schwarz',        
        labelsPath = '/home/torgil/tmp/rotte/atlas/Schwarz/SAMIT.txt'; % atlas labels
        atlasPath  = '/home/torgil/tmp/rotte/atlas/Schwarz/SAMIT.nii'; % atlas rois
        % find the SPECT files in atlas space
        imgDir = '/home/torgil/tmp/rotte/git_base/img/crop/';
        files = findFiles(imgDir,'.*\_SPECT_scropWarped.nii.gz');
    case 'WHS',        
        labelsPath = '/home/torgil/tmp/rotte/atlas/whs/WHS_SD_rat_atlas_hemi.label'; % atlas labels
        atlasPath  = '/home/torgil/tmp/rotte/atlas/whs/WHS_rat_atlas_hemi_02mm.nii.gz'; % atlas rois        
        % find the SPECT files in atlas space
        imgDir = '/home/torgil/tmp/rotte/git_base/img/crop_whs/';
        files = findFiles(imgDir,'.*\_SPECT.*\_cropWarped.nii.gz');
    otherwise,
        error('Unknown atlas type')
end


% read atlas 
[~,atlas] = readNii(atlasPath);

% read atlas labels
% labels is a struct 2 x n struct 
% containing label index, and label name
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
        labelNumber = labels{1}(j);
        mask = bsxfun(@eq,atlas,labelNumber);        
        tmp = mask.*img;
        nonzero = tmp(tmp > 0);
        tableArray(i,j) = mean(nonzero(:));                
    end
end

tableFile = ['table_' atlasType '.csv'];
labs = {'Filename','id','sess','group',labels{2}{:}};
% construct table 
vals = cell(nFiles,nLabels+4); % extra filename,id, group, scan#
vals(:,1) = files;
% extract id, group and scan# from filename and put in array 
%id = zeros(nFiles,1);
%sess = zeros(nFiles,1);
%grp = cell(nFiles,1);
for i=1:nFiles,
    [~,fname] = rmExt(files{i});
    s = textscan(fname,'%s%n%s%n%s%s%s','Delimiter','_');    
    id = s{2};
    sess = s{4};
    grp = s{1};
    vals{i,2} = id;
    vals{i,3} = sess;
    vals{i,4} = grp;
end
%vals(:,2) = id;
%vals(:,3) = sess;
%vals(:,4) = grp;

vals(:,5:end)=num2cell(tableArray);
T = cell2table(vals,'VariableNames',labs);

% save table
writetable(T,tableFile);













