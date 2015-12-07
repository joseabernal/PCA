function [x] = CalculateAffineTransform(A, b)    
    %% Solving the system Ax = b to get the trasnformation matrix
    x = pinv(A) * b;
end