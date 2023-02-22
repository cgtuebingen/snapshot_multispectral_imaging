function error = calib_objfun(x, ax)
% A ... image formation matrix
% y ... captured image (normalized)
% G ... gradient matrix
% alpha ... regularization weight
% x ... estimated image
% ncolors ... number of color channels

D = ax{1};
y = ax{2}; % captured data 
G = ax{4};
alpha = ax{5};
x = reshape(x,ax{3}(1:2));
ncolors = ax{3}(3);
error = 0.5*norm(D*x - y,'fro')^2;
g = G*x;
reg = norm(g{1},'fro')^2 + norm(g{2},'fro')^2;
greg = G'* g; % gradient of regularizer
error = error + alpha/2 * reg;

global gx; % gradient 
gx = (transpose(D)*(D*x) - transpose(D)*y) + alpha * greg;
gx = gx(:);