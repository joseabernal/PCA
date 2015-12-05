clc
clear all

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

for k = 1 : length(featureFiles)
    fullFileName = fullfile(folder, featureFiles(k).name);
    fprintf(1, 'Now reading %s\n', fullFileName);
    featuresMatrix = load(fullFileName)';
    features(k, :) = featuresMatrix(:);
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
F = FeatureNormalization(features, b0, 0.01);

imageFiles = [dir(fullfile(folder, '*.jpg')); dir(fullfile(folder, '*.JPG'))];
images = zeros(length(imageFiles), 320, 320);
D = zeros(length(imageFiles), blockSize*blockSize);

figure(),
hold on
for k = 1 : length(imageFiles)
    fullFileName = fullfile(folder, imageFiles(k).name);
    fprintf(1, 'Now reading %s\n', fullFileName);
    I = im2double(rgb2gray(imread(fullFileName)));
    images(k, 1:size(I, 1), 1:size(I, 2)) = I;
    
    processedImage = ProcessImage(I, features(k, :), F, blockSize);
    D(k, :) = processedImage(:)';
end

%% Database normalization and reduction

for i = 1:size(D, 2)
    Dnorm(:, i) = D(:, i) - mean(D(:, i));
end

S = cov(Dnorm);

% For face recognition, k < 100 (suggested by the guide)
k = 75; %we should iterate over this value according to sum^k(eigen)/sum^n(eigen) >= 95%
[U, V] = eigs(S, k);

reducedD = Dnorm * U;

%% test section
for i = 1 : 5
    testImage = D(i*10, :);
    testImage = (testImage - mean(testImage));

    % Reduce the testImage
    reducedTestImage = testImage * U;

    bestFace = 0;
    bestEuc = Inf;
    values = zeros(1, size(D, 1));
    
    % Find the best match
    for j = 1:size(D, 1)
        euc = norm(reducedTestImage - reducedD(j, :));
        if (bestEuc > euc)
            bestFace = j;
            bestEuc = euc;
        end
        values(j) = euc;
    end
    
    display([bestFace i*10])
end