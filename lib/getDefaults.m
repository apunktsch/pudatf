function default = getDefaults(file, value)
a = dbstack(1);
fid = fopen(file);
tline = fgetl(fid);
while ischar(tline)
    if contains(tline, a.name)
       break;
    end   
    tline = fgetl(fid);
end
while ischar(tline)
    sides = split(tline,":");
    if strcmp(strrep(sides(1)," ",""), value)
        eval(strcat("default=",string(sides(2))));
    end
    tline = fgetl(fid);
end
if not(exist("default", "var")) 
    error("variable <%s> not found for file <%s> in defaults <%s>", value,a.name ,file)
end
fclose(fid);