function error = obj_scale_factor_multi_input(x, ax)
%% get cfa weights, variables to be optimized
cfa_calibration_weights = reshape(x,32,1); % 32x1

%% get spectral images from dataset 1
I1 = reshape(ax{1},[],32); % Nx32

%% get RGB capture from dataset 1
I_rgb_gt1 = reshape(ax{2},[],1); % Nx1

%% compute RGB image from spectral images from dataset 1
I_rgb1 = I1*cfa_calibration_weights;

%% get spectral images from dataset 2
I2 = reshape(ax{3},[],32); % Nx32

%% get RGB capture from dataset 2
I_rgb_gt2 = reshape(ax{4},[],1); % Nx1

%% compute RGB image from spectral images from dataset 2
I_rgb2 = I2*cfa_calibration_weights;

%% get spectral images from dataset 3
I3 = reshape(ax{5},[],32); % Nx32

%% get RGB capture from dataset 3
I_rgb_gt3 = reshape(ax{6},[],1); % Nx1

%% compute RGB image from spectral images from dataset 3
I_rgb3 = I3*cfa_calibration_weights;

%% compute error
error = 0.5*norm(I_rgb1-I_rgb_gt1,'fro')^2 + 0.5*norm(I_rgb2-I_rgb_gt2,'fro')^2 + ...
    0.5*norm(I_rgb3-I_rgb_gt3,'fro')^2;

%% calculate gradient
global gx;
gx = (transpose(cfa_calibration_weights)*transpose(I1)-transpose(I_rgb_gt1))*I1 + ...
    (transpose(cfa_calibration_weights)*transpose(I2)-transpose(I_rgb_gt2))*I2 + ...
    (transpose(cfa_calibration_weights)*transpose(I3)-transpose(I_rgb_gt3))*I3;

end