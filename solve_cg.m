function x = solve_cg(v, tau, chImg, channels, lambda_residual_cap)
    %Solves Ax = b with
    % A = (lambda_residual_cap*tau* M'* M + eye ) and b = tau * lambda_residual_cap * M' * b + f
    % Please refer to eq(7) in the paper
    
    %Right matrix side
    b = tau * 2*lambda_residual_cap .* observationMat(chImg, channels, -1) + v; 
    
    %Matrix
    Mfun = @(x) reshape( tau * 2*lambda_residual_cap .* observationMat( reshape(x,size(v)) , channels, 0  ) + reshape(x,size(v)), [], 1 );  

    %Solve
    warning off;
    [x, ~, ~, ~] = pcg( Mfun, b(:), 1e-12, 100, [], [], v(:) );
    warning on;
    
    %Reshape
    x = reshape( x, size(v) );

end