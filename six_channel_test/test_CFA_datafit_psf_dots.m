% This script tests the debayedots restoration using least square fitting.
% The experiment is performed on data of spectralon sphere images, lego
% monochromatic images and dots monochromatic dots PSFs.
clear all;
close all;
clc;
addpath('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab/');
ncolors = 6;

%% load CFA weights
load('/home/chenjiee/Projects/code_public/slm_camera/camera_calibration/cs2000_measurement/analysis/cfa_tf_measurement.mat');
cfa_calibration_weights = transformation./repmat(sum(transformation,1),[3 1]);

% rescale the old light source profile
load('../../camera_calibration/light_source_spd.mat');
wavelength_ls = 380:1:780;

% load spectra of broadband spectralon sphere
filename = '~/Projects/code_public/slm_camera/camera_calibration/cs2000_measurement/results/spectralon/broadband.csv';
spectra_broad_spectralon = read_cs2000_csv(filename, 0);

weight_ls = ls_spd_mean(31:10:310+31)./spectra_broad_spectralon(31:10:310+31);
weight_ls = repmat(weight_ls/max(max(max(weight_ls))),[3 1]);
cfa_calibration_weights = cfa_calibration_weights.*weight_ls;
cfa_calibration_weights_sampled = cfa_calibration_weights(:,5:5:end);

%% load monochromatic measurement
for ch = 1:ncolors
    PATH_TO_IMAGES = '/graphics/projects/data/slm_camera/eccv_data/psf/dots/';
    FILENAME = strcat('mono_psf_dots_',num2str(ch-1),'.mat');
    load([PATH_TO_IMAGES FILENAME]);
    if ch == 6
        mono_psf_dots_six_bands(:,:,1) = imrotate(mono_psf,90);
    else
        mono_psf_dots_six_bands(:,:,ch+1) = imrotate(mono_psf,90);
    end
end
img_size = size(mono_psf);

ll = [847, 551];
psf_size = [71 71];
figure;
imshow(mono_psf_dots_six_bands(ll(1):ll(1)+psf_size(1)-1,ll(2):ll(2)+psf_size(2)-1,6)*1e7);

%% normalize image by the peak value
% mono_psf_dots_six_bands_norm = mono_psf_dots_six_bands/max(mono_psf_dots_six_bands(:));

%% matrix operator
mono_psf_dots_six_bands_norm = mono_psf_dots_six_bands(ll(1):ll(1)+psf_size(1)-1,ll(2):ll(2)+psf_size(2)-1,:);
D = {ncolors};
for col = 1:ncolors
    D{col} = bayer2mat(psf_size,'rggb',cfa_calibration_weights_sampled(:,col));
end
% display image
% for ch = 1:ncolors
%     figure; imshow(demosaic(uint16(mono_spectralon_six_bands_norm(:,:,ch)/max(max(mono_spectralon_six_bands_norm(:,:,ch)))*65535),'rggb')*1e5);
% end

%% optimization with single channel data fitting
% for ch = 1:ncolors
%     ax{1} = D;
%     ax{2} = ncolors;
%     ax{3} = mono_spectralon_six_bands_norm(:,:,ch);
%     ax{4} = img_size;
%     tol = 1e-5;
%     maxiter = 100000;
%     xinit = mono_spectralon_six_bands_norm(:,:,ch); % initialization with denoised naive solution
% 
%     % call lbfgsb
%     lb = zeros(size(xinit));
%     ub = ones(size(xinit)); % upper bound of the optimized result
%     try
%         xsol = lbfgsb(xinit(:), lb(:), ub(:), ...
%             'obj_debayer_fit_single_ch', 'calib_gradfun', ...
%             ax, [], ...
%             'maxiter', maxiter, ...    % max iterations
%             'm', 3, ...         % smaller means faster iterations
%             'factr',tol, ...   % convergence condition
%             'pgtol',tol);      % tolerance of proj gradient
%     catch
%         warning('Solver unable to converge. Assigning solution to be 0.');
%         xsol = zeros(img_size);
%     end
%     xsol = reshape(xsol,size(xinit));
%     xsol_six_bands{ch} = xsol;
% end

%% optimization with multiple channel data fitting and l2
G = grad2mat([],[],'same',[],''); % Construct gradient matrix
alpha = 1;
ax{1} = D;
ax{2} = mono_psf_dots_six_bands_norm;
ax{3} = [size(mono_psf_dots_six_bands_norm(:,:,1)) ncolors];
ax{4} = G;
ax{5} = alpha;
tol = 1e-12;
maxiter = 100000;
% xinit = mono_spectralon_six_bands;
xinit = ones([size(mono_psf_dots_six_bands_norm(:,:,1)) ncolors]);

% call lbfgsb
lb = zeros(size(xinit));
ub = ones(size(xinit)); % upper bound of the optimized result
% try
    xsol_l2 = lbfgsb(xinit(:), lb(:), ub(:), ...
        'calib_objfun_multi_ch_l2', 'calib_gradfun_gx', ...
        ax, [], ...
        'maxiter', maxiter, ...    % max iterations
        'm', 3, ...         % smaller means faster iterations
        'factr',tol, ...   % convergence condition
        'pgtol',tol);      % tolerance of proj gradient
% catch
%     warning('Solver unable to converge. Assigning solution to be 0.');
%     xsol_l2 = zeros([img_size ncolors]);
% end
xsol_l2 = reshape(xsol_l2,size(xinit));

%% display results
figure
for ch = 1:ncolors
    axes(ch) = subplot(1,ncolors,ch); imagesc(xsol_l2(:,:,ch)); axis image;
end
linkaxes(axes);

%% save results
save('results/realworld/psf/psf_dots_normal.mat');
