% This algorithm is an implementation of FlexISP:A Flexible Camera Image Processing Framework by Felix Heide et al. 

clear all;
close all;
clc;

addpath('./adds/gabrielPeyre/');
addpath('./adds/BM3D/');
%% configurations
% cfa pattern
conf_cfa = 'rggb';

% configuration for primal-dual algorithm
conf_pdopt_sigma_scale = 12.5; % noise variance
conf_pdopt_lambda_reg = 1; % weight of penalty term overall
conf_pdopt_max_iters = 30; % number of iteration
conf_lambda_cross = 0; % weight of cross channel prior
conf_lambda_channels = [[2000, [conf_lambda_cross, conf_lambda_cross, conf_lambda_cross]]; ... % color channel prior
                        [2000, [conf_lambda_cross, conf_lambda_cross, conf_lambda_cross]]; ...
                        [2000, [conf_lambda_cross, conf_lambda_cross, conf_lambda_cross]]];
               
%% input images
% read in images
I = im2double(imresize(imread('input.tif'),0.25));

% blurring
I_blur = zeros(size(I));
kernel_size = [17, 17];
kernel = cell(0);
channel_patch = cell(0);
radius = [8 8 8];
for ch = 1:size(I,3)
   kernel{ch} = zeros(kernel_size);
   %% no blur
%    kernel{ch}( floor(kernel_size(1)/2)+1, floor(kernel_size(2)/2)+1) = 1;
   %% ring kernel
    for j=1:kernel_size(1)
        for i=1:kernel_size(2)
            if abs(sqrt(floor(j-floor(kernel_size(1)/2) - 1)^2 + floor(i-floor(kernel_size(2)/2) - 1)^2) - radius(ch)) < 0.5
                kernel{ch}( j, i ) = 1;
            end
        end
    end
    %% normalize kernel
    kernel{ch} = kernel{ch}/sum(sum(kernel{ch}));
    I_blur(:,:,ch) = imfilter(I(:,:,ch), kernel{ch}, 'conv', 'replicate', 'same');
end

I_raw_input = generate_bayer(I_blur, conf_cfa);
% figure;imshow(I_raw_input);title('Captured Camera Image');

%% run optimization
%% initial guess
I_initial_guess = double(demosaic(uint8(I_raw_input*255), conf_cfa))/255;
for ch = 1:size(I,3)
%     I_initial_guess(:,:,ch) = deconvlucy(I_initial_guess(:,:,ch),kernel{ch});
%     I_initial_guess(:,:,ch) = deconvwnr(I_initial_guess(:,:,ch), kernel{ch}, 0.1);
%     I_initial_guess(:,:,ch) = rand(size(I(:,:,1)));
    I_initial_guess(:,:,ch) = I_blur(:,:,ch);
end

%% input data to pd
channel_patch = cell(0);
initial_channel_patch = cell(0);
[r_mask, g_mask, b_mask] = generate_bayer_mask(size(I(:,:,1)), conf_cfa);
channel_mask = cat(3, r_mask, g_mask, b_mask);
for ch = 1:size(I,3)
    channel_patch(ch).Image = I_raw_input .* channel_mask(:,:,ch);
    channel_patch(ch).K = kernel{ch};
    initial_channel_patch(ch).Image = I_initial_guess(:, :, ch);
    initial_channel_patch(ch).K = kernel{ch};
end
%% Primal-dual optimization
result = pd(channel_patch, initial_channel_patch, conf_lambda_channels, conf_pdopt_lambda_reg, ... 
    conf_pdopt_max_iters, conf_pdopt_sigma_scale, 1e-6, '.', 'brief', I);
I_result = cat(3, result(1).Image, result(2).Image, result(3).Image);
%% display results
figure;
ax(1)=subplot(2,2,1);imshow(I);title('Original Image');
ax(2)=subplot(2,2,2);imshow(I_blur);title('Blurred Image');
ax(3)=subplot(2,2,3);imshow(I_initial_guess);title('Initial Guess Image');
ax(4)=subplot(2,2,4);imshow(I_result);title('Optimized Image');
linkaxes(ax,'xy');
%% compute PSNR
% remove artifact border
border = floor(kernel_size(1)/2);
sr = border; er = size(I,1) - border;
sc = border; ec = size(I,2) - border;

% red channel
psnr_r = comppsnr(I_result(sr:er, sc:ec), I(sr:er, sc:ec));
psnr_g = comppsnr(I_result(sr:er, sc:ec), I(sr:er, sc:ec));
psnr_b = comppsnr(I_result(sr:er, sc:ec), I(sr:er, sc:ec));

fprintf('PSNR = [%.2f %.2f %.2f]\n', psnr_r, psnr_g, psnr_b);
