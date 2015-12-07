function A = CreateFeatureMatrix(features)
    %% Determine the affine transformation matrix (A)
    A = zeros(10, 6);
    for i = 1:length(features)/2
        pos = 2*i - 1;
        A(pos, :) = [features(pos) features(pos + 1) 0 0 1 0];
        A(pos + 1, :) = [0 0 features(pos) features(pos + 1) 0 1];
    end
end