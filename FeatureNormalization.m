function [Favg] = FeatureNormalization(features, b0, threshold)
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
       
        if (abs(Favg - Fprev) < threshold)
            repeat = false;
        end

        Fprev = Favg;
        iter = iter + 1;
    end
    display(iter)
end