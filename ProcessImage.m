function processedImage = ProcessImage(image, feature, F, blockSize)
    % Creating the spatial transformation structure
    % Reference : 
    % http://www.mathworks.com/help/images/ref/imtransform.html
    % http://blogs.mathworks.com/steve/2006/02/14/spatial-transformations-maketform-tformfwd-and-tforminv/
    FM = CreateFeatureMatrix(feature);
    transfMatrix = CalculateAffineTransform(FM, F);
    
    FEATURE = (FM * transfMatrix);
    %plot(FEATURE(1), FEATURE(2), 'ok')
    %plot(FEATURE(3), FEATURE(4), 'oy')
    %plot(FEATURE(5), FEATURE(6), 'or')
    %plot(FEATURE(7), FEATURE(8), 'ob')
    %plot(FEATURE(9), FEATURE(10), 'oc')

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
    
    %imshow(newImage);
    processedImage = newImage;
end
