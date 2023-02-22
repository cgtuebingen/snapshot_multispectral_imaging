function I_rgb = spectral_to_rgb_cam(I, cfa_calibration_weights)

if nargin < 2
    %% compute rgb images of each channel from spectral images I
    % load camera spectral response function
    load('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab/camera_response/ccd_response_curve.mat');
    % resample the quantum efficiency
    cfa_calibration_weights_r = qe_r(11:10:end-25);
    cfa_calibration_weights_g = qe_g(11:10:end-25);
    cfa_calibration_weights_b = qe_b(11:10:end-25);
    cfa_calibration_weights = [cfa_calibration_weights_r;cfa_calibration_weights_g;cfa_calibration_weights_b];
end

%% compute RGB images
for ch = 1:32
    I_r(:,:,ch) = cfa_calibration_weights(1,ch) * I(:,:,ch);
    I_g(:,:,ch) = cfa_calibration_weights(2,ch) * I(:,:,ch);
    I_b(:,:,ch) = cfa_calibration_weights(3,ch) * I(:,:,ch);
end

I_r = sum(I_r,3);
I_g = sum(I_g,3);
I_b = sum(I_b,3);

I_rgb = cat(3, I_r,I_g,I_b);

end