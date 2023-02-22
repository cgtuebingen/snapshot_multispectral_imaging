function db_chs = pd(channels, channels_0, w_channels, w_regularization, max_it, ...
    w_sigma_scale, tol, outputFolder, verbose, I_sharp)
% This is the main primal-dual algorithm to optimize FlexISP.
%% check for channel sanity
if ~isempty(channels_0) && (length(channels) ~= length(channels_0))
    error('Initial channels do not match channels.\n');
end

%% parameters
% initialization
db_chs = channels_0;
% current channels
w_res_curr = w_channels(:,1);
w_cross_curr = w_channels(:,2:end);

%% START MINIMIZATION
% for iter = 1:3
% sprintf('Start iteration...%d', iter)
[db_chs] = pd_channel_deconv(channels, db_chs, w_res_curr, w_cross_curr, w_regularization, w_sigma_scale, ...
    max_it, tol, verbose, outputFolder, I_sharp);
% end
end

function db_chs = pd_channel_deconv(channels, db_chs, lambda_residual_cap, w_cross_curr, w_regularization, w_sigma_scale, ...
    max_it, tol, verbose, outputFolder, I_sharp)
    if ~isempty(outputFolder)
        mkdir(outputFolder, 'iteration');
    end

    chImg = cat(3, channels(1).Image, channels(2).Image, channels(3).Image);
    dbchImg = cat(3, db_chs(1).Image, db_chs(2).Image, db_chs(3).Image);
    
    w_tv = 5;
    sigma = 40; % 27;
    theta = 1.0; 
    L = operator_norm(w_regularization, w_tv, w_cross_curr, db_chs, size(chImg));
    tau = 0.9/(sigma*L^2);
    %% initialize regularization operators
    % image gradient sparsity prior
    ProxL1 = @(u) u./max(1, sqrt(u.^2));
    % denoising prior
    ProxBM3D = @(u, noise_sigma) CBM3D(1, u, noise_sigma);
    % combining regularization operators
    ProxF = @(y, gamma) prox_wrap(y, gamma, ProxBM3D, ProxL1);
    %% initialize data fidelity operators
    lambda_residual_cap = cat( 3, repmat( lambda_residual_cap(1), size(chImg,1), size(chImg,2) ), ...
                                  repmat( lambda_residual_cap(2), size(chImg,1), size(chImg,2) ), ...
                                  repmat( lambda_residual_cap(3), size(chImg,1), size(chImg,2) ) );
    ProxG = @(v, tau) solve_cg(v, tau, chImg, channels, lambda_residual_cap);    
    %% initialize x_0, y_0
    x = dbchImg;
    y = Kmult_channels(x, db_chs, w_tv, w_cross_curr, w_regularization);
    %% z is chImg
    %% iteration max_iters times of primal-dual algorithm
    for k = 1:max_it
        y_k = y;
        x_k = x;
        y = Kmult_channels(x_k, db_chs, w_tv, w_cross_curr, w_regularization);
        for ch = 1:length(y)
            y{ch} = (sigma * y{ch} + y_k{ch})/sigma;
        end
    %% solve penalty term
        proxF = ProxF(y, w_sigma_scale);
        for ch = 1:length(y)
            y{ch} = sigma*y{ch} - sigma * proxF{ch};
        end
    %% solve data fidelity term
        x = ProxG(x_k - tau * KmultT_channels(y, db_chs, w_tv, w_cross_curr, w_regularization), tau);
    %% extrapolation term
        x = x + theta*(x - x_k);
    %% computer PSNR
        fprintf('Iteration: %d\n', k);
    end
    db_chs(1).Image = x(:,:,1);
    db_chs(2).Image = x(:,:,2);
    db_chs(3).Image = x(:,:,3);
end