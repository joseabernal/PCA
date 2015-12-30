function handler = PCA()
    handler.PerformPCA = @PerformPCA;
    handler.FindBestMatches = @FindBestMatches;
end

function [Dreduced, U] = PerformPCA(D, k)
    Dnorm = zeros(size(D));
    
    meanImage = mean(D);
    for i = 1:size(D, 1)
        Dnorm(i, :) = (D(i, :) - meanImage);
    end

    S = (Dnorm' * D)/(size(D, 1));

    % For face recognition, k < 100 (suggested by the guide)
    [U, ~] = eigs(S, k);

    Dreduced = Dnorm * U;
end

function [bestMatches] = FindBestMatches(reducedTestImage, reducedD, k)
    bestEuc = Inf;
    values = zeros(size(reducedD, 1), 1);
    
    % Find the best match
    for j = 1 : size(reducedD, 1)
        euc = norm(reducedTestImage - reducedD(j, :));
        if (bestEuc > euc)
            bestEuc = euc;
        end
        values(j) = euc;
    end
    
    [~, i] = sort(values);
    bestMatches = i(1:k);
end