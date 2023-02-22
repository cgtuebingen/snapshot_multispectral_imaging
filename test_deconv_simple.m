clear all;
close all;
clc;
startup
% Test script for hyperspectral debayering

% Load cfa calibration data, concatenate and normalise weights
[status,result] = system('whoami');
username = result(1:end-1);

switch username
 case 'chenjiee'
  PATH_TO_IMAGES = '/graphics/projects/data/slm_camera/psf_measurements/160624_data/'; 
 case 'mhirsch'
  PATH_TO_IMAGES = '/media/data/projects/slm_camera/data/psf_measurements/160624_data/';
end

% Load monochromatic lego image
FILENAME = 'spiralLego.mat';

load([PATH_TO_IMAGES FILENAME]);

ncolors = 5;
offset = [701,601];
sx = [800,800];
sh = [sx ncolors];
raw = zeros(sx(1), sx(2), ncolors);

raw(:,:,1) = multiChSpiralLego_0(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,2) = multiChSpiralLego_1(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,3) = multiChSpiralLego_2(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,4) = multiChSpiralLego_3(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,5) = multiChSpiralLego_4(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);

y = {ncolors};
for col = 1:1:ncolors
    y{col} = mean(demosaic(im2uint16(raw(:,:,col)/max(vec(raw(:,:,col)))),'rggb'),3);
end

raw(:,:,1) = multiChSpiralLego_gt_0(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,2) = multiChSpiralLego_gt_1(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,3) = multiChSpiralLego_gt_2(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,4) = multiChSpiralLego_gt_3(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,5) = multiChSpiralLego_gt_4(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);

xgt = {ncolors};
for col = 1:1:ncolors
    xgt{col} = mean(demosaic(im2uint16(raw(:,:,col)/max(vec(raw(:,:,col)))),'rggb'),3);
end

offset = [953,1001];
sx = [120,120];

rawpsf(:,:,1) = multiChSpiralPSFs_0(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
rawpsf(:,:,2) = multiChSpiralPSFs_1(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
rawpsf(:,:,3) = multiChSpiralPSFs_2(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
rawpsf(:,:,4) = multiChSpiralPSFs_3(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
rawpsf(:,:,5) = multiChSpiralPSFs_4(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);

%% load demosaiced psf

% matlab demosaiced
% psf = {ncolors};
% for col = 1:1:ncolors
%     psf{col} = mean(demosaic(im2uint16(rawpsf(:,:,col)/max(vec(rawpsf(:,:,col)))),'rggb'),3);
% end

% lbfgsb demosaiced
psf = {ncolors};
load('psf_gt.mat');
for col = 1:ncolors
    psf{col} = psf_gt(:,:,col);
    psf{col} = psf{col}/max(psf{col}(:));
end
%%
xhat = {ncolors};
for col = 1:1:ncolors
  xhat{col} = deconvlucy(y{col}, psf{col});
end

figure;
for col = 1:1:ncolors
  subplot(1,5,col)
  imagesc(flipud(log(psf{col})));axis image
end
linkaxes

figure;
for col = 1:1:ncolors
  subplot(3,5,col)
  imagesc(flipud(y{col}));axis image
  subplot(3,5,col+5)
  imagesc(flipud(xhat{col}));axis image
  subplot(3,5,col+10)
  imagesc(flipud(xgt{col}));axis image
end
linkaxes