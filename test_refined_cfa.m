% This script tests the refined spectral response function optimized using
% three multispectral dataset. I test the function by comparing the
% combination results using the refined and non-refined response function.
clear all;
close all;
clc;

%% load image data
[Xsol, I_rgb_gt] = load_spectral_imgs_rgb_gt('colorchecker');

%% load non-refined spectral response function
load('cfa_calibration_weights_vendor.mat');
cfa_calibration_weights_non = cfa_calibration_weights;
I_rgb_non = spectral_to_rgb_cam(Xsol, cfa_calibration_weights_non);

%% load refined spectral response function
load('refine_cfa.mat');
cfa_calibration_weights_refined = cfa_calibration_weights;
I_rgb = spectral_to_rgb_cam(Xsol, cfa_calibration_weights_refined);

%% display results
ilm_factor = 1e3;
figure;
axes(1)=subplot(1,3,1);imshow(I_rgb_gt*ilm_factor/30); title('Ground truth');
axes(2)=subplot(1,3,2);imshow(I_rgb_non*ilm_factor); title('Non-refined');
axes(3)=subplot(1,3,3);imshow(I_rgb*ilm_factor/30); title('Refined');
linkaxes(axes);
%% store results
save('test_refine_cfa.mat');