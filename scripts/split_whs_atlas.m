function split_whs_atlas
% Split WHS atlas in right and left hem
% 
% Positive x is right hemisphere
% Need to relabel the atlas labels so that there are unique labels
% for the two hemispheres, also the labels file must be reformatted.
% Label index runs from 0 -> 115 
% We add 300 to right hemi and 500 to left hemi 
% 


labelFile = '/home/torgil/tmp/rotte/atlas/whs/WHS_SD_rat_atlas_v2.label';
labelImage = '/home/torgil/tmp/rotte/atlas/whs/WHS_SD_rat_atlas_v2.nii.gz';
new_labelImage = '/home/torgil/tmp/rotte/atlas/whs/WHS_rat_atlas_hemi.nii.gz';
new_labelFile = '/home/torgil/tmp/rotte/atlas/whs/WHS_SD_rat_atlas_hemi.label';

% the offset for the new indexes. 
rOffset = 300; % offset for right hemisphere
lOffset = 500; % offset for left hemisphere

[V,atlas] = readNii(labelImage);
mask = zeros(V.dim);

% find index for x origin
ox = -V.mat(1,4)/V.mat(1,1); 

mask(1:ox,:,:)= rOffset;
mask(ox+1:end,:,:)= lOffset;

atlas = atlas + mask; 
% fix the opaque mask
atlas(atlas==rOffset) = 0;
atlas(atlas==lOffset) = 0;

Vnew = V;
Vnew.fname = new_labelImage;
writeNii(Vnew,atlas);

% now fix labels file
fid = fopen(labelFile);
% # ITK-SnAP Label Description File
% # File format: 
% # IDX   -R-  -G-  -B-  -A--  VIS MSH  LABEL
% # Fields: 
% #    IDX:   Zero-based index 
% #    -R-:   Red color component (0..255)
% #    -G-:   Green color component (0..255)
% #    -B-:   Blue color component (0..255)
% #    -A-:   Label transparency (0.00 .. 1.00)
% #    VIS:   Label visibility (0 or 1)
% #    MIDX:   Label mesh visibility (0 or 1)
% #  LABEL:   Label description 

labels = textscan(fid,'%n %d %d %d %f %d %d %q','MultipleDelimsAsOne',1,'CommentStyle','#');
fclose(fid);
numelLabels = length(labels{1});
newLabels = cell(2*numelLabels,8);

% reassign parameters from lables file, see abowe for def
IDX = labels{1};
R = labels{2};
G = labels{3};
B = labels{4};
A = labels{5};
VIS = labels{6};
MIDX = labels{7};
LABEL = labels{8};

for i=1:numelLabels,
    % new index
    newLabels{1}(i) = IDX(i) + rOffset; 
    newLabels{1}(i+numelLabels) = IDX(i) + lOffset; 
    % new R
    newLabels{2}(i) = newRGB(R(i),-10);
    newLabels{2}(i+numelLabels) = newRGB(R(i),10);
    % new G
    newLabels{3}(i) = newRGB(G(i),-10);
    newLabels{3}(i+numelLabels) = newRGB(G(i),10);
    % new B
    newLabels{4}(i) = newRGB(B(i),-10);
    newLabels{4}(i+numelLabels) = newRGB(B(i),10);
    % new A (unchanged)
    newLabels{5}(i) = A(i);
    newLabels{5}(i+numelLabels) = A(i);
    % new VIS (unchanged)
    newLabels{6}(i) = VIS(i);
    newLabels{6}(i+numelLabels) = VIS(i);
    % new MIDX (unchanged)
    newLabels{7}(i) = MIDX(i);
    newLabels{7}(i+numelLabels) = MIDX(i);
    % new LABEL
    newLabels{8}{i} = ['Right ' LABEL{i}];
    newLabels{8}{i+numelLabels} = ['Left ' LABEL{i}];
end
newLabels{1}(1) = 0;


fid = fopen(new_labelFile,'w+');
for i=1:numelLabels*2,    
    fprintf(fid,'%i\t%d\t%d\t%d\t%f\t%d\t%d\t%s\n',newLabels{1}(i),newLabels{2}(i),...
        newLabels{3}(i),newLabels{4}(i),newLabels{5}(i),newLabels{6}(i),...
        newLabels{7}(i),newLabels{8}{i});
end
fclose(fid);


function newValue = newRGB(oldValue,change)
% change old RGB value by "change", but ensure that values are between
% 0-255
newValue = oldValue + change;
if newValue > 255; newValue = 255; end
if newValue < 0; newValue = 0; end




