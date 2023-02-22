function y = prox_wrap(y, gamma, ProxBM3D, ProxL1)
% This function wrap up the proximal term of internal denoising, TV, and
% cross-channel regularization.
    y_curr = y;
    i = 0; % count of regularization term
    %% Regularization L1    
    i = i + 1;
    for ch = 1:length(y)
       y{ch}(:,:,i:i+1) = ProxL1( y_curr{ch}(:,:,i:i+1) ); 
    end
    i = i + 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Regularization denoising
    i = i + 1;
    %get image
    v_img = [];
    for ch = 1:length(y)
        v_img = cat(3, v_img, y_curr{ch}(:,:,i));
    end
    %get prox
    [NA, prox_denoise] = ProxBM3D(v_img, gamma);
%     prox_bm3d = zero(size(v_img,1:2));
    %insert
    for ch = 1:length(y)
       y{ch}(:,:,i) = prox_denoise(:,:,ch); 
    end
    %% Regularization Cross-channel
    i = i + 1;
    for ch = 1:length(y)
       y{ch}(:,:,i:end) = ProxL1( y_curr{ch}(:,:,i:end) ); 
    end
end