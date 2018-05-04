function labels = read_atlas_labels(atlasType,labelsPath)
fid = fopen(labelsPath);
labels = textscan(fid,'%n %s','MultipleDelimsAsOne',1,'CommentStyle','//');
fclose(fid);

