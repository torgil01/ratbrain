function labels = read_atlas_labels(atlasType,labelsPath)
fid = fopen(labelsPath);
switch atlasType,
    case 'Schwarz',        
        labels = textscan(fid,'%n %s','MultipleDelimsAsOne',1,'CommentStyle','//');
    case 'WHS',        
        labels = textscan(fid,'%n %*d %*d %*d %*d %*d %*d %q','MultipleDelimsAsOne',1,'CommentStyle','#');
    otherwise,
        fclose(fid);
        error('Unknown atlas type')
end
fclose(fid);


