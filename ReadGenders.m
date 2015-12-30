function [gendersMap] = ReadGenders()
    fid = fopen('genders/genders.txt');

    gendersMap = containers.Map('KeyType','char','ValueType','uint8');
    
    currentLine = fgets(fid);
    while ischar(currentLine)
        data = strsplit(currentLine);
        gendersMap(data{1}) = str2num(data{2});
        currentLine = fgets(fid);
    end

    fclose(fid);
end