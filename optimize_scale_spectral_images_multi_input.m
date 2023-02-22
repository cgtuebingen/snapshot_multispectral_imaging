% This script optimizes the scaling factor to combine spectral images into
% one RGB image. I first test the factor with one channel(R) and one set of
% images. It takes three sets of multispectral images as input.
clear all;
close all;
clc;
startup;

%% load spectral images, single shot RGB capture from dataset 1
[Xsol, I_rgb_gt] = load_spectral_imgs_rgb_gt('lego2');

%% output to optimization parameters
ax{1} = Xsol;
ax{2} = I_rgb_gt(:,:,1);

%% load spectral images, single shot RGB capture from dataset 2
[Xsol, I_rgb_gt] = load_spectral_imgs_rgb_gt('colorchecker');

%% output to optimization parameters
ax{3} = Xsol;
ax{4} = I_rgb_gt(:,:,1);

%% load spectral images, single shot RGB capture from dataset 3
[Xsol, I_rgb_gt] = load_spectral_imgs_rgb_gt('angel');

%% output to optimization parameters
ax{5} = Xsol;
ax{6} = I_rgb_gt(:,:,1);

%% load camera spectral response function
resp_scale = 20;
load('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab/camera_response/ccd_response_curve.mat');
% resample the quantum efficiency
cfa_calibration_weights_r = qe_r(11:10:end-25);
cfa_calibration_weights_g = qe_g(11:10:end-25);
cfa_calibration_weights_b = qe_b(11:10:end-25);
cfa_calibration_weights = [cfa_calibration_weights_r;cfa_calibration_weights_g;cfa_calibration_weights_b];
cfa_r = cfa_calibration_weights_r*resp_scale;

tol = 1e-12;
lb = zeros(size(cfa_r));
ub = max(cfa_r)*ones(size(cfa_r));
maxiter = 3;

xsol = lbfgsb(cfa_r, lb(:), ub(:), ...
    'obj_scale_factor_multi_input', 'calib_gradfun', ...
    ax, [], ...
    'maxiter', maxiter, ...
    'm', 3, ...
    'factr', tol, ...
    'pgtol', tol);
