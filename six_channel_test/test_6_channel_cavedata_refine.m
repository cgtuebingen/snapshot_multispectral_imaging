% This tests the 6 channel reconstruction with multispectral data from CAVE.
clear all;
close all;
clc;

% load data
addpath('/home/chenjiee/Projects/code_public/slm_camera/multispectral_deconvolution_matlab');
startup;

load('../sampled_cfa_weight_vendor.mat');
cfa_calibration_weights0 = cat(1,w_r,w_g,w_b);
cfa_calibration_weights0 = cfa_calibration_weights0./repmat(sum(cfa_calibration_weights0,1),[3 1]);
% resample cfa data to 6 channels
resample = ceil(linspace(1,31,6));
disp('CFA weight:');
cfa_calibration_weights = cfa_calibration_weights0(:,resample);

%% ring PSFs with 81x81 resolution
for ch = 1:6
    [X Y] = meshgrid(-40:40, -40:40);
    If0 = ((X.^2+Y.^2)<=(4*ch*10/6+1)^2) & ((X.^2+Y.^2)>=(4*ch*10/6)^2);
    psf(:,:,ch) = If0;
    psf(:,:,ch) = psf(:,:,ch)/sum(sum(psf(:,:,ch)));
end

%% display PSFs
figure;
set(gcf, 'Position', [1 1 600 500]);
psf_limit = [0 0.1];
for ch = 1:6
    % imshow(psf,'InitialMagnification', 'fit');
    imagesc(psf(:,:,ch),psf_limit); colorbar;
    pause(1);
end

%% synthesize images
sx = [512 512]; % image size
% construct the operators
for ch = 1:6
    D{ch} = bayer2mat(sx, 'rggb', cfa_calibration_weights(:,ch));
    C{ch} = cnv2mat(psf(:,:,ch),sx,'same');
end

%% load multispectral images from CAVE dataset
namelist{1} = 'balloons_ms';
namelist{2} = 'beads_ms';
namelist{3} = 'cd_ms';
namelist{4} = 'chart_and_stuffed_toy_ms';
namelist{5} = 'clay_ms';
namelist{6} = 'cloth_ms';
namelist{7} = 'egyptian_statue_ms';
namelist{8} = 'face_ms';
namelist{9} = 'fake_and_real_beers_ms';
namelist{10} = 'fake_and_real_food_ms';
namelist{11} = 'fake_and_real_lemon_slices_ms';
namelist{12} = 'fake_and_real_lemons_ms';
namelist{13} = 'fake_and_real_peppers_ms';
namelist{14} = 'fake_and_real_strawberries_ms';
namelist{15} = 'fake_and_real_sushi_ms';
namelist{16} = 'fake_and_real_tomatoes_ms';
namelist{17} = 'feathers_ms';
namelist{18} = 'flowers_ms';
namelist{19} = 'glass_tiles_ms';
namelist{20} = 'hairs_ms';
namelist{21} = 'jelly_beans_ms';
namelist{22} = 'oil_painting_ms';
namelist{23} = 'paints_ms';
namelist{24} = 'photo_and_face_ms';
namelist{25} = 'pompoms_ms';
namelist{26} = 'real_and_fake_apples_ms';
namelist{27} = 'real_and_fake_peppers_ms';
namelist{28} = 'sponges_ms';
namelist{29} = 'stuffed_toys_ms';
namelist{30} = 'superballs_ms';
namelist{31} = 'thread_spools_ms';
namelist{32} = 'watercolors_ms';

