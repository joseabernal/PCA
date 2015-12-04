function database = ApplyTransform(image, feature, F)
    % Fixed image size
    blockSize = 64;

    % Database of images. The size of this matrix is N x M where N is the
    % number of images and M the default image size.
    
    %database = zeros(length(images), blockSize * blockSize);

    % Creating the spatial transformation structure
    % Reference : 
    % http://www.mathworks.com/help/images/ref/imtransform.html
    % http://blogs.mathworks.com/steve/2006/02/14/spatial-transformations-maketform-tformfwd-and-tforminv/
    FM = CreateFeatureMatrix(feature);
    transfMatrix = CalculateAffineTransform(FM, F);
    
    %FEATURES = reshape(FM * transfMatrix, [5 2]);
    %plot(FEATURES(1, 1), FEATURES(1, 2), 'ok')
    %plot(FEATURES(2, 1), FEATURES(2, 2), 'oy')
    %plot(FEATURES(3, 1), FEATURES(3, 2), 'or')
    %plot(FEATURES(4, 1), FEATURES(4, 2), 'ob')
    %plot(FEATURES(5, 1), FEATURES(5, 2), 'oc')

    scale = [transfMatrix(1) transfMatrix(3) 0; transfMatrix(2) transfMatrix(4) 0];
    translation = [transfMatrix(5) transfMatrix(6) 1];
    ststruct = maketform('affine', [scale; translation]);
    display([scale; translation])
    IAff = imtransform(image, ststruct);
    
    database = IAff;
    imshow(IAff)
    pause(1)
end