function error = test_decnv_multi_ch_objfun(x)

global ax;
% Auxillary data
C = ax{1};
y = ax{2};
sx = ax{3};
G = ax{4};
alpha = ax{5};
x = reshape(x, [sx 5]);

% Objective function
dataft = C{1}*x(:,:,1);
gxhs = G*x(:,:,1);
greg = norm(gxhs{1},'fro')^2 + norm(gxhs{2},'fro')^2;
for col = 2:size(x,3) % iterate color channel
    dataft = dataft + (C{col}*x(:,:,col));
    gxhs = G*x(:,:,col);
    greg = greg + norm(gxhs{1},'fro')^2 + norm(gxhs{2},'fro')^2;
end
dataft = dataft - y;

global gx;
e = 1e-7;
gx = Grad('test_fun', reshape(x, [size(x,1)*size(x,2)*size(x,3),1]), e, ax{1}, ax{2}, ax{3}, ax{4}, ax{5});

dataft = norm(dataft,'fro');
error = dataft + alpha*greg;