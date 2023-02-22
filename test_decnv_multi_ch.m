% This program perform ONLY the deconvolution by demosaicing first the 

clear all;
close all;
clc;
startup

%% Load data

% Load cfa calibration data, concatenate and normalise weights
PATH_TO_CFA_CALIBRATION = '/graphics/projects/data/slm_camera/psf_measurements/160524_data/';
FILENAME_CFA_CALIBRATION = 'cfaCalib_1.mat';

load([PATH_TO_CFA_CALIBRATION FILENAME_CFA_CALIBRATION]);

cfa_calibration_weights = cat(1,m_r,m_g,m_b);
cfa_calibration_weights = cfa_calibration_weights./repmat(sum(cfa_calibration_weights,1),[3 1]); % normalization of weights

% Load monochromatic lego image
PATH_TO_IMAGES = '/graphics/projects/data/slm_camera/psf_measurements/160624_data/';
FILENAME = 'spiralLego.mat';

load([PATH_TO_IMAGES FILENAME]);

ncolors = 5;
offset = [701,601];
% sx = [800,800];
sx = [20,20];
sh = [sx ncolors];
raw = zeros(sx(1), sx(2), ncolors);

raw(:,:,1) = multiChSpiralLego_gt_0(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,2) = multiChSpiralLego_gt_1(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,3) = multiChSpiralLego_gt_2(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,4) = multiChSpiralLego_gt_3(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
raw(:,:,5) = multiChSpiralLego_gt_4(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
for col = 1:1:ncolors
    raw(:,:,col) = mean(demosaic(im2uint16(raw(:,:,col)/max(vec(raw(:,:,col)))),'rggb'),3);
end

y = spiralLego(offset(1):offset(1)+sx(1)-1,offset(2):offset(2)+sx(2)-1);
y = mean(demosaic(im2uint16(y/max(y(:))),'rggb'),3);
y = y/max(vec(y));

offset_psf = [953,1001];
% sx_psf = [120,120];
sx_psf = [8,8];

rawpsf(:,:,1) = multiChSpiralPSFs_0(offset_psf(1):offset_psf(1)+sx_psf(1)-1,offset_psf(2):offset_psf(2)+sx_psf(2)-1);
rawpsf(:,:,2) = multiChSpiralPSFs_1(offset_psf(1):offset_psf(1)+sx_psf(1)-1,offset_psf(2):offset_psf(2)+sx_psf(2)-1);
rawpsf(:,:,3) = multiChSpiralPSFs_2(offset_psf(1):offset_psf(1)+sx_psf(1)-1,offset_psf(2):offset_psf(2)+sx_psf(2)-1);
rawpsf(:,:,4) = multiChSpiralPSFs_3(offset_psf(1):offset_psf(1)+sx_psf(1)-1,offset_psf(2):offset_psf(2)+sx_psf(2)-1);
rawpsf(:,:,5) = multiChSpiralPSFs_4(offset_psf(1):offset_psf(1)+sx_psf(1)-1,offset_psf(2):offset_psf(2)+sx_psf(2)-1);

psf = {ncolors};
for col = 1:1:ncolors
    psf{col} = mean(demosaic(im2uint16(rawpsf(:,:,col)/max(vec(rawpsf(:,:,col)))),'rggb'),3);
    psf{col} = psf{col}/max(vec(psf{col}));
end

xinit = zeros(size(raw));
lb = zeros(size(raw));
ub = zeros(size(raw));

for col = 1:1:ncolors
% First column of cfa_calibration_weights corresponds to 700nm
% which hasn't been captured for this example
    C{col} = cnv2mat(psf{col}, sx, 'same'); % convolution matrix
    % initial guess and bounds
    xinit(:,:,col) = raw(:,:,col)/max(vec(raw(:,:,col)));
    lb(:,:,col) = ones(sx);
    ub(:,:,col) = zeros(sx);
end

G = grad2mat([],[],'same',[],'');
alpha = 1.0;
global ax;
ax{1} = C;
ax{2} = y;
ax{3} = sx;
ax{4} = G;
ax{5} = alpha;
tol = 1e-12;
maxiter = 1000;

%% Call L-BFGS-B
xinit = reshape(xinit,[size(xinit,1)*size(xinit,2)*size(xinit,3),1]);
lb = reshape(lb,[size(lb,1)*size(lb,2)*size(lb,3),1]);
ub = reshape(ub,[size(ub,1)*size(ub,2)*size(ub,3),1]);

xsol = lbfgsb(xinit, lb, ub, ...
              'test_decnv_multi_ch_objfun', 'test_decnv_multi_ch_gradfun', ...
              [], [], ...
              'maxiter', maxiter, ...    % max iterations
              'm', 3, ...         % smaller means faster iterations
              'factr',tol, ...   % convergence condition
              'pgtol',tol);      % tolerance of proj gradient 