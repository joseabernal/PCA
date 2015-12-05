function processedImage = ProcessImage(image, feature, F, blockSize)
    % Database of images. The size of this matrix is N x M where N is the
    % number of images and M the default image size.
    
    %database = zeros(length(images), blockSize * blockSize);

    % Creating the spatial transformation structure
    % Reference : 
    % http://www.mathworks.com/help/images/ref/imtransform.html
    % http://blogs.mathworks.com/steve/2006/02/14/spatial-transformations-maketform-tformfwd-and-tforminv/
    FM = CreateFeatureMatrix(feature);
    transfMatrix = CalculateAffineTransform(FM, F);
    
    FEATURES = (FM * transfMatrix);
    plot(FEATURES(1), FEATURES(2), 'ok')
    plot(FEATURES(3), FEATURES(4), 'oy')
    plot(FEATURES(5), FEATURES(6), 'or')
    plot(FEATURES(7), FEATURES(8), 'ob')
    plot(FEATURES(9), FEATURES(10), 'oc')

    scale = [transfMatrix(1) transfMatrix(3) 0; transfMatrix(2) transfMatrix(4) 0];
    translation = [transfMatrix(5) transfMatrix(6) 1];
    ststruct = maketform('affine', [scale; translation]);
    IAff = imtransform(image, ststruct, 'Size', [blockSize blockSize]);
    
    processedImage = IAff;
end