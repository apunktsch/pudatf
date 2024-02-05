function b = analyzeSystems(folder)
% folder        folder with the systems to analyse
d = dir(folder);
b = {};
c = {};
for i = 1:length(d)
    [filepath,name,ext] = fileparts(d(i).name);
    if not(d(i).isdir) && strcmpi(ext, '.mat')
        b{end+1} = who('-file', [filepath name ext]);
        c{end+1} = name;
    end
end
fh = fopen(strcat(folder,"/systems.index"), 'w+');
for k = 1:length(b) 
    b_k = b{k};
    
     fprintf(fh, "%s", string(b_k{1}));
    for i =  2:length(b_k)
      fprintf(fh, ",%s", string(b_k{i}));
    end
    fprintf(fh,": %s\n", c{k})
end

fclose(fh)