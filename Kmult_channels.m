function y = Kmult_channels(x, db_chs, w_tv, w_cross_channels, w_regularization)
% This function compute the matrix computation of K.
    for ch = 1:size(x,3)
        y{ch} = Kmult(x, ch, db_chs, w_tv, w_cross_channels(ch,:), w_regularization);
    end
end

function y = Kmult(x, ch, db_chs, w_tv, w_cross_channels, w_regularization)
    y = [];
    x_ch = x(:,:,ch);
    %% L1 norm( anisotropic TV)
    y = w_tv * grad(x_ch);
    %% regularization weigt overall (???)
    S_II = w_regularization * x_ch;
    y = cat(3, y, S_II);
    %% Cross-channel penalty
    dyf = [-1;1];
    dxf = [-1 1];
    for adj_ch = 1:size(x,3) 
    %Continue for current channel and zero channels
        if adj_ch == ch || w_cross_channels(adj_ch) < eps()
            continue;
        end
        adjChImg = db_chs(adj_ch).Image; %Curr cross channel
    %Compute cross terms
        diag_term = imfilter(adjChImg, fliplr(flipud(dxf)), 'conv', 'full');
        diag_term = diag_term(:, 2:end) .* x_ch;
        conv_term = imfilter(x_ch, fliplr(flipud(dxf)), 'conv', 'full');
        Sxf = (w_cross_channels(adj_ch) * 0.5) * ( adjChImg .* conv_term(:, 2:end) - diag_term );
    
        diag_term = imfilter(adjChImg, fliplr(flipud(dyf)), 'conv', 'full');
        diag_term = diag_term(2:end, :) .* x_ch;
        conv_term = imfilter(x_ch, fliplr(flipud(dyf)), 'conv', 'full');
        Syf = (w_cross_channels(adj_ch) * 0.5) * ( adjChImg .* conv_term(2:end, :) - diag_term );
    
    %Gather
        y = cat(3,y, Sxf, Syf);
    end
end