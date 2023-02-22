function [error, gradx, M] = obj_bayer_conv_fit_sobolev_tv_cross_ch_vec(x, ax)
% function error = obj_bayer_conv_fit_sobolev_tv_cross_ch_vec(x, ax)
% The analytic calculated gradient function is false.
% Therefore the gradient matching tests fail.

% D ... Bayering/Mosaicing matrix
% C ... Convolution matrix
% y ... Snapshot image
% x ... Estimated images
% ncolors ... Number of color channels

D = ax{1};
C = ax{2};
ncolors = ax{3};
y = ax{4};
sx = ax{5};
alpha = ax{6};
beta = ax{7};
lambda = ax{8};
Gx = ax{9};
G_tv = ax{10};
D_t = ax{11};
C_t = ax{12};
xhs = reshape(x,[sx ncolors]);
error = 0;
% M = cell(1,ncolors);
M = zeros([sx ncolors]);
M_c = zeros([sx ncolors]);
I = zeros(sx);
global gradx; % gradient function
gradx = zeros([sx ncolors]);

for col = 1:ncolors
    M_c(:,:,col) = D{col}*(C{col}*xhs(:,:,col));
end

I = sum(M_c,3);

for col = 1:ncolors
    M(:,:,col) = I - M_c(:,:,col);
end

% for col = 1:ncolors
%     if col == 1
%         M(:,:,1) = sum(M_c(:,:,2:end),3);
%         continue;
%     end
%     if col == ncolors
%         M(:,:,ncolors) = sum(M_c(:,:,1:ncolors-1),3);
%         continue;
%     end
%     M(:,:,col) = sum(M_c(:,:,1:col-1),3) + sum(M_c(:,:,col+1:end),3);
% end
    
error = error + 0.5*norm(I - y, 'fro')^2; % least square data fitting

% Single channel Sobolev prior
greg_l2 = zeros(size(xhs));
for col = 1:ncolors
    g = Gx*xhs(:,:,col);
    g_l2 = norm(g{1},'fro')^2 + norm(g{2},'fro')^2;
    greg_l2(:,:,col) = greg_l2(:,:,col) + Gx'*g; % gradient of regularizer
    error = error + 0.5 * alpha * g_l2;
end

% TV (smooth edges) regularizer
gx_sgn_x = cell(1,6);
gx_sgn_y = cell(1,6);
gx = cell(1,2);
for col = 1:ncolors
    
    for hv = 1:2
        gx{hv} = G_tv{hv}*reshape(xhs(:,:,col),[],1);
        error = error + beta * sum(abs(gx{hv}));
    end
    
    gx_sgn_x{col} = sign(gx{1});
    gx_sgn_y{col} = sign(gx{2});
end

% cross channel prior
greg_crs_ch_sing = zeros([ax{5} ncolors]);
for ch = 1:ncolors
    error_crs = 0;
    x_curr = xhs(:,:,ch);
    g{1} = reshape(G_tv{1}*reshape(x_curr,[],1),sx); % gradient of current channel
    g{2} = reshape(G_tv{2}*reshape(x_curr,[],1),sx); % gradient of current channel
    for iter = 1:ncolors
        if ( (ch == iter) )
            continue;
        end
        x_nb = xhs(:,:,iter);
        % x direction
        g_x_nb{1} = reshape(G_tv{1}*reshape(x_nb,[],1),sx); % compute gradient of the neighbor channel
        error_crs = error_crs + sum(abs(vec(g_x_nb{1}.*x_curr)-vec(g{1}.*x_nb)));
        sgn_mask_x = sign((-g{1}.*x_nb+g_x_nb{1}.*x_curr));
        
        % gradient of current channel
        greg_crs_ch_sing(:,:,ch) = greg_crs_ch_sing(:,:,ch) + (sgn_mask_x.*g_x_nb{1} - reshape(G_tv{1}'*reshape(sgn_mask_x.*x_nb,[],1),sx));
        
        % gradient of neighbor channels
        greg_crs_ch_sing(:,:,iter) = greg_crs_ch_sing(:,:,iter) + (-sgn_mask_x.*g{1} + reshape(G_tv{1}'*reshape(sgn_mask_x.*x_curr,[],1),sx));
        
        % y direction
        g_x_nb{2} = reshape(G_tv{2}*reshape(x_nb,[],1),sx); % compute gradient of the neighbor channel
        error_crs = error_crs + sum(abs(vec(g_x_nb{2}.*x_curr)-vec(g{2}.*x_nb)));
        sgn_mask_y = sign((-g{2}.*x_nb+g_x_nb{2}.*x_curr));
        
        % gradient of current channel
        greg_crs_ch_sing(:,:,ch) = greg_crs_ch_sing(:,:,ch) + (sgn_mask_y.*g_x_nb{2} - reshape(G_tv{2}'*reshape(sgn_mask_y.*x_nb,[],1),sx));
        
        % gradient of neighbor channels
        greg_crs_ch_sing(:,:,iter) = greg_crs_ch_sing(:,:,iter) + (-sgn_mask_y.*g{2} + reshape(G_tv{2}'*reshape(sgn_mask_y.*x_curr,[],1),sx));
    end
    error = error + lambda * error_crs;
end

temp_mat = M_c - cat(3,y,y,y,y,y,y) + M;
for col = 1:ncolors
    gradx(:,:,col) = C_t{col}*(D_t{col}*(temp_mat(:,:,col)));
    gradx(:,:,col) = gradx(:,:,col) + beta * reshape(G_tv{1}'*gx_sgn_x{col},sx);
    gradx(:,:,col) = gradx(:,:,col) + beta * reshape(G_tv{2}'*gx_sgn_y{col},sx);
end
gradx = gradx + alpha * greg_l2;
% for col = 1:ncolors
%     xs = xhs(:,:,col);
%     gradx(:,:,col) = alpha * greg_l2(:,:,col) + ...
%         transpose(C{col})*(transpose(D{col})*(D{col}*(C{col}*xs))) - transpose(C{col})*(transpose(D{col})*y) + ...
%         transpose(C{col})*(transpose(D{col})*M(:,:,col));
%     gradx(:,:,col) = gradx(:,:,col) + beta * reshape(G_tv{1}'*gx_sgn_x{col},sx);
%     gradx(:,:,col) = gradx(:,:,col) + beta * reshape(G_tv{2}'*gx_sgn_y{col},sx);
% end
gradx = gradx + lambda * greg_crs_ch_sing;
gradx = reshape(gradx,[],1);

