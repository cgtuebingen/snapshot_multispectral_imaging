function error= obj_bayer_conv(x, ax)
% D ... bayering matrix
% y ... captured image (normalized)
% G ... gradient matrix
% alpha ... regularization weight
% x ... estimated image
% ncolors ... number of color channels
% C ... convolution matrix

D = ax{1}; 
y = ax{2}; % captured data 
G = ax{4};
alpha = ax{5};
xhs = reshape(x,ax{3});
ncolors = ax{3}(3);
greg = zeros(ax{3});
C = ax{6};
sz = size(D{1}*(C{1}*xhs(:,:,1)));
error = 0;
for col = 1:ncolors
%     M{col} = zeros(ax{3}(1:2));
    M{col} = zeros(sz);
    % accumulate data fitting matrix
    for ch = 1:ncolors
        if ch == col
            continue;
        end
        M_temp = D{ch}*(C{ch}*xhs(:,:,ch));
        % crop the central part
%         M_temp{col} = M_temp{col}((sz(1)-ax{3}(1))/2+1:(sz(1)+ax{3}(1))/2,(sz(2)-ax{3}(2))/2+1:(sz(2)+ax{3}(2))/2);
        M{col} = M{col}+M_temp;
    end
end

% I = zeros(ax{3}(1:2));
I = zeros(sz);
for col = 1:ncolors
    % image formation
    I_temp = D{col}*(C{col}*xhs(:,:,col));
%     I_temp = I_temp((sz(1)-ax{3}(1))/2+1:(sz(1)+ax{3}(1))/2,(sz(2)-ax{3}(2))/2+1:(sz(2)+ax{3}(2))/2);
    I = I + I_temp;
    g = G*xhs(:,:,col);
    reg = norm(g{1},'fro')^2 + norm(g{2},'fro')^2;
    greg(:,:,col) = G'* g; % gradient of regularizer
    error = error + alpha/2 * reg;
end
% crop I
I = I((sz(1)-ax{3}(1))/2+1:(sz(1)+ax{3}(1))/2,(sz(2)-ax{3}(2))/2+1:(sz(2)+ax{3}(2))/2);
error = error + 0.5*norm(I - y,'fro')^2; % least square data fitting 

yhat = zeros(sz);
yhat((sz(1)-ax{3}(1))/2+1:(sz(1)+ax{3}(1))/2,(sz(2)-ax{3}(2))/2+1:(sz(2)+ax{3}(2))/2) = y;
global gx; % gradient
gx = zeros(ax{3});
for col = 1:ncolors
    gx(:,:,col) = transpose(C{col})*(transpose(D{col})*M{col}) - transpose(C{col})*(transpose(D{col})*yhat) + ...
        transpose(C{col})*(transpose(D{col})*(D{col}*(C{col}*xhs(:,:,col)))) + greg(:,:,col);
end
gx = gx(:);
end