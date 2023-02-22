% This script optimizes the scaling factor to combine spectral images into
% one RGB image. I first test the factor with one channel(R) and one set of
% images.
clear all;
close all;
clc;
startup;

%% load spectral images, single shot RGB capture
load('mono_mosaiced_to_combined_rgb_lego2.mat');

%% load ground truth
DIR_RGB = '/graphics/projects/data/slm_camera/bmvc/scene/lego/singleshot/';
FILENAME_RGB = strcat('non_modulated.mat');
load(strcat(DIR_RGB, FILENAME_RGB));
non_modulated = imrotate(non_modulated, 90);
I_rgb_gt = double(demosaic(uint16(non_modulated*65535),'rggb'))/65535;

%% load camera spectral response function
resp_scale = 20;
load('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab/camera_response/ccd_response_curve.mat');
% resample the quantum efficiency
cfa_calibration_weights_r = qe_r(11:10:end-25);
cfa_calibration_weights_g = qe_g(11:10:end-25);
cfa_calibration_weights_b = qe_b(11:10:end-25);
cfa_calibration_weights = [cfa_calibration_weights_r;cfa_calibration_weights_g;cfa_calibration_weights_b];
cfa_r = cfa_calibration_weights_r*resp_scale;

%% optimization of response function
ax{1} = Xsol;
ax{2} = I_rgb_gt(:,:,1);
tol = 1e-12;
lb = zeros(size(cfa_r));
ub = max(cfa_r)*ones(size(cfa_r));
maxiter = 2;

xsol = lbfgsb(cfa_r, lb(:), ub(:), ...
    'obj_scale_factor', 'calib_gradfun', ...
    ax, [], ...
    'maxiter', maxiter, ...
    'm', 3, ...
    'factr', tol, ...
    'pgtol', tol);
