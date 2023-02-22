function L = operator_norm(w_regularization, w_tv, w_cross_curr, db_chs, sx)
    
    % computes the operator norm for a linear operator AS on images with size sx, 
    % which is the square root of the largest eigenvector of AS*A.
    % http://mathworld.wolfram.com/OperatorNorm.html

    vec_size = prod(sx);
    %Compute largest eigenvalue (in this case arnoldi, since matlab
    %implementation faster than power iteration)
    opts.tol = 1.e-3;
    opts.maxit = 50;
    lambda_largest = eigs(@(x)ASAfun(x, db_chs, sx, w_regularization, w_tv, w_cross_curr ), vec_size, 1,'LM', opts);
    L = sqrt(lambda_largest);

return;