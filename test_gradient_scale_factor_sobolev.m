% This script validates the gradient of the objective of scale factor. It
% loads data of multispectral images and spectral response function. It
% calls the checkgrad function.
clear all;
close all;
clc;
startup

%% load camera spectral response function
resp_scale = 20;
load('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab/camera_response/ccd_response_curve.mat');
% resample the quantum efficiency
cfa_calibration_weights_r = qe_r(11:10:end-25);
cfa_calibration_weights_g = qe_g(11:10:end-25);
cfa_calibration_weights_b = qe_b(11:10:end-25);
cfa_calibration_weights = [cfa_calibration_weights_r;cfa_calibration_weights_g;cfa_calibration_weights_b];
cfa_r = reshape(cfa_calibration_weights_r*resp_scale,[],1);

%% load spectral images, single shot RGB capture
load('mono_mosaiced_to_combined_rgb_lego2.mat');

%% load ground truth
DIR_RGB = '/graphics/projects/data/slm_camera/bmvc/scene/lego/singleshot/';
FILENAME_RGB = strcat('non_modulated.mat');
load(strcat(DIR_RGB, FILENAME_RGB));
non_modulated = imrotate(non_modulated, 90);
I_rgb_gt = double(demosaic(uint16(non_modulated*65535),'rggb'))/65535;

%% call checkgrad to check the gradient function
ax{1} = Xsol;
ax{2} = I_rgb_gt(:,:,1);
tol = 1e-12;
lb = zeros(size(cfa_r));
ub = max(cfa_r)*ones(size(cfa_r));
maxiter = 2;

e = 1e-4;
xinit = rand(size(cfa_r));
d = checkgrad('test_fun_scale_factor_sobolev', xinit(:), e, ax)