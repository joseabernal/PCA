clc;
close all;
clear all;

[names, images] = ReadDataset('training_images/');
D = zeros(length(images), size(images{1}, 1) * size(images{1}, 2));
    
for k = 1 : length(images)
    image = images{k};
    D(k, :) = im2double(image(:))';
end

PCAHandler = PCA;
k = 75; %we should iterate over this value according to sum^k(eigen)/sum^n(eigen) >= 95%
[reducedD, U] =  PCAHandler.PerformPCA(D, k);

%% test section
[testNames, testImages] = ReadDataset('test_images/');

errorCounter = 0;

for i = 1 : length(testImages)
    testImage = im2double(testImages{i});
    testImage = testImage(:)';

    % Reduce the testImage
    reducedTestImage = testImage * U;

    idx = PCAHandler.FindBestMatches(reducedTestImage, reducedD, 1);
    
    testName = testNames{i};
    testName = testName(1:length(testName)-6);
    name = names{idx};
    name = name(1:length(name)-6);
    
    if (strcmp(testName, name) == 0)
        errorCounter = errorCounter + 1;
    end
end

accuracy = (1 - errorCounter/length(testImages)) * 100;