function [names, images] = ReadDataset(folder)
    % Reference:
    % http://www.mathworks.com/matlabcentral/answers/109068-how-to-load-files-identified-by-the-matlab-function-of-dir

    if ~isdir(folder)
        display('Unable to locate folder')
        return;
    end

    imageFiles = dir(fullfile(folder, '*.pgm'));
    names = cell(length(imageFiles), 1);
    images = cell(length(imageFiles), 1);

    for k = 1 : length(imageFiles)
        fullFileName = fullfile(folder, imageFiles(k).name);
        fprintf(1, 'Now reading %s\n', fullFileName);

        images{k} = imread(fullFileName);
        names{k} = imageFiles(k).name;
    end
end