%%
% timing
tic
for iter_img = 23:23
    for ch = 1:6
        filename = strcat('/home/chenjiee/Documents/test_images/multispectral_images_from_CAVE/',namelist{iter_img},'/',namelist{iter_img},'/',namelist{iter_img});
        filename_n = sprintf('_%02d.png',resample(ch));
        filename = strcat(filename, filename_n);
        gt_img(:,:,ch) = double(imread(filename))/65535;
    end
    limit = [0,1];
    figure;
    set(gcf, 'Position', [1 1 4000 400]);
    for ch = 1:6
        subplot(1,6,ch);
        imagesc(gt_img(:,:,ch),limit); title('Ground Truth'); colormap(gray); colorbar;
    end
    
    %% input image simulation
    y = zeros(size(gt_img(:,:,1)));
    for ch = 1:6
        y = y + D{ch}*(C{ch}*gt_img(:,:,ch));
    end
    
    %% display ground truth image
    figure;
    set(gcf, 'Position', [600 1 600 500]);
    % imshow(gt_img, 'InitialMagnification', 'fit'); title('Ground truth image');
    for ch = 1:6
        imagesc(gt_img(:,:,ch)); colorbar;
    end
    
    %% display input image
    figure;
    set(gcf, 'Position', [1200 1 600 500]);
    % imshow(y, 'InitialMagnification', 'fit'); title('Input image');
    imagesc(y); colormap(gray); colorbar;
    saveas(gcf, 'results/Input image.png');
    
    %% demosaiced input image
    figure; set(gcf, 'Position', [1800 1 600 500]);
    imshow(demosaic(uint8(y), 'rggb'), 'InitialMagnification', 'fit'); title('Demosaiced Image');
    
    %% image optimization with least square fitting, TV and Sobolev priors
    tic
    disp('Initialize parameters...');
    ax{1} = D;
    ax{2} = C;
    ax{3} = 6;
    ax{4} = y;
    ax{5} = sx;
    alpha = 0.0;
    beta = 0.0;
    lambda = 5.0e-2;
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
    
    % xinit = ones([sx 6]);
    % xinit = cat(3, y, y, y);
    % xinit = gt_img;
    xinit = rand([sx 6]);
    % xinit = zeros([sx 6]);
    % xinit(:,:,3) = gt_img(:,:,3);
    lb = zeros(size(xinit));
    ub = ones(size(xinit));
    
    disp(strcat('Optimizing:',namelist{iter_img}));
    xsol0 = lbfgsb(xinit(:), lb(:), ub(:), ...
        'obj_bayer_conv_fit_sobolev_tv_cross_ch_vec', 'calib_gradfun_gradx', ...
        ax, [], ...
        'maxiter', maxiter, ...
        'm', 3, ...
        'factr', tol, ...
        'pgtol', tol);
    xsol0 = reshape(xsol0, size(xinit));
    %     xsol = xsol0(pad_size(1)+1:end-pad_size(1), pad_size(2)+1:end-pad_size(2),:);
    xsol = xsol0;
    for ch = 1:6
        gx = Gx*xsol(:,:,ch);
        gradient_norm(ch) = norm(gx{1},'fro')^2 + norm(gx{2},'fro')^2/(sum(sum(abs(gx{1})))+sum(sum(abs(gx{2}))));
    end
    
    %% Make directory
    mkdir(strcat('results/refinement/',namelist{iter_img}));
    dir = strcat('results/refinement/',namelist{iter_img});
    
    % compute PSNR
    disp('PSNR of the solution is');
    for ch = 1:6
        PSNR(ch) = psnr(xsol(:,:,ch), gt_img(:,:,ch));
    end
    PSNR
    
    %% Display solution with pixel-wise spectra
    limit = [0,1];
    figure;
    set(gcf, 'Position', [1 1 4000 400]);
    for ch = 1:6
        subplot(1,6,ch);
        imagesc(gt_img(:,:,ch),limit); title('Ground Truth'); colormap(gray); colorbar;
    end
    saveas(gcf, strcat(dir,'/Ground Truth Image spectra.png'));
    
    figure;
    set(gcf, 'Position', [1 600 4000 400]);
    for ch = 1:6
        axes(ch) = subplot(1,6,ch);
        imagesc(xsol(:,:,ch),limit); title(strcat('Solution PSNR ', num2str(psnr(xsol(:,:,ch),gt_img(:,:,ch))))); colormap(gray); colorbar;
    end
    linkaxes(axes);
    saveas(gcf, strcat(dir,'/Solution spectra.png'));
    
    res_limit = [0,0.3];
    figure;
    set(gcf, 'Position', [1 1200 4000 400]);
    for ch = 1:6
        subplot(1,6,ch);
        imagesc(abs(xsol(:,:,ch)-gt_img(:,:,ch)),res_limit); colorbar; title('Residual');
    end
    saveas(gcf, strcat(dir, '/Residual of solution spectra.png'));
    
    %% Plot spectra
    % compute spectra from results and ground truth images
    gt_spectra0 = sum(sum(gt_img))/(sum(sum(sum(gt_img))));
    %     gt_spectra_patch = sum(sum(gt_img(164:222,138:186,:)))/sum(sum(sum(gt_img(164:222,138:186,:))));
    %     gt_spectra_patch = sum(sum(gt_img(317:373,176:225,:)))/sum(sum(sum(gt_img(317:373,176:225,:))));
    %     gt_spectra_patch = sum(sum(gt_img(317:336,356:380,:)))/sum(sum(sum(gt_img(317:336,356:380,:))));
    %     gt_spectra_patch = sum(sum(gt_img(196:196+19,209:209+19,:)))/sum(sum(sum(gt_img(196:196+19,209:209+19,:))));
    gt_spectra_patch = sum(sum(gt_img(302:302+19,229:229+19,:)))/sum(sum(sum(gt_img(302:302+19,229:229+19,:))));
    % compute spectra from one patch
    for ch = 1:6
        gt_spectra(ch) = gt_spectra_patch(:,:,ch);
    end
    xsol_spectra0 = sum(sum(xsol))/sum(sum(sum(xsol)));
    %     xsol_spectra_patch =
    %     sum(sum(xsol(164:222,138:186,:)))/sum(sum(sum(xsol(164:222,138:186,:))));
    %     % balloons
    %     xsol_spectra_patch =
    %     sum(sum(xsol(317:373,176:225,:)))/sum(sum(sum(xsol(317:373,176:225,:))));
    %     % flowers
    %     xsol_spectra_patch =
    %     sum(sum(xsol(317:336,356:380,:)))/sum(sum(sum(xsol(317:336,356:380,:))));
    %     % stuffed toys
    %     xsol_spectra_patch = sum(sum(xsol(196:196+19,209:209+19,:)))/sum(sum(sum(xsol(196:196+19,209:209+19,:)))); % feather
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
    
    close all;
    save(strcat(dir,'/fulldata.mat'));
end
toc