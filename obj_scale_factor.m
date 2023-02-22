function error = obj_scale_factor(x, ax)
%% get spectral images
I = reshape(ax{1},[],32); % Nx32

%% get RGB capture
I_rgb_gt = reshape(ax{2},[],1); % Nx1

%% get cfa weights, variables to be optimized
cfa_calibration_weights = reshape(x,32,1); % 32x1

%% compute RGB image from spectral images
I_rgb = I*cfa_calibration_weights;

%% compute error
error = 0.5*norm(I_rgb-I_rgb_gt,'fro')^2;

%% calculate gradient
global gx;
gx = (transpose(cfa_calibration_weights)*transpose(I)-transpose(I_rgb_gt))*I;

end