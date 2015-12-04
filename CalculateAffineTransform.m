function [x] = CalculateAffineTransform(A, b)    
    %% Computing the svd and inverse
    [U, S, V] = svd(A);
    invA = V * pinv(S) * U';
    
    %% Solving the system Ax = b to get the trasnformation matrix
    x = invA * b;
end