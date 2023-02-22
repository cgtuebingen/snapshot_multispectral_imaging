function [error,gx] = test_fun_scale_factor_sobolev(x, ax)
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

%% compute Sobolev error
G = grad2mat([],[],'same',[],'');
gradx = G*cfa_calibration_weights;
lambda = 1e-2;
for hv = 1:2
	error = error + 0.5* lambda * norm(reshape(gradx{hv},[],1), 'fro')^2;
end

%% calculate gradient
global gx;
gx = (transpose(cfa_calibration_weights)*transpose(I)-transpose(I_rgb_gt))*I + ... 
    reshape(lambda * (G'*(G*cfa_calibration_weights)),1,[]);

gx = reshape(gx,[],1);

end