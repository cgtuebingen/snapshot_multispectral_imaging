% This script computes the synthetic results of the
clear all;
close all;
clc;

%% load CFA
addpath('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab');
startup;
load('../../camera_calibration/camera_spectral_response_function.mat');
cfa_calibration_weights = c_six_bands;

%% normalize CFA
cfa_factor = repmat(sum(cfa_calibration_weights,1),[3 1]);
cfa_calibration_weights = cfa_calibration_weights./repmat(sum(cfa_calibration_weights,1),[3 1]);

resample = ceil(linspace(1,31,6));

%% load ring PSF
load('results/realworld/psf/psf_ring_par_1.mat','xsol_l2'); % demosaiced PSFs
load('../../camera_calibration/multispectral_scale_factor.mat');
for ch = 1:6
    %     psf(:,:,ch) = xsol_l2(882-20:882+20,585-20:585+20,ch)/s_six_bands(ch);
    psf(:,:,ch) = xsol_l2(36-20:36+20,35-20:35+20,ch)/s_six_bands(ch);
end
psf = psf/max(psf(:));

%% display PSFs
figure;
set(gcf, 'Position', [1 1 600 500]);
psf_limit = [0 0.1];
for ch = 1:6
    axes(ch) = subplot(1,6,ch);imshow(psf(:,:,ch)*100,'InitialMagnification', 'fit');
end

%% load single shot image
load('/graphics/projects/data/slm_camera/eccv_data/lego/ring/snapshot_lego_ring.mat');
y_full = imrotate(lego_ring, 90);
% y = y_full(487:487+100-1,737:737+100-1);
y = y_full;
y = y/max(y(:));

%% display input image
figure;
set(gcf, 'Position', [1200 1 600 500]);
imshow(y, 'InitialMagnification', 'fit'); title('Input image');
imagesc(y); colormap(gray); colorbar;
saveas(gcf, 'results/Input image.png');

% demosaiced input image
figure; set(gcf, 'Position', [1800 1 600 500]);
imshow(demosaic(uint8(255*y), 'rggb'), 'InitialMagnification', 'fit'); title('Demosaiced Image');

%% Operators
sx = size(y); % image size
% construct the operators
for ch = 1:6
    D{ch} = bayer2mat(sx, 'rggb', cfa_calibration_weights(:,ch));
    C{ch} = cnv2mat(psf(:,:,ch),sx,'same');
end

%% image optimization with least square fitting, TV and Sobolev priors
disp('Initialize parameters...');
ax{1} = D;
ax{2} = C;
ax{3} = 6;
ax{4} = y;
ax{5} = sx;
alpha = 0.0;
beta = 0.0;
lambda = 1.0;
ax{6} = alpha;
ax{7} = beta;
ax{8} = lambda;
Gx = grad2mat(2,[],'same');
G_tv = gradient_mat(sx(1));
ax{9} = Gx;
ax{10} = G_tv;
ax{11} = transpose(D);
ax{12} = transpose(C);
tol = 1e-12;
tol = 1e-12;
maxiter = 10000;
S = sprintf('Optimizing with least square fit and TV...');
disp(S);

xinit = rand([sx 6]);
lb = zeros(size(xinit));
ub = ones(size(xinit));

disp('Optimizing...');
tic % count computation time of optimization
xsol0 = lbfgsb(xinit(:), lb(:), ub(:), ...
    'obj_bayer_conv_fit_sobolev_tv_cross_ch_vec', 'calib_gradfun_gradx', ...
    ax, [], ...
    'maxiter', maxiter, ...
    'm', 3, ...
    'factr', tol, ...
    'pgtol', tol);
toc
xsol0 = reshape(xsol0, size(xinit));
xsol = xsol0;
figure;
set(gcf, 'Position', [1 1 4000 400]);
for ch = 1:6
    subplot(1,6,ch);
    imagesc(xsol(:,:,ch),[0 0.05]); title('Solved from fitting, single channel and global cross channel results'); colormap(gray); colorbar;
end


% %% denoising intermediate results
% 
% for ch = 1:6
%     [temp_psnr,xsol(:,:,ch)] = BM3D(xsol(:,:,ch),xsol0(:,:,ch),10,'np',0); % how to find the noise level?
% end
% figure;
% set(gcf, 'Position', [1 1 4000 400]);
% for ch = 1:6
%     subplot(1,6,ch);
%     imagesc(xsol(:,:,ch),[0 1]); title('Denoised intermediate results'); colormap(gray); colorbar;
% end
% 
% %% determin sharpest channel
% % gradient norm
%  Gx = grad2mat(2,[],'same');
% for ch = 1:6
%     gx = Gx*xsol(:,:,ch);
%     gradient_norm(ch) = (norm(gx{1},'fro')^2 + norm(gx{2},'fro')^2)/(sum(sum(abs(gx{1})))+sum(sum(abs(gx{2}))));
% end
% [val, it] = max(gradient_norm)
% % plot gradient norm
% figure;
% plot(1:6, gradient_norm, 'o-b'); title('Sharpness');
% 
% %% run the optimization with sharp reference
% for iter = 1:2
%     disp('Sharp reference optimization...');
%     clear ax;
%     ax = cell(1,9);
%     pad_size = [0 0];
%     ax{1} = D;
%     ax{2} = C;
%     ax{3} = 6;
%     ax{4} = y;
%     ax{5} = size(y);
%     alpha = 1e-4;
%     beta = 1e-4;
%     lambda = 1e-2;
%     ax{6} = alpha;
%     ax{7} = beta;
%     ax{8} = lambda;
%     Gx = grad2mat(2,[],'same');
%     G_tv = gradient_mat(sx(1));
%     ax{9} = xsol(:,:,it);
%     ax{10} = Gx;
%     ax{11} = G_tv;
%     ax{12} = transpose(D);
%     ax{13} = transpose(C);
%     try
%     xsol = lbfgsb(xsol(:), lb(:), ub(:), ...
%         'obj_bayer_conv_fit_sobolev_tv_crs_ref_vec', 'calib_gradfun_gradx', ...
%         ax, [], ...
%         'maxiter', maxiter, ...
%         'm', 3, ...
%         'factr', tol, ...
%         'pgtol', tol);
%     catch
%         warning('Cannot converge...');
%     end
%     
%     xsol = reshape(xsol, size(xinit));
%     for ch = 1:6
%         gx = Gx*xsol(:,:,ch);
%         gradient_norm(ch) = norm(gx{1},'fro')^2 + norm(gx{2},'fro')^2/(sum(sum(abs(gx{1})))+sum(sum(abs(gx{2}))));
%     end
% end
% 
%% Ground truth image
load('./results/realworld/lego/groundtruth.mat','xsol_l2');
load('../../camera_calibration/multispectral_scale_factor.mat');
for ch = 1:6
    gt_img(:,:,ch) = xsol_l2(:,:,ch)/s_six_bands(ch);
end
% 
%% Make directory
mkdir(strcat('results/realworld/real_psf_real_image/crop/'));
dir = strcat('results/realworld/real_psf_real_image/crop/');

% compute PSNR
disp('PSNR of the solution is');
for ch = 1:6
    PSNR(ch) = psnr(xsol(:,:,ch), gt_img(:,:,ch));
end
PSNR

%% Display solution with pixel-wise spectra
limit = [0,0.01];
figure;
set(gcf, 'Position', [1 1 4000 400]);
for ch = 1:6
    axes(ch)=subplot(1,6,ch);
    imagesc(gt_img(:,:,ch),limit); title('Ground Truth'); colormap(gray); axis image;
end
linkaxes(axes);
saveas(gcf, strcat(dir,'/Ground Truth Image spectra.png'));

figure;
set(gcf, 'Position', [1 600 4000 400]);
for ch = 1:6
    axes(ch) = subplot(1,6,ch);
    imagesc(xsol(:,:,ch),limit); colormap(gray); axis image;
%     title(strcat('Solution PSNR ', num2str(psnr(xsol(:,:,ch),gt_img(:,:,ch))))); colormap(gray); colorbar;
end
linkaxes(axes);
saveas(gcf, strcat(dir,'/Solution spectra.png'));

res_limit = [0,limit(2)*0.3];
figure;
set(gcf, 'Position', [1 1200 4000 400]);
for ch = 1:6
    subplot(1,6,ch);
    imagesc(abs(xsol(:,:,ch)-gt_img(:,:,ch)),res_limit); colormap(gray); title('Residual');
end
saveas(gcf, strcat(dir, '/Residual of solution spectra.png'));

%% Plot spectra
% compute spectra from results and ground truth images
gt_spectra0 = sum(sum(gt_img))/(sum(sum(sum(gt_img))));
gt_spectra_patch = sum(sum(gt_img(302:302+19,229:229+19,:)))/sum(sum(sum(gt_img(302:302+19,229:229+19,:))));
% compute spectra from one patch
for ch = 1:6
    gt_spectra(ch) = gt_spectra_patch(:,:,ch);
end
xsol_spectra0 = sum(sum(xsol))/sum(sum(sum(xsol)));
xsol_spectra_patch = sum(sum(xsol(302:302+19,229:229+19,:)))/sum(sum(sum(xsol(302:302+19,229:229+19,:)))); % paints
% compute spectra from one patch
for ch = 1:6
    xsol_spectra(ch) = xsol_spectra_patch(:,:,ch);
end
figure;
plot(resample, gt_spectra, 'o-r', resample, xsol_spectra, 'o-b');
axis([resample(1) resample(6) 0 1.0]);
legend('Ground Truth Spectra', 'Solution Spectra');
legend('Location','northeast');

saveas(gcf,strcat(dir,'/Spectra Comparison.png'));

%% Plot PSNR
figure;
plot(resample, PSNR, 'o-b'); title('PSNR vs Sample Wavelength');
saveas(gcf, strcat(dir,'/PSNR plot.png'));

%% display PSFs in one image
figure;
set(gcf, 'Position', [1 1 4000 400]);
psf_limit = [0 0.1];
for ch = 1:6
    subplot(1,6,ch); imagesc(psf(:,:,ch),psf_limit); colorbar;
end
saveas(gcf, strcat(dir,'/PSFs.png'));

close all;
save(strcat(dir,'/fulldata.mat'));
% toc