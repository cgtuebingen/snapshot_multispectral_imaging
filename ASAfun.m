function ASAx = ASAfun(x, db_chs, sx, w_regularization, w_tv, w_cross_curr )
% This function compute the matrix multiplication of KT * K which further
% can be used for computing matrix norm.
    x_img = reshape(x,sx);
    ASAx = KmultT_channels(Kmult_channels(x_img, db_chs, w_tv, w_cross_curr, w_regularization), db_chs, ... 
        w_tv, w_cross_curr, w_regularization);
    ASAx = ASAx(:);
return