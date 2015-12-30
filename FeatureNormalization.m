function handler = FeatureNormalization()
    handler.NormalizeAllFaces = @NormalizeAllFaces;
    handler.NormalizeDataInFolder = @NormalizeDataInFolder;
    handler.CalculateBestTransformation = @CalculateBestTransformation;
    handler.ProcessImage = @ProcessImage;
    handler.CalculateAffineTransform = @CalculateAffineTransform;
    handler.CreateFeatureMatrix = @CreateFeatureMatrix;
end

function NormalizeAllFaces()
    clc;
    clear all;
    close all;
    
    figure(),
    hold on
    [~, images, fileNames] = NormalizeDataInFolder();
    hold off

    for k = 1 : length(images)
        fileName = fileNames{k};
        fileName = upper(fileName(1:length(fileName)-4));
        
        if (mod(k, 5) < 3)
            imwrite(images{k}, strcat('training_images/', fileName, '.pgm'));
        else
            imwrite(images{k}, strcat('test_images/', fileName, '.pgm'));
        end
    end
end

function [features, images, fileNames] = NormalizeDataInFolder()
    % Reference:
    % http://www.mathworks.com/matlabcentral/answers/109068-how-to-load-files-identified-by-the-matlab-function-of-dir

    folder = 'all_faces/';
    if ~isdir(folder)
        display('Unable to locate folder')
        return;
    end

    featurePattern = fullfile(folder, '*.txt');
    featureFiles = dir(featurePattern);
    features = zeros(length(featureFiles), 10);
    fileNames = cell(length(featureFiles), 1);

    for k = 1 : length(featureFiles)
        fullFileName = fullfile(folder, featureFiles(k).name);
        fprintf(1, 'Now reading %s\n', fullFileName);
        featuresMatrix = load(fullFileName)';
        features(k, :) = featuresMatrix(:);
        display(size(featureFiles(k).name))
    end

    % Fixed facial features positions to be considered
    P1 = [13; 20];
    P2 = [50; 20];
    P3 = [34; 34];
    P4 = [16; 50];
    P5 = [48; 50];

    % Initial vector b to be used in Ax = b for feature normalization
    b0 = [P1; P2; P3; P4; P5];

    % Fixed image size
    blockSize = 64;

    % Calculate the affine transformation
    F = CalculateBestTransformation(features, b0, 0.01);

    imageFiles = dir(fullfile(folder, '*.jpg'));
    images = cell(length(imageFiles), 1);

    for k = 1 : length(imageFiles)
        fullFileName = fullfile(folder, imageFiles(k).name);
        fprintf(1, 'Now reading %s\n', fullFileName);
        I = im2double(rgb2gray(imread(fullFileName)));
        fileNames{k} = imageFiles(k).name;

        processedImage = ProcessImage(I, features(k, :), F, blockSize);
        images{k} = processedImage;
        %D(k, :) = processedImage(:)';
    end
end

function [Favg] = CalculateBestTransformation(features, b0, threshold)
    N = size(features, 2);
    Favg = features(1, :)';
    Fprev = Favg;

    repeat = true;
    iter = 0;
    while repeat
        FM = CreateFeatureMatrix(Favg);
        
        Favg = FM * CalculateAffineTransform(FM, b0);
        tmp = Favg;
        
        for i = 2 : N
            FM = CreateFeatureMatrix(features(i, :)');
            tmp = tmp + FM * CalculateAffineTransform(FM, Favg);
        end

        Favg = tmp ./ N;
       
        if ((abs(Favg - Fprev) < threshold))
            repeat = false;
        end

        Fprev = Favg;
        iter = iter + 1;
    end
end

function processedImage = ProcessImage(image, feature, F, blockSize)
    % Creating the spatial transformation structure
    % Reference : 
    % http://www.mathworks.com/help/images/ref/imtransform.html
    % http://blogs.mathworks.com/steve/2006/02/14/spatial-transformations-maketform-tformfwd-and-tforminv/
    FM = CreateFeatureMatrix(feature);
    transfMatrix = CalculateAffineTransform(FM, F);
    
    FEATURE = (FM * transfMatrix);
    plot(FEATURE(1), FEATURE(2), 'ok')
    plot(FEATURE(3), FEATURE(4), 'oy')
    plot(FEATURE(5), FEATURE(6), 'or')
    plot(FEATURE(7), FEATURE(8), 'ob')
    plot(FEATURE(9), FEATURE(10), 'oc')

    A = [transfMatrix(1) transfMatrix(2); transfMatrix(3) transfMatrix(4)];
    b = [transfMatrix(5) transfMatrix(6)];
    Ainv = pinv(A);

    newImage = zeros(blockSize, blockSize);
    for i = 1:size(newImage, 1)
        for j = 1:size(newImage, 2)
            p = Ainv * ([i j] - b)';
            x = floor(p(1));
            y = floor(p(2));

            if x > 0 && x <= size(image, 2) && y > 0 && y <= size(image, 1)
                newImage(j, i) = image(y, x);
            end
        end
    end
    
    processedImage = newImage;
end

function [x] = CalculateAffineTransform(A, b)    
    % Solving the system Ax = b to get the transformation matrix
    x = pinv(A) * b;
end

function A = CreateFeatureMatrix(features)
    % Determine the affine transformation matrix (A)
    A = zeros(10, 6);
    for i = 1:length(features)/2
        pos = 2*i - 1;
        A(pos, :) = [features(pos) features(pos + 1) 0 0 1 0];
        A(pos + 1, :) = [0 0 features(pos) features(pos + 1) 0 1];
    end
end