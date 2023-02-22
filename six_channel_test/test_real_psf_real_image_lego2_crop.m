% This script computes the synthetic results of the
clear all;
close all;
clc;

%% load CFA
addpath('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab');
startup;
load('../../camera_calibration/cs2000_measurement/analysis/cfa_measurement_cs2000.mat');

%% normalize CFA
cfa_factor = repmat(sum(cfa_calibration_weights,1),[3 1]);
cfa_calibration_weights = cfa_calibration_weights./repmat(sum(cfa_calibration_weights,1),[3 1]);
cfa_calibration_weights_sampled = cfa_calibration_weights(:,5:5:end);

resample = ceil(linspace(1,31,6));

%% load ring PSF
load('results/realworld/psf/psf_ring_normal.mat','xsol_l2'); % demosaiced PSFs
for ch = 1:6
    psf(:,:,ch) = xsol_l2(36-20:36+20,35-20:35+20,ch);
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
load('/graphics/projects/data/slm_camera/bmvc/scene/lego2/singleshot/ring_modulated.mat');
y_full = imrotate(ring_modulated, 90);
% y = y_full(515:1319,435:1239);
y = y_full(385:1184,475:1274);
% y = y_full(745:745+199,807:807+199);
y = y/(10*mean(y(:)));

%% TODO
% How to set normalization scale when there's a highlight

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
    D{ch} = bayer2mat(sx, 'rggb', cfa_calibration_weights_sampled(:,ch));
    C{ch} = cnv2mat(psf(:,:,ch),sx,'same');
end

%% image optimization with least square fitting, TV and Sobolev priors
disp('Initialize parameters...');
ax{1} = D;
ax{2} = C;
ax{3} = 6;
ax{4} = y;
ax{5} = sx;
alpha = 1.0e-2;
beta = 1.0e-2;
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
load('../mono_mosaiced_to_combined_rgb_lego2.mat','Xsol');
for ch = 1:6
%     gt(:,:,ch) = Xsol(587:787,733:933,(ch-1)*5+5);
    gt(:,:,ch) = Xsol(385:1184,475:1274,(ch-1)*5+5);
end

%% Make directory
mkdir(strcat('results/realworld/real_psf_real_image/crop/lego2_2/'));
dir = strcat('results/realworld/real_psf_real_image/crop/lego2_2/');

%% display comparison
weighting_psf = reshape(sum(sum(psf)),1,[]);
for ch = 1:6
    xsol(:,:,ch) = xsol(:,:,ch) * weighting_psf(ch);
end

%%
for ch = 1:6
    gt(:,:,ch) = gt(:,:,ch)/sum(sum(gt(100:end-100,100:end-100,ch)));
    xsol(:,:,ch) = xsol(:,:,ch)/sum(sum(xsol(100:end-100,100:end-100,ch)));
end
%%
figure;
for ch = 1:3
    subplot(2,3,ch); imshow(gt(:,:,ch)*1e5); title(strcat('Ground truth Channel ',num2str(ch)));
    if ch == 1
        subplot(2,3,ch+3); imshow(xsol(:,:,ch)*1e5); title(strcat('Solution Channel ',num2str(ch)));
    end
    subplot(2,3,ch+3); imshow(xsol(:,:,ch)*1e5); title(strcat('Solution Channel ',num2str(ch)));
end
figure;
for ch = 4:6
    subplot(2,3,ch-3); imshow(gt(:,:,ch)*1e5); title(strcat('Ground truth Channel ',num2str(ch)));
    subplot(2,3,ch); imshow(xsol(:,:,ch)*1e5); title(strcat('Solution Channel ',num2str(ch)));
end

% saveas(gcf,strcat(dir,'/Comparison gt and solution 2.png'));

